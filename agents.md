# Agent Handoff: five-bolt-chain-guard

This document is written for an AI agent (or future human) picking up this project cold. It contains everything needed to write the OpenSCAD source, export the print files, and complete the documentation — without needing the original human present.

---

## Mission

Create a complete, print-ready 5-bolt chain guard for trekking bikes. Mirror the structure and quality of the existing four-bolt-chain-guard project in the sibling directory. The end state should match the four-bolt project's file inventory exactly, with all specs updated for the 5-bolt trekking context.

---

## Repository Layout

```
cad-designs/
├── four-bolt-chain-guard/        ← REFERENCE IMPLEMENTATION (complete)
│   ├── four-bolt-chain-guard.scad
│   ├── four-bolt-chain-guard.stl
│   ├── four-bolt-chain-guard.3mf
│   ├── images/
│   │   └── four-bolt-chain-guard.png
│   ├── scad-code.txt             ← identical copy of .scad, for plain-text readers
│   ├── README.md
│   └── LICENSE
└── five-bolt-chain-guard/        ← THIS PROJECT (in progress)
    ├── README.md                 ← written, version 0.1
    ├── agents.md                 ← this file
    └── LICENSE                   ← MIT, 2026, already correct
```

### Files still to create

- `five-bolt-chain-guard.scad`
- `five-bolt-chain-guard.stl` (exported from OpenSCAD by human)
- `five-bolt-chain-guard.3mf` (exported from OpenSCAD by human)
- `images/five-bolt-chain-guard.png` (screenshot from OpenSCAD by human)
- `scad-code.txt` (exact copy of final .scad content)

---

## Reference: Four-Bolt Source Code

The four-bolt source is at `../four-bolt-chain-guard/four-bolt-chain-guard.scad`. Read it before writing anything. The five-bolt `.scad` is a parametric adaptation of that file — not a rewrite from scratch.

Key structural logic in the four-bolt source:
- **Two concentric rings** built with `difference()` of two cylinders
- **N struts** in a `for` loop at `i * 360/num_struts` degree intervals, each strut = two parallel 5mm `cube()` walls with 8mm gap
- **Between each adjacent pair of struts** (second `for` loop): X-brace diagonals using `hull()` between computed wall endpoints, outer chord connector, and mid-angle radial strut
- All geometry is fully parametric — changing `num_struts` is the primary lever

---

## Design Decisions

### Confirmed

| Parameter | Value | Rationale |
|---|---|---|
| `num_struts` | 5 | Defines 5-bolt geometry |
| `thickness` | 5mm | Same as 4-bolt — proven adequate |
| `ring_thickness` | 5mm | Same as 4-bolt |
| `bolt_diameter` | 8mm | M8 replacement bolts, same mounting approach as 4-bolt |
| `connector_thickness` | 5mm | Same strut wall thickness as 4-bolt |
| `inner_rim_diameter` | 120mm | **Measured**: crankset body extends 60mm from center axis — inner hole must be ≥ 120mm diameter |
| `$fn` | 100 | Same render quality |

### Estimated (verify before finalizing)

| Parameter | Estimated Value | Notes |
|---|---|---|
| `outer_rim_diameter` | 220mm | **Measured**: teeth at 105mm from center. Guard outer edge at 110mm radius = 220mm diameter gives full coverage. |
| BCD target | 130mm only | See BCD constraint note below. |

### BCD constraint — critical

The large inner diameter (120mm) is driven by the bulky crankset central body, which extends 60mm from the center axis. This has a hard consequence for BCD compatibility:

```
inner_ring_outer = inner_rim_diameter/2 + ring_thickness = 60 + 5 = 65mm
```

Bolt holes must sit at radius ≥ 65mm to be reachable by the strut channels. This means:

- BCD 104mm → bolt at radius 52mm ✗ blocked by inner ring
- BCD 110mm → bolt at radius 55mm ✗ blocked by inner ring
- BCD 130mm → bolt at radius 65mm ✓ sits right at the inner ring edge

**This design targets 130mm BCD only.** This is the standard for classic Shimano Trekking cranksets (FC-T521, FC-T431, FC-T4060) and older road/touring cranks. The wider BCD range stated in earlier planning is not achievable with this inner diameter.

### Open questions (ask human before coding if uncertain)

1. **Bolt spec**: Confirm M8 replacement bolt approach vs. M5 passthrough slots for existing chainring bolts. If the human wants to reuse existing Shimano chainring bolts (M5 hollow bolt system), `bolt_diameter` must be 5, not 8.
2. **Front derailleur**: Does the target trekking bike have a front derailleur? If yes, the guard must not block cable path — may affect outer diameter ceiling.

---

## Geometry: 4-bolt vs 5-bolt

| Property | 4-bolt | 5-bolt |
|---|---|---|
| Strut angles | 0°, 90°, 180°, 270° | 0°, 72°, 144°, 216°, 288° |
| Inter-strut gap | 90° | 72° |
| Mid-angle offset | 45° | 36° |
| X-brace count | 4 pairs | 5 pairs |
| Chord connectors | 4 | 5 |
| Mid-radial struts | 4 | 5 |

The second `for` loop in the four-bolt code already uses `angle1`, `angle2`, and `mid_angle` derived from `num_struts` — so it is already generic. Changing `num_struts = 4` to `num_struts = 5` is the primary change. The X-brace angles will be steeper (72° gap vs 90°), but the geometry is still valid.

### Strut slot length

In the four-bolt design, the strut walls span from `inner_ring_outer` to `outer_ring_inner`. This is the radial range available for bolt travel. For the five-bolt with confirmed dimensions:

