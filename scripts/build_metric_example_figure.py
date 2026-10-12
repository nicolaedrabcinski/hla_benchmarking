# Builds figures/metric_example_D1_arcasHLA.png/.svg: a set-membership schematic for
# the correct/miscalled/novel/no-call outcome categories, using 4 real arcasHLA samples.
# Sample data sourced from datasets/{1,4}_gs.csv + results/standard/arcas_d{1,4}.csv
# (hardcoded below; not derived from the main scoring notebook, which this figure does
# not otherwise depend on). No-call example drawn from D4 because arcasHLA has zero
# no-calls at Locus A in D1 -- see BACKLOG.md's metric-example slide redesign note.
#
# Design: each slot is a gold-standard "orbit" (the sample's own synonymous-accession
# set) plus the predicted allele, connected by what actually happened --
#   correct:   arrow from the prediction into its own orbit ("matches")
#   miscalled: the prediction instead matches a small "elsewhere in D1" cluster, never
#              this sample's orbit -- visually distinguishes it from novel, below
#   novel:     the prediction sits alone with a starburst -- no set anywhere contains it
#   no_call:   a dashed empty placeholder, no orbit interaction at all
# This shows *why* each case is classified as it is (set membership) rather than just
# re-presenting the same gold-standard/predicted text pair in a different box style.
#
# Icons are vector-drawn (lines/circles/markers), not unicode glyphs: checkmark/cross/
# star/slash characters render through font-fallback with inconsistent baselines next
# to bold Latin text.
import math
import random
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Ellipse

for _p in fm.findSystemFonts():
    if "/lato/Lato-Regular.ttf" in _p or "/lato/Lato-Bold.ttf" in _p:
        fm.fontManager.addfont(_p)
plt.rcParams["font.family"] = ["Lato", "DejaVu Sans"]

COL = {
    "correct":   "#4CAF50",
    "miscalled": "#FF9800",
    "novel":     "#9C27B0",
    "no_call":   "#F44336",
}
NAVY = "#1a2332"
GRAY = "#6b7280"
LIGHT_BORDER = "#d9dce1"
LABEL = {
    "correct": "CORRECT",
    "miscalled": "MISCALLED",
    "novel": "NOVEL",
    "no_call": "NO-CALL",
}


def tint(hexcolor, frac=0.85):
    h = hexcolor.lstrip("#")
    r, g, b = (int(h[i:i+2], 16) for i in (0, 2, 4))
    r = int(r + (255 - r) * frac)
    g = int(g + (255 - g) * frac)
    b = int(b + (255 - b) * frac)
    return f"#{r:02x}{g:02x}{b:02x}"


def draw_icon(ax, cx, cy, r, kind, color):
    if kind == "correct":
        xs = [cx - 0.5*r, cx - 0.12*r, cx + 0.55*r]
        ys = [cy - 0.02*r, cy - 0.42*r, cy + 0.42*r]
        ax.plot(xs, ys, color=color, linewidth=2.2, solid_capstyle="round",
                 solid_joinstyle="round", zorder=5)
    elif kind == "miscalled":
        d = 0.42*r
        ax.plot([cx-d, cx+d], [cy-d, cy+d], color=color, linewidth=2.2, solid_capstyle="round", zorder=5)
        ax.plot([cx-d, cx+d], [cy+d, cy-d], color=color, linewidth=2.2, solid_capstyle="round", zorder=5)
    elif kind == "novel":
        ax.plot([cx], [cy], marker="*", markersize=r*1.9, markerfacecolor=color,
                 markeredgewidth=0, zorder=5)
    elif kind == "no_call":
        ring = Circle((cx, cy), r*0.62, facecolor="none", edgecolor=color, linewidth=2.0, zorder=5)
        ax.add_patch(ring)
        d = r*0.62*0.72
        ax.plot([cx-d, cx+d], [cy-d, cy+d], color=color, linewidth=2.0, solid_capstyle="round", zorder=5)


fig = plt.figure(figsize=(16, 10), dpi=150)
ax = fig.add_axes([0, 0, 1, 1])
ax.set_xlim(0, 1600)
ax.set_ylim(0, 1000)
ax.axis("off")
fig.patch.set_facecolor("white")

ax.text(30, 965, "How one prediction is scored (accuracy metric)",
        fontsize=27, fontweight="bold", color=NAVY, va="top")
ax.text(30, 927,
        "Each predicted allele either lands inside this sample's own gold-standard set, a\n"
        "different sample's set, or no set at all — one real sample per outcome, arcasHLA, 2-field.",
        fontsize=13, color=GRAY, va="top", linespacing=1.5)

