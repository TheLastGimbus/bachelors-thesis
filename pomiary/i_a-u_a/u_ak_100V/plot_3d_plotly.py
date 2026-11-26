#!/usr/bin/env python3
"""Combine i_a-u_a sweeps (one CSV per flow value) into a 3D graph (Plotly).

Same data pipeline as plot_3d.py: every *.csv next to this script is one
run at a fixed flow (setpoint from the filename, e.g. "sccm_0.115"),
sweeping U_a; I_a samples are median-binned into common U_a bins and
written to combined.csv. One I_a(U_a) curve per flow, colored by flow.
Rendered with Plotly instead of Matplotlib: the main output is an
interactive HTML (rotate/zoom, hover shows values), plus a static PNG
via Kaleido for the thesis.

Flags:
  --measured-flow  Position each point at the Flow actually measured
                   in the CSV's Flow column (median per bin, same
                   samples as the I_a median) instead of the constant
                   setpoint from the filename.
  --trim-x [MARGIN]  Limit the U_a axis to just around the active
                   region: where I_a leaves the noise floor (ignition)
                   and returns to it (extinction), +/- MARGIN V
                   (default 50). Points outside the window are cut
                   from the plot.
"""

import argparse
import csv
import math
import re
from pathlib import Path

import numpy as np
import plotly.colors
import plotly.graph_objects as go

HERE = Path(__file__).resolve().parent
OUT_HTML = HERE / "u_ak_100V_3d.html"
OUT_PNG = HERE / "u_ak_100V_3d_plotly.png"
OUT_CSV = HERE / "combined.csv"

UA_BIN = 10.0  # V, bin width for averaging I_a at a given U_a

WIDTH, HEIGHT = 1100, 750  # px; PNG export uses scale=2 => 2200x1500


def load_run(path):
    """Return (setpoint, U_a, I_a, Flow column) for one measurement CSV."""
    flow_match = re.search(r"sccm_([0-9]+(?:\.[0-9]+)?)", path.name)
    if flow_match is None:
        print(f"  !! no 'sccm_*' in filename, skipping: {path.name}")
        return None

    ua, ia, fl = [], [], []
    bad = 0
    with path.open(newline="") as fh:
        for row in csv.reader(fh, delimiter="\t"):
            if not row or row[0].lstrip().startswith("#"):
                continue
            if "U_a" in row[0]:  # header line
                continue
            try:
                u = float(row[1])
                i = float(row[2])
                f = float(row[4])
            except (ValueError, IndexError):
                continue
            if not (math.isfinite(u) and math.isfinite(i) and math.isfinite(f)):
                bad += 1  # e.g. a 'nan' from a voltmeter/serial glitch
                continue
            ua.append(u)
            ia.append(i)
            fl.append(f)
    if bad:
        print(f"  !! dropped {bad} non-finite row(s) in: {path.name}")

    if len(ua) < 2:
        print(f"  !! no usable rows in: {path.name}")
        return None

    setpoint = float(flow_match.group(1))
    print(
        f"  {path.name}: setpoint={setpoint} sccm, {len(ua)} rows, "
        f"U_a {min(ua):.0f}..{max(ua):.0f} V, "
        f"Flow col mean {np.mean(fl):.4f}"
    )
    return setpoint, np.asarray(ua), np.asarray(ia), np.asarray(fl)


def bin_run(ua, ia, fl, edges):
    """Per U_a bin: median U_a, Flow, I_a; returns arrays + counts."""
    idx = np.digitize(ua, edges) - 1
    valid = (idx >= 0) & (idx < len(edges) - 1)
    idx = idx[valid]
    ua_v, ia_v, fl_v = ua[valid], ia[valid], fl[valid]

    bins, med_u, med_f, med_i, counts = [], [], [], [], []
    for b in np.unique(idx):
        sel = idx == b
        bins.append(int(b))
        med_u.append(np.median(ua_v[sel]))
        med_f.append(np.median(fl_v[sel]))
        med_i.append(np.median(ia_v[sel]))  # median: robust to spikes
        counts.append(sel.sum())
    return (
        np.asarray(bins, int),
        np.asarray(med_u),
        np.asarray(med_f),
        np.asarray(med_i),
        np.asarray(counts),
    )


def active_x_span(line_bins, line_x, Z, frac=0.05):
    """U_a range where any curve leaves the noise floor (I_a > frac*max)."""
    zs = np.concatenate([Z[k, b] for k, b in enumerate(line_bins)])
    xs = np.concatenate(line_x)
    on = zs > np.nanmax(zs) * frac
    return xs[on].min(), xs[on].max()


def flow_color(v, lo, span):
    """One Viridis rgb string for a flow value in [lo, lo + span]."""
    return plotly.colors.sample_colorscale("Viridis", [(v - lo) / span])[0]


