#include <Arduino.h>

// USB-UART voltmeter for Arduino Nano (ATmega328P)
//
// Wiring: signals to measure -> A0..A7 (0..Vcc, no divider on this build).
// Usage: open the serial port at 115200 baud and press Enter.
//        The board replies with one tab-separated line containing every
//        analog pin in order A0..A7, for example:
//        1.786\t0.001\t...\t0.000
//
// The ADC reference is the 5 V rail, which is only approximately 5 V when
// powered over USB. To get a usable absolute reading the actual Vcc is
// measured against the ATmega's internal 1.1 V bandgap reference and used
// to scale the ADC result.

const uint8_t FIRST_ANALOG_PIN = A0;
const uint8_t ANALOG_PIN_COUNT = 8;  // A0..A7
const uint8_t AVERAGE_SAMPLES = 16;

// Nominal bandgap voltage in millivolts. The datasheet value is 1.1 V.
const uint16_t BANDGAP_MV = 1100;

// Measure Vcc in millivolts using the internal bandgap reference.
uint16_t readVccMillivolts() {
  // Select AVcc as reference and the 1.1 V bandgap as ADC input
  // (MUX3..0 = 1110 on ATmega328P).
  ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
  delay(2);  // Let the reference settle.

  ADCSRA |= _BV(ADSC);
  while (bit_is_set(ADCSRA, ADSC)) {
  }

  uint16_t adc = ADC;
  if (adc == 0) {
    return 0;
  }

  // Vcc = Vbandgap * 1023 / ADC
  return (uint32_t)BANDGAP_MV * 1023UL / adc;
}

uint16_t readAnalogAverage(uint8_t pin, uint8_t samples) {
  uint32_t sum = 0;
  for (uint8_t i = 0; i < samples; i++) {
    sum += analogRead(pin);
    delay(2);
  }
  return sum / samples;
}

float measureVoltage(uint8_t pin, uint16_t vccMillivolts) {
  // Throw away the first conversion after switching from another input,
  // then average the rest.
  analogRead(pin);
  uint16_t adc = readAnalogAverage(pin, AVERAGE_SAMPLES);
  if (vccMillivolts == 0) {
    return 0.0;
  }
  return (float)adc * (vccMillivolts / 1000.0) / 1023.0;
}

// Emit one tab-separated line with the voltage on every analog pin (A0..A7).
void printMeasurements(uint16_t vccMillivolts) {
  for (uint8_t i = 0; i < ANALOG_PIN_COUNT; i++) {
    if (i > 0) {
      Serial.print('\t');
    }
    Serial.print(measureVoltage(FIRST_ANALOG_PIN + i, vccMillivolts), 3);
  }
  // Plain LF keeps the output easy to consume from a script.
  Serial.print('\n');
}

void setup() {
  Serial.begin(115200);
  analogReference(DEFAULT);
  // Discard the first conversion after switching reference/input.
  analogRead(FIRST_ANALOG_PIN);
}

void loop() {
  static bool lastWasCR = false;

  while (Serial.available() > 0) {
    char c = (char)Serial.read();

    // Accept LF, CR or CRLF as the "Enter" key.
    bool isEnter = (c == '\n') || (c == '\r');
    if (!isEnter) {
      lastWasCR = false;
      continue;
    }

    // Swallow the LF of a CRLF pair so one Enter gives one reading.
    if (c == '\n' && lastWasCR) {
      lastWasCR = false;
      continue;
    }
    lastWasCR = (c == '\r');

    uint16_t vccMv = readVccMillivolts();
    printMeasurements(vccMv);
  }
}
