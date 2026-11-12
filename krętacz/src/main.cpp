// Valve driver: stepper (TMC2208) turns the valve, pressure gauge read on A0.
//
// Serial commands (115200, newline terminated):
//   F <mg/s>   hold inflow at target (PID)
//   P <Pa>     hold pressure at target (PID)
//   M <deg>    rotate by angle (negative = other way) and stay; 0 = stop everything
//   RF / RP / RV   read inflow [mg/s] / pressure [Pa] / raw voltage [V]
#include <Arduino.h>

// ---- hardware ----
const uint8_t PIN_STEP = 2;
const uint8_t PIN_DIR = 3;
const uint8_t PIN_EN = 4;  // TMC2208 EN, aztive LOW
const uint8_t PIN_ADC = A0;

// Flip to -1 if "positive" turns the valve the wrong way.
// Positive must mean "opening" (more inflow) - PID relies on it.
const int MOTOR_DIRECTION = 1;

//const float STEPS_PER_REV = 200.0f * 8;  // 1.8deg motor, TMC2208 default 1/8 microstep (MS1=MS2=GND)
const float STEPS_PER_REV = 200.0f;  // Pololu-style A4988 or DRV8825 driver (MS1=MS2=GND)
const float DIVIDER = 2.0f;              // 1:2 divider before ADC
const float ADC_VREF = 5.0f;

// ---- motion ----
const float MANUAL_SPEED = 200;    // steps/s
const float PID_MAX_SPEED = 100;   // steps/s, keeps PID adjustments slow

// ---- PID (error is relative: (target - measured) / target; output in steps/s) ----
const float KP = 300, KI = 50, KD = 0;
const unsigned long PID_PERIOD_MS = 200;

enum Mode { IDLE, MANUAL, TARGET_FLOW, TARGET_PRESSURE };
Mode mode = IDLE;
float target = 0;

long pending = 0;  // steps left to do (signed, in "valve opening" direction)
unsigned long stepIntervalUs = 1000000UL / MANUAL_SPEED;

float integral = 0, lastError = 0;
float stepRemainder = 0;
unsigned long lastPid = 0;

float readVoltage() {
  long sum = 0;
  for (int i = 0; i < 16; i++) sum += analogRead(PIN_ADC);
  return sum / 16.0f / 1023.0f * ADC_VREF * DIVIDER;
}

float voltageToPressure(float v) { return pow(10.0f, 1.667f * v - 9.333f); }

float pressureToFlow(float p) {
  return ((-81.7547f * p + 12.65459f) * p + 0.29089f) * p + 0.00217f;
}

float readPressure() { return voltageToPressure(readVoltage()); }
float readFlow() { return pressureToFlow(readPressure()); }

void stop() {
  mode = IDLE;
  pending = 0;
  stepRemainder = 0;
}

void startMode(Mode m, float value) {
  stop();
  if (value <= 0) return;
  mode = m;
  target = value;
  integral = lastError = 0;
  lastPid = millis();
  stepIntervalUs = 1000000UL / PID_MAX_SPEED;
}

void startManual(float degrees) {
  stop();
  if (degrees == 0) return;
  mode = MANUAL;
  pending = degrees / 360.0f * STEPS_PER_REV;
  stepIntervalUs = 1000000UL / MANUAL_SPEED;
}

void updatePid() {
  if (mode != TARGET_FLOW && mode != TARGET_PRESSURE) return;
  if (millis() - lastPid < PID_PERIOD_MS) return;
  float dt = (millis() - lastPid) / 1000.0f;
  lastPid = millis();

  float measured = (mode == TARGET_FLOW) ? readFlow() : readPressure();
  float error = (target - measured) / target;
  integral = constrain(integral + error * dt, -PID_MAX_SPEED / max(KI, 1e-6f), PID_MAX_SPEED / max(KI, 1e-6f));
  float out = KP * error + KI * integral + KD * (error - lastError) / dt;
  lastError = error;

  out = constrain(out, -PID_MAX_SPEED, PID_MAX_SPEED);
  stepRemainder += out * dt;
  long whole = (long)stepRemainder;
  stepRemainder -= whole;
  pending = whole;
}

void updateStepper() {
  static unsigned long lastStep = 0;
  if (pending == 0) {
    if (mode == MANUAL) mode = IDLE;
    digitalWrite(PIN_EN, HIGH);  // release the coil when nothing to do
    return;
  }
  digitalWrite(PIN_EN, LOW);
  if (micros() - lastStep < stepIntervalUs) return;
  lastStep = micros();

  bool forward = pending > 0;
  digitalWrite(PIN_DIR, (forward == (MOTOR_DIRECTION > 0)) ? HIGH : LOW);
  digitalWrite(PIN_STEP, HIGH);
  delayMicroseconds(2);
  digitalWrite(PIN_STEP, LOW);
  pending += forward ? -1 : 1;
}

void handleCommand(String line) {
  line.trim();
  line.toUpperCase();
  if (line.length() == 0) return;
  float value = line.substring(1).toFloat();

  if (line == "RF") Serial.println(readFlow(), 5);
  else if (line == "RP") Serial.println(readPressure(), 5);
  else if (line == "RV") Serial.println(readVoltage(), 4);
  else if (line[0] == 'F') startMode(TARGET_FLOW, value);
  else if (line[0] == 'P') startMode(TARGET_PRESSURE, value);
  else if (line[0] == 'M') startManual(value);
  else { Serial.println("?"); return; }

  if (line[0] == 'F' || line[0] == 'P' || line[0] == 'M') Serial.println("OK");
}

void setup() {
  pinMode(PIN_STEP, OUTPUT);
  pinMode(PIN_DIR, OUTPUT);
  pinMode(PIN_EN, OUTPUT);
  digitalWrite(PIN_EN, HIGH);
  Serial.begin(115200);
}

void loop() {
  static String line;
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') { handleCommand(line); line = ""; }
    else line += c;
  }
  updatePid();
  updateStepper();
}