gap = 26
x0, y0 = 24, 78
card_top = 818
card_w = (1600 - 2*x0 - gap) / 2
card_h = (card_top - y0 - gap) / 2

# Fixed seed: satellite-dot jitter within each orbit is cosmetic and must be
# reproducible across reruns (so diffs stay clean/no-op when nothing changed).
rng = random.Random(7)


def orbit_dots(ax, cx, cy, r, n, color):
    """n small unlabeled satellite dots on a ring, representing synonymous accessions."""
    angles = [2*math.pi*k/max(n, 1) + rng.uniform(-0.15, 0.15) for k in range(n)]
    for a in angles:
        px, py = cx + r*math.cos(a), cy + r*0.55*math.sin(a)
        ax.add_patch(Circle((px, py), 5.5, facecolor=color, edgecolor="none", zorder=3))


def draw_slot(ax, x0, w, ry, row_h, gs_label, n_syn, pred_label, outcome):
    oc = COL[outcome]
    orbit_cx = x0 + w*0.20
    orbit_r = min(72, row_h*0.42)

    ax.add_patch(Ellipse((orbit_cx, ry), orbit_r*2.3, orbit_r*1.25,
                          facecolor="#f4f5f7", edgecolor="#c9ccd1", linewidth=1.2,
                          linestyle=(0, (3, 2)), zorder=2))
    orbit_dots(ax, orbit_cx, ry, orbit_r, n_syn, "#cdd1d7")
    dot_color = COL["correct"] if outcome == "correct" else "#9aa0aa"
    ax.add_patch(Circle((orbit_cx, ry), 9, facecolor=dot_color, edgecolor="white", linewidth=1.3, zorder=4))
    ax.text(orbit_cx, ry - orbit_r*0.95, gs_label, fontsize=11.5, fontweight="bold", color=NAVY,
            ha="center", va="top", zorder=4)
    if n_syn:
        ax.text(orbit_cx, ry - orbit_r*0.95 - 16, f"+{n_syn} synonymous", fontsize=8.5, color=GRAY,
                ha="center", va="top", zorder=4)

    pred_cx = x0 + w*0.74
    if outcome == "no_call":
        ax.add_patch(Circle((pred_cx, ry), 11, facecolor="none", edgecolor=oc, linewidth=1.8,
                             linestyle=(0, (3, 2)), zorder=4))
        draw_icon(ax, pred_cx, ry, 8, outcome, oc)
        ax.text(pred_cx, ry-26, "no prediction", fontsize=10, color=oc, fontweight="bold",
                ha="center", va="top", zorder=4)
        return

    ax.add_patch(Circle((pred_cx, ry), 11, facecolor=tint(oc, 0.82), edgecolor=oc, linewidth=2.2, zorder=4))
    draw_icon(ax, pred_cx, ry, 7.5, outcome, oc)
    ax.text(pred_cx, ry+24, pred_label, fontsize=12.5, fontweight="bold", color=NAVY,
            ha="center", va="bottom", zorder=4)

    if outcome == "correct":
        ax.add_patch(FancyArrowPatch((pred_cx-11, ry), (orbit_cx+11, ry), arrowstyle="-|>",
                                      mutation_scale=14, linewidth=2, color=oc,
                                      connectionstyle="arc3,rad=-0.15", zorder=3))
        ax.text((pred_cx+orbit_cx)/2, ry+12, "matches", fontsize=8.5, color=oc, ha="center", zorder=4)
    elif outcome == "miscalled":
        # Dashed arrow curving AWAY, past the sample's own orbit, to a small
        # "elsewhere in cohort" cluster -- shows the allele is real, just not
        # a member of THIS sample's set (distinct from novel, below).
        else_cx, else_cy = orbit_cx + w*0.12, ry - row_h*0.33
        ax.add_patch(Ellipse((else_cx, else_cy), 70, 30, facecolor="#fdf1e0",
                              edgecolor="#e8c488", linewidth=1, zorder=2))
        ax.add_patch(Circle((else_cx, else_cy), 6, facecolor=oc, edgecolor="white", linewidth=1, zorder=4))
        ax.text(else_cx, else_cy-20, "elsewhere in D1", fontsize=8, color="#8a6d3b", ha="center", zorder=4)
        ax.add_patch(FancyArrowPatch((pred_cx-11, ry-4), (else_cx+14, else_cy+4), arrowstyle="-|>",
                                      mutation_scale=13, linewidth=1.8, color=oc, linestyle=(0, (4, 2)),
                                      connectionstyle="arc3,rad=0.25", zorder=3))
        ax.plot([orbit_cx, pred_cx-14], [ry, ry], color="#d9dce1", linewidth=1.2,
                linestyle=(0, (2, 3)), zorder=2)
        ax.text((orbit_cx+pred_cx)/2, ry-14, "≠ this sample", fontsize=8.5, color=GRAY, ha="center", zorder=4)
    elif outcome == "novel":
        for ang in range(0, 360, 45):
            a = math.radians(ang)
            x1, y1 = pred_cx+16*math.cos(a), ry+16*math.sin(a)
            x2, y2 = pred_cx+24*math.cos(a), ry+24*math.sin(a)
            ax.plot([x1, x2], [y1, y2], color=oc, linewidth=1.6, zorder=3)
        ax.text(pred_cx, ry-26, "no set contains it", fontsize=9, color=oc, ha="center", va="top", zorder=4)


