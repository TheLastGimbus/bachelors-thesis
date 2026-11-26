import pandas as pd
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

SRC, PTS, OUT = "10-30-0--0-actually.csv", "steady_points.csv", "/tmp/opencode/plot.png"

df = pd.read_csv(SRC, skipinitialspace=True)
pts = pd.read_csv(PTS)
t0 = df["system time"].iloc[0]

fig, (a1, a2) = plt.subplots(2, 1, sharex=True, figsize=(14, 7))
a1.plot(df["system time"] - t0, df["Pressure Voltage"], lw=0.8)
a1.plot(pts["system time"] - t0, pts["Pressure Voltage"], "ro")
a1.set_ylabel("Pressure Voltage [V]")
a2.plot(df["system time"] - t0, df["mass flow"], lw=0.8)
a2.plot(pts["system time"] - t0, pts["mass flow"], "ro")
a2.set_ylabel("mass flow [mg/s]")
a2.set_xlabel("time [s]")
fig.tight_layout()
fig.savefig(OUT, dpi=100)
print(OUT)
