import pandas as pd

SRC, DST = "10-30-0--0-actually.csv", "steady_points.csv"
VMAX = 5.0  # drop points above this voltage
EPS, MINLEN, SKIP, BACK = (
    2e-3,
    5,
    150,
    2,
)  # settled |ΔV| ; min plateau length ; drop N pts each end ; step back N pts from plateau end

df = pd.read_csv(SRC, skipinitialspace=True)
core = df.iloc[
    SKIP : len(df) - SKIP
]  # .iloc keeps original index -> src_row stays true

v = core["Pressure Voltage"]
settled = (v.diff().abs() < EPS).fillna(False)  # seam row has no predecessor
settled.iloc[0] = False  # ...so never treat it as a plateau start

rid = (~settled).cumsum()
rlen = settled.groupby(rid).transform("sum")
last = (
    settled & (rid != rid.shift(-1)) & v.shift(-1).notna()
)  # last row of each settled run

pick = (last & (rlen >= MINLEN)).shift(
    -BACK, fill_value=False
)  # move the pick back before the voltage starts creeping
out = core[pick & (v <= VMAX)].copy()
out.insert(0, "src_row", out.index + 2)  # original CSV line number
out = out.reset_index(drop=True)
out.to_csv(DST, index=False)
print(f"{len(out)} points -> {DST}")