def draw_card(cx0, cy0, w, h, category, sample, scope, slots):
    color = COL[category]
    ax.add_patch(FancyBboxPatch((cx0, cy0), w, h, boxstyle="round,pad=0,rounding_size=12",
                                 linewidth=1.3, edgecolor=LIGHT_BORDER, facecolor="white", zorder=1))
    head_h = 56
    ax.add_patch(FancyBboxPatch((cx0, cy0+h-head_h), w, head_h, boxstyle="round,pad=0,rounding_size=12",
                                 linewidth=0, facecolor=color, zorder=2))
    ax.add_patch(plt.Rectangle((cx0, cy0+h-head_h), w, head_h*0.45, facecolor=color, edgecolor="none", zorder=2))
    draw_icon(ax, cx0+32, cy0+h-head_h/2, 13*0.72, category, "white")
    ax.text(cx0+56, cy0+h-head_h/2, LABEL[category], fontsize=16.5, fontweight="bold", color="white",
            va="center", zorder=3)
    ax.text(cx0+w-22, cy0+h-head_h/2, f"{sample}   {scope}", fontsize=12, color="white",
            va="center", ha="right", zorder=3)

    n = len(slots)
    zone_top, zone_bot = cy0+h-head_h-10, cy0+20
    row_h = (zone_top-zone_bot)/n
    for i, (gs_label, n_syn, pred_label, outcome) in enumerate(slots):
        ry = zone_top - (i+0.5)*row_h
        draw_slot(ax, cx0+10, w-20, ry, row_h, gs_label, n_syn, pred_label, outcome)


draw_card(x0, y0+card_h+gap, card_w, card_h, "correct", "ERR188033", "Locus A, D1",
          [("A*01:01", 5, "A*01:01", "correct"), ("A*03:01", 5, "A*03:01", "correct")])
draw_card(x0+card_w+gap, y0+card_h+gap, card_w, card_h, "miscalled", "ERR204881", "Locus A, D1",
          [("A*02:01", 0, "A*02:01", "correct"), ("A*68:01:00", 0, "A*31:01", "miscalled")])
draw_card(x0, y0, card_w, card_h, "novel", "ERR188028", "Locus A, D1",
          [("A*02:01", 8, "A*02:864", "novel"), ("A*32:01:00", 0, "A*32:01", "correct")])
draw_card(x0+card_w+gap, y0, card_w, card_h, "no_call", "SRR5252835", "Locus DRB1, D4",
          [("DRB1*15:01", 0, "", "no_call"), ("DRB1*11:04", 0, "", "no_call")])

leg_y = 34
leg_items = [
    ("correct", "predicted allele is in the sample's own set"),
    ("miscalled", "predicted allele is real, but a member of a different sample's set"),
    ("novel", "predicted allele is a member of no gold-standard set at all"),
    ("no_call", "tool returned no prediction for the slot"),
]
col_x = [30, 824]
row_y = [leg_y+11, leg_y-11]
for idx, (cat, desc) in enumerate(leg_items):
    lx, ly = col_x[idx % 2], row_y[idx // 2]
    ax.add_patch(Circle((lx+7, ly), 9, facecolor=COL[cat], edgecolor="none", zorder=3))
    draw_icon(ax, lx+7, ly, 6.5, cat, "white")
    ax.text(lx+25, ly, f"{LABEL[cat].capitalize()} — {desc}", fontsize=9.7, color="#3d4451",
            va="center", zorder=3)

fig.savefig("figures/metric_example_D1_arcasHLA.png", facecolor="white")
fig.savefig("figures/metric_example_D1_arcasHLA.svg", facecolor="white")
print("done")