```
inner_ring_outer = inner_rim_diameter/2 + ring_thickness = 60 + 5 = 65mm
outer_ring_inner = outer_rim_diameter/2 - ring_thickness = 110 - 5 = 105mm
```

BCD 130mm → bolt at radius 65mm ✓ (sits exactly at the inner ring edge — tight but valid)

The slot spans 65mm–105mm radially. The only target BCD is 130mm. There is no useful radial adjustment range — the bolt sits near the inner end of the slot. This is functional but worth noting: the "universal" slot feature of the four-bolt design is not a benefit here.

---

## Footguns

**1. Outer diameter too small**
190mm (the 4-bolt value) is not enough for a trekking bike. Use 220mm — teeth are measured at 105mm from the center. Getting this wrong means the printed part doesn't guard the chain/ring interface at all.

**2. Inner diameter too small — crankset body collision**
The crankset on the target bike has a large, bulky central body that extends 60mm from the center axis. The inner hole must be at least 120mm diameter. If `inner_rim_diameter` is copied from the four-bolt value of 70mm, the guard will physically collide with the crankset and cannot be installed. Do not reduce this value.

**3. Bolt diameter wrong for chainring bolt type**
Many trekking chainring bolts are M5 Shimano-style hollow bolt+nut sets, not M8. If the intent is to reuse existing bolts, `bolt_diameter = 8` makes the channel too wide and the bolt won't clamp. The four-bolt design uses M8 as *replacement* bolts — confirm this is also the intent here.

**4. X-brace visual inspection required**
At 72° inter-strut spacing, the diagonal hull() connections produce steeper angles than in the 4-bolt. The code will render without errors but the bracing may look visually off or create thin/weak cross-sections. Always open the rendered model in OpenSCAD and rotate it before exporting.

**5. scad-code.txt must be an exact copy**
After finalizing the .scad, copy its content verbatim into scad-code.txt. Do not summarize or reformat. The four-bolt repo has both files and they are identical — maintain that convention.

**6. Do not use inner_ring_outer as a named variable before it is defined**
OpenSCAD is parsed top-to-bottom for variable assignments. The four-bolt source defines `inner_ring_outer` and `outer_ring_inner` after the basic parameters. Keep the same order to avoid undefined variable errors.

**7. README image section**
The README.md currently has the image tag commented out. Uncomment it and add the actual image path once `images/five-bolt-chain-guard.png` exists.

**8. README status checklist**
The README.md has a status checklist (5 checkboxes). Update each item to `[x]` as work completes. Do not leave all boxes unchecked in the final release.

---

## Step-by-Step Instructions for the Coding Agent

### Step 1 — Confirm open questions
Before writing code, check with the human:
- Bolt spec: M8 replacement or M5 passthrough (outer/inner diameters are now confirmed by measurement)

### Step 2 — Write `five-bolt-chain-guard.scad`
- Copy the four-bolt source as a structural reference
- Change `num_struts = 4` → `num_struts = 5`
- Set `outer_rim_diameter = 220` (teeth at 105mm, confirmed by measurement)
- Set `inner_rim_diameter = 120` (crankset body at 60mm radius, confirmed by measurement)
- Update `bolt_diameter` if M5 is chosen
- Update the header comment block (title, bolt count, bike type)
- Update the inline comment `// for square pattern` → `// for 5-bolt pattern`
- Do NOT change the structural geometry logic — it is already generic

### Step 3 — Verify in OpenSCAD
Open the file in OpenSCAD and check:
- [ ] 5 struts visible, evenly spaced at 72°
- [ ] Each strut has two parallel walls with a gap
- [ ] 5 sets of inter-strut bracing (X-brace + chord + mid-radial)
- [ ] Inner and outer rings are solid and continuous
- [ ] No geometry floats disconnected from the main body
- [ ] The model looks symmetric from all angles

### Step 4 — Export files (human action required)
The following must be done by the human in OpenSCAD:
1. File → Export → Export as STL → `five-bolt-chain-guard.stl`
2. File → Export → Export as 3MF → `five-bolt-chain-guard.3mf`
3. View → Screenshot → save to `images/five-bolt-chain-guard.png`

### Step 5 — Create `scad-code.txt`
Copy the exact content of `five-bolt-chain-guard.scad` into a new file `scad-code.txt`. No changes.

### Step 6 — Update README.md
- Uncomment the image tag in the Design Details section
- Update the specs table with confirmed values (remove *(est.)* markers)
- Tick off completed items in the status checklist
- Update version from `0.1 (design phase)` to `1.0`

---

## Verification Checklist (Definition of Done)

- [ ] `five-bolt-chain-guard.scad` exists and renders without errors
- [ ] Model has exactly 5 struts at 72° spacing
- [ ] BCD slot covers 104–130mm (bolt travels from r=52mm to r=65mm within the channel)
- [ ] `five-bolt-chain-guard.stl` exported
- [ ] `five-bolt-chain-guard.3mf` exported
- [ ] `images/five-bolt-chain-guard.png` saved
- [ ] `scad-code.txt` matches `.scad` exactly
- [ ] `README.md` updated with final specs, image uncommented, checklist ticked
- [ ] All 7 files present (scad, stl, 3mf, png, scad-code.txt, README.md, LICENSE)

---

## Related Files

- Reference implementation: `../four-bolt-chain-guard/four-bolt-chain-guard.scad`
- This project's README: `./README.md`
- License: `./LICENSE` (MIT, 2026, Dominik Braun — already correct, do not modify)
