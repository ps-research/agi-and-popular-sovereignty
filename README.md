# Popular Sovereignty in the Age of AGI

Figure-reproduction code for the paper *Popular Sovereignty in the Age of AGI*, which
introduces the **dispensability framework**, the eight trajectory archetypes, and
the dispensability trap.

This repository contains the scripts that generate every figure in the paper from
the published dataset on Zenodo. It does **not** contain the simulation model itself
— that will be released as a Julia package (`TheDispensabilityGame.jl`) at paper
acceptance.

## Data

This work uses the **AGI Game — Grand Parameter Sweep Dataset**, archived on Zenodo
with a persistent DOI:

- **Concept DOI** (always latest): [10.5281/zenodo.20259914](https://doi.org/10.5281/zenodo.20259914)
- **Version DOI** (v1.0.0): [10.5281/zenodo.20259915](https://doi.org/10.5281/zenodo.20259915)
- License: CC-BY-4.0

The dataset (1.57 GB compressed) holds 31,944 per-configuration simulation outputs
plus derived analytical tables. Running `make data` (or `make all`) downloads and
unpacks it automatically.

## Quick start

```bash
git clone https://github.com/ps-research/agi-and-popular-sovereignty.git
cd agi-and-popular-sovereignty
julia --project=. -e 'using Pkg; Pkg.instantiate()'
make all
```

That downloads the dataset (~2 min), unpacks it (~30 s), and generates all 7
figures into `figures/<name>/` (PDF + 600 DPI PNG + JSON metadata). Total time
on a 32-thread machine: ~3 minutes.

## Per-figure commands

`make <stem>` regenerates a single figure. The stem is the experiment filename
without the `.jl` extension:

| Make target | Figure | Description |
|---|---|---|
| `01_fig1_1_two_family_Lt` | Fig 1.1 | Two-family L(t) overlay across 8 trajectory exemplars |
| `02_fig1_2_MR_leverage_heatmap` | Fig 1.2 | Mean final leverage over (M, R) with dominant trajectory codes |
| `03_fig1_3_trajectory_tilemap` | Fig 1.3 | Trajectory landscape on (O, E) per M (small multiples) |
| `04_fig1_4_score_margin_map` | Fig 1.4 | Classification ambiguity heatmap per M |
| `05_fig1_5_two_stage_erosion_dumbbell` | Fig 1.5 | Per-trajectory L̄(0)→L̄(100) dumbbell |
| `06_fig1_6_kappa_components_GM` | Fig 1.6 | κ component evolution for Governed Multipolarity |
| `07_table_1_7_decline_modes` | Table 1 | Two-phase decline characteristics (PDF + LaTeX + CSV) |

## Repository layout

```
.
├── README.md                 (this file)
├── LICENSE                   (MIT — code)
├── Project.toml              (Julia dependencies)
├── Makefile                  (master runner)
├── data/
│   ├── fetch.sh              (downloads + verifies Zenodo dataset)
│   └── sweep_results/        (populated by fetch.sh — gitignored)
├── lib/
│   └── figures_lib.jl        (shared palette, theme, CSV/TS loaders)
├── experiments/
│   └── 0X_*.jl               (one script per figure)
└── figures/                  (generated output — gitignored)
```


## Reproducibility

Continuous integration runs `make all` on every push and uploads the regenerated
figures as a build artifact, so the green ✓ on the latest commit is evidence that
the dataset → figures pipeline still works on a clean Ubuntu machine. See the
[Actions tab](https://github.com/ps-research/agi-and-popular-sovereignty/actions).

The simulation code that produced the dataset is currently held in a private
repository pending paper acceptance. Once accepted, it will be released as the
`TheDispensabilityGame.jl` Julia package; this repository will be updated to
declare a dependency on the published package version.

## License

- **Code** (this repository, Project.toml, Makefile, fetch.sh, experiments, lib):
  MIT (see `LICENSE`).
- **Figures and data**: CC-BY-4.0, inherited from the Zenodo dataset license.
  Cite the dataset DOI when reusing.

---

Built with [Claude Code](https://claude.ai/code) using Claude Opus 4.7 (1M context).
