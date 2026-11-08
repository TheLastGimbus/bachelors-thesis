# Arduino Nano USB-UART voltmeter

Measures the voltage on every analog pin (`A0`..`A7`) and reports it over the
USB serial port as one tab-separated line per reading. A reading is taken only
when an Enter key (CR, LF or CRLF) is received.

## Usage

1. Connect the voltages to measure (0..Vcc) to `A0`..`A7`, with grounds tied
   together at `GND`.
2. Connect the board over USB.
3. Open the serial port at **115200 baud**.
4. Press Enter. The board answers with one line, for example:

   ```
   1.786	0.002	0.001	0.000	0.001	0.002	0.000	0.001
   ```

   Columns are `A0`, `A1`, `A2`, `A3`, `A4`, `A5`, `A6`, `A7`, in that order.
   Values are in volts. Pins with nothing connected will float and can show
   arbitrary readings.

PlatformIO commands:

```sh
pio run -t upload
pio device monitor
```

Reading the values from a script (Python):

```python
import serial

with serial.Serial("/dev/ttyUSB0", 115200, timeout=2) as port:
    port.write(b"\n")
    values = [float(v) for v in port.readline().decode().strip().split("\t")]
    print(values[0])  # A0
```

## Accuracy

The ADC uses Vcc as its reference, so the firmware measures the actual Vcc
against the ATmega328P internal 1.1 V bandgap and compensates for it. The
bandgap value varies slightly from chip to chip, so absolute accuracy is
roughly a few percent. If you need better accuracy, measure a known voltage,
then adjust `BANDGAP_MV` in `src/main.cpp` accordingly.

Do not exceed Vcc (about 5 V) on any analog pin.
