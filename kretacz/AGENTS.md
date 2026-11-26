# Valve driver (krętacz)

PlatformIO project (Arduino Nano, ATmega328P, `board = nanoatmega328new`, new bootloader at 115200). A stepper motor turns the needle valve that lets air into a vacuum chamber. Firmware adjusts the valve to reach a target inflow or pressure.

All code is in `src/main.cpp`. Keep it minimal and readable.

## Hardware
- Motor: WObit 39BYGH405B, bipolar, 1.8deg, 12 V, 0.4 A. Coil A (white/yellow) -> 1A/1B, coil B (red/blue) -> 2A/2B.
- Driver: Pololu-style A4988 or DRV8825 (labels DIRECTION/STEP/SLEEP/RESET/MS1-3/ENABLE), NOT a TMC2208, no UART. RESET must be tied to SLEEP (or 5 V). Current limit set by trimpot. MS1-3 are tied to 5 V (1/16 on A4988, 1/32 on DRV8825): `STEPS_PER_REV` in code must match the real chip.
- Pins: STEP D2, DIR D3, EN D4 (active low), pressure gauge on A0 through a 1:2 divider (sensor outputs 0-10 V, ADC 5 V ref).
- Voltage reading: ADC uses Vcc as reference, so `readVcc()` measures the real Vcc against the internal 1.1 V bandgap (`BANDGAP_V`) and scales readings with it (same approach as `../arduino-voltometer`). After the 1:2 divider factor, a linear correction `V*CAL_GAIN + CAL_OFFSET` (1.02, 0.0236 V) is applied, fitted against a reference multimeter. The fit depends on the bandgap compensation: if `BANDGAP_V` or the method changes, redo the calibration.
- Valve is hand-limited mechanically at fully closed.

## Physics / formulas
Documented in `../sccm to f(U_prozniomiez)/filter/README.md` (Polish).
- Pressure from gauge voltage: `P[Pa] = 10^(1.667*U - 9.333)`.
- Inflow in mg/s is a cubic polynomial in **pressure** (not voltage; README's last section is sloppy about this), valid for roughly 0.002-0.07 mg/s. Works because the pump removes a constant amount at steady state.

## Serial protocol (115200, newline-terminated)
`F <mg/s>` flow PID, `P <Pa>` pressure PID, `M <deg>` rotate by angle (0 = stop everything), `Z` set current position as 0, `ZE`/`ZD` enable/disable the closed-end (position 0) limit (disabled at boot), `RF`/`RP`/`RV` read flow/pressure/voltage, `RA` read angle from 0. Replies `OK` for commands, `?` for unknown ones, `LIMIT closed|open` when a limit stops motion.

## Design notes
- `MOTOR_DIRECTION` (+1/-1) flips motor direction. Positive must mean "opening" (PID relies on it).
- PID output is valve **speed**, so the valve acts as an integrator. Default `KI = 0`; KD works on the measurement. Gains are fractions of `PID_MAX_SPEED`. The valve-to-pressure response has lots of lag, so keep it slow.
- PID only sets `pidSpeed` (steps/s) every 200 ms; `updateStepper` steps continuously at that rate (evenly spaced). Do not turn PID output into a burst of pending steps - that made the valve hop. Coils stay powered while in PID mode.
- Speeds are defined in revolutions per second times `STEPS_PER_REV`, so they scale with microstepping.
- Software limit: position 0 = valve closed at boot (or after `Z`), but the closed-end limit is **off by default** and only enforced after `ZE` (`ZD` turns it back off). All steps pass through `updateStepper`, which enforces it for manual and PID modes. Optional `MAX_OPEN_DEG`. Position is dead-reckoned, so lost steps or hand-turning cause drift. No limit switch yet (a microswitch at the closed end was suggested).
- Coils are disabled when idle.

## Workflow
- `pio run` to build. Upload with `pio run -t upload` (board on `/dev/ttyUSB0`). Test serial with `pio device monitor -b 115200`.
- Check any change to angles/speeds against `STEPS_PER_REV`. Do not upload without the user's say-so when hardware is not attached.
- PID gains are untuned on the real valve; tuning is in progress.