def build_figure(runs, line_bins, line_x, line_y, Z, measured_flow, x_range=None):
    """Assemble the Plotly figure: one line trace per run."""
    y_anchor = np.array([np.mean(y) for y in line_y])
    lo, hi = y_anchor.min(), y_anchor.max()
    span = max(hi - lo, 1e-12)

    fig = go.Figure()
    for k, (setpoint, _, _, _) in enumerate(runs):
        bins, x, y = line_bins[k], line_x[k], line_y[k]
        if measured_flow:
            label = f"{np.mean(y):.4f} sccm (set {setpoint:g})"
        else:
            label = f"{setpoint:g} sccm"
        fig.add_trace(
            go.Scatter3d(
                x=x,
                y=y,
                z=Z[k, bins],
                mode="lines",
                line=dict(color=flow_color(np.mean(y), lo, span), width=5),
                name=label,
                hovertemplate=(
                    "U_a %{x:.1f} V<br>"
                    "Flow %{y:.4f} sccm<br>"
                    "I_a %{z:.1f} µA"
                    "<extra>%{name}</extra>"
                ),
            )
        )

    # Same viewpoint as plot_3d.py's view_init(elev=25, azim=-60),
    # converted to a Plotly camera eye position.
    elev, azim = math.radians(25), math.radians(-60)
    r = 2.0
    eye = {
        "x": r * math.cos(elev) * math.cos(azim),
        "y": r * math.cos(elev) * math.sin(azim),
        "z": r * math.sin(elev),
    }

    scene = dict(
        xaxis_title="U<sub>a</sub> [V]",
        yaxis_title="Flow [sccm]",
        zaxis_title="I<sub>a</sub> [µA]",
        camera=dict(eye=eye),
    )
    if x_range is not None:
        scene["xaxis"] = dict(range=list(x_range))

    fig.update_layout(
        width=WIDTH,
        height=HEIGHT,
        title=dict(
            text=(
                "Charakterystyka I<sub>a</sub>(U<sub>a</sub>) dla różnych przepływów"
                "<br><sup>U<sub>ak</sub> = 100 V</sup>"
            ),
            x=0.5,
            xanchor="center",
            y=0.97,
        ),
        scene=scene,
        legend=dict(title=dict(text="Flow [sccm]"), x=0.0, y=0.98),
        margin=dict(l=0, r=0, t=40, b=0),
    )
    return fig


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "--measured-flow",
        action="store_true",
        help="use the Flow measured in the CSV column (per-bin median) "
        "for the Y position instead of the filename setpoint",
    )
    ap.add_argument(
        "--trim-x",
        nargs="?",
        const=50.0,
        type=float,
        metavar="MARGIN_V",
        help="limit the U_a axis to just around the active region "
        "(ignition .. extinction) with this margin in V (default 50)",
    )
    args = ap.parse_args()

    files = sorted(p for p in HERE.glob("*.csv") if p != OUT_CSV)
    print(f"Found {len(files)} CSV files in {HERE}:")
    print(
        f"Y position: {'measured Flow column' if args.measured_flow else 'filename setpoint'}\n"
    )

    runs = []
    for f in files:
        got = load_run(f)
        if got:
            runs.append(got)
    if len(runs) < 2:
        raise SystemExit("Need at least 2 runs to build a 3D graph.")
    runs.sort(key=lambda r: r[0])  # by setpoint

    all_ua = np.concatenate([ua for _, ua, _, _ in runs])
    lo = math.floor(all_ua.min() / UA_BIN) * UA_BIN
    edges = np.arange(lo, all_ua.max() + UA_BIN, UA_BIN)
    centers = edges[:-1] + UA_BIN / 2

    # Median I_a per U_a bin for every run (NaN outside its own range),
    # plus the coordinates actually used for the line points
    Z = np.full((len(runs), len(centers)), np.nan)
    line_bins, line_x, line_y = [], [], []
    rows_csv = []
    for k, (setpoint, ua, ia, fl) in enumerate(runs):
        bins, med_u, med_f, med_i, counts = bin_run(ua, ia, fl, edges)
        covered = (centers[bins] >= ua.min()) & (centers[bins] <= ua.max())
        bins = bins[covered]
        med_u, med_f, med_i, counts = (
            med_u[covered],
            med_f[covered],
            med_i[covered],
            counts[covered],
        )

        Z[k, bins] = med_i * 1e6  # A -> uA
        line_bins.append(bins)
        if args.measured_flow:
            line_x.append(med_u)
            line_y.append(med_f)
        else:
            line_x.append(centers[bins])
            line_y.append(np.full(len(bins), setpoint))

        for b, mf, mi, n in zip(bins, med_f, med_i, counts):
            rows_csv.append((centers[b], setpoint, mf, mi * 1e6, n))

    # Save the combined, binned data
    with OUT_CSV.open("w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(
            [
                "U_a bin center [V]",
                "Flow setpoint [sccm]",
                "Flow measured [sccm]",
                "I_a [uA]",
                "samples in bin",
            ]
        )
        w.writerows(rows_csv)
    print(f"\nWrote {OUT_CSV.name} ({len(rows_csv)} binned points)")

    # --trim-x: keep the plotted data consistent with the axis window
    # (cutting the points outside). combined.csv keeps every point.
    win = None
    if args.trim_x is not None:
        x0, x1 = active_x_span(line_bins, line_x, Z)
        win = (x0 - args.trim_x, x1 + args.trim_x)
        print(
            f"Trimming U_a axis to {win[0]:.0f}..{win[1]:.0f} V (cutting points outside)"
        )
        for k in range(len(line_bins)):
            m = (line_x[k] >= win[0]) & (line_x[k] <= win[1])
            line_bins[k] = line_bins[k][m]
            line_x[k] = line_x[k][m]
            line_y[k] = line_y[k][m]

    fig = build_figure(
        runs, line_bins, line_x, line_y, Z, args.measured_flow, x_range=win
    )

    # Interactive HTML: self-contained (plotly.js embedded), rotate/zoom.
    fig.write_html(OUT_HTML, include_plotlyjs=True)
    print(f"Wrote {OUT_HTML.name} (interactive)")

    # Static PNG for the thesis (via Kaleido + a local Chromium).
    fig.write_image(OUT_PNG, width=WIDTH, height=HEIGHT, scale=2)
    print(f"Wrote {OUT_PNG.name}")

    try:  # like plt.show(): open the interactive figure in a browser
        fig.show()
    except Exception as e:
        print(f"(could not open a browser tab: {e}; open {OUT_HTML} manually)")


if __name__ == "__main__":
    main()
