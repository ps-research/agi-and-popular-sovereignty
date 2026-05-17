#!/usr/bin/env julia
# scripts/updated/fig_1_4.jl — Paper 1, Fig 1.4 (revision)
# Update: remove the main figure title.

using CairoMakie, Printf, Statistics, JSON
include(joinpath(@__DIR__, "..", "lib", "figures_lib.jl"))

const FIG_NAME = "fig1_4_score_margin_map"
const OUT_DIR  = joinpath(FIGURES_ROOT, FIG_NAME)
mkpath(OUT_DIR)

println("Loading summary…")
SUMMARY = load_summary()

function build_figure()
    fig = Figure(size = (780, 540))

    all_mats = Dict{Int, Tuple{Vector{Float64}, Vector{Float64}, Matrix{Float64}}}()
    for M in [1, 2, 3, 4]
        mask = SUMMARY.M .== M
        O_vals, E_vals, mat = pivot_mean(SUMMARY.O[mask], SUMMARY.E[mask], SUMMARY.score_margin[mask])
        all_mats[M] = (O_vals, E_vals, mat)
    end
    gmin = minimum(minimum(m) for m in [v[3] for v in values(all_mats)])
    gmax = maximum(maximum(m) for m in [v[3] for v in values(all_mats)])

    last_hm = nothing
    for (panel_i, M) in enumerate([1, 2, 3, 4])
        row = (panel_i - 1) ÷ 2 + 1
        col = (panel_i - 1) % 2 + 1
        O_vals, E_vals, mat = all_mats[M]
        nO, nE = size(mat)
        ax = Axis(fig[row, col];
            xlabel = row == 2 ? "Openness O" : "",
            ylabel = col == 1 ? "Enforcement E" : "",
            title  = "M = $M",
            titlesize = 12,
            xticks = (1:nO, [@sprintf("%.1f", o) for o in O_vals]),
            yticks = (1:nE, [@sprintf("%.1f", e) for e in E_vals]),
            xlabelsize = 11, ylabelsize = 11,
            xticklabelsize = 9, yticklabelsize = 9,
        )
        if row == 1; ax.xticklabelsvisible = false; end
        if col == 2; ax.yticklabelsvisible = false; end
        last_hm = heatmap!(ax, 1:nO, 1:nE, mat;
            colormap = :viridis, colorrange = (gmin, gmax))
    end

    Colorbar(fig[1:2, 3], last_hm;
        label = "Mean score margin (winner − runner-up)",
        labelsize = 11, ticklabelsize = 9,
        height = Relative(0.85), width = 14)

    colgap!(fig.layout, 10)
    rowgap!(fig.layout, 8)
    return fig
end

println("Rendering…")
save_fig(build_figure(), FIG_NAME; outdir = OUT_DIR)

meta = Dict(
    "caption" =>
        "Mean classification score margin over (Openness, Enforcement) at each M; bright = unambiguous classification, dark = boundary regions where trajectories are nearly tied.",

    "main_findings" =>
        "Score margin reveals where the classifier is confident vs. torn. Dark bands trace trajectory " *
        "boundaries; bright interiors mark unambiguous trajectory cores. The M=1 panel shows the " *
        "cleanest interior (high margin throughout the Captured Hegemony region), reflecting that " *
        "single-sovereign regimes are dynamically distinct. M=2 and M=3 panels show thin dark valleys " *
        "running diagonally — these are the Competitive Tension ↔ Bipolar Standoff and Competitive " *
        "Tension ↔ Regulatory Preservation boundaries. M=4 shows the most fragmented landscape, with " *
        "multiple boundary intersections in the upper-right region (Governed Multipolarity ↔ " *
        "Open-Source Paradox ↔ Gatekeeping Inversion). Across all panels, 40.77% of the 31,944 " *
        "configurations have score_margin < 0.05 — meaning the classifier is nearly tied between two " *
        "trajectories. The top symmetric boundary pairs are Gov ↔ Reg Preservation (2,465 configs) " *
        "and Alg ↔ Cap Hegemony (1,500), suggesting these pairs may be quasi-equivalent dynamical " *
        "attractors with different parameter labels rather than distinct mechanisms.",

    "detailed_findings" =>
        "This figure quantifies the classifier's certainty across the parameter space, complementing " *
        "the categorical map of Fig 1.3. For each configuration, score_margin = trajectory_score − " *
        "runner_up_score, computed during the trajectory classification step. Low margin (dark in the " *
        "heatmap) indicates the classifier is nearly tied between the winning trajectory and the " *
        "next-best alternative — the configuration sits on a boundary in the dynamical landscape.\n\n" *
        "Substantively, dark bands trace the dynamical adjacency structure. Trajectories that border " *
        "each other in (O, E) at fixed M are dynamically nearby — small parameter changes can flip " *
        "the classification. M=1 has a single thick band at low E (Captured Hegemony ↔ Regulatory " *
        "Preservation transition). M=2 and M=3 show multiple thin valleys: Competitive Tension borders " *
        "Bipolar Standoff in the mid-O region and Regulatory Preservation along the low-E edge. M=4 " *
        "is the most fragmented, with three-way intersections in the upper-right.\n\n" *
        "Methodologically, the abundance of dark cells is a warning sign for the 8-trajectory " *
        "taxonomy. 40.77% of the entire 31,944-config sweep has score_margin < 0.05. The top " *
        "symmetric confusion pairs are Gov ↔ Reg (2,465 configs) and Alg ↔ Cap (1,500). These pairs " *
        "likely represent quasi-equivalent dynamical attractors: similar L̄, similar κ trajectories, " *
        "similar coalition dynamics — but different (M, R, E) settings that hit the model's scoring " *
        "functions slightly differently.\n\n" *
        "For Paper 1, this figure complements the categorical taxonomy with an honest map of " *
        "classification uncertainty. It supports the framework while exposing its limits: the " *
        "8-trajectory schema is useful but should be read with awareness that many configurations " *
        "are boundary cases. A more parsimonious taxonomy of ~6 attractors (collapsing Gov+Reg and " *
        "Alg+Cap pairs) may better capture the true dynamical structure."
)

open(joinpath(OUT_DIR, FIG_NAME * ".json"), "w") do io
    JSON.print(io, meta, 2)
end

println("Saved to $OUT_DIR")
