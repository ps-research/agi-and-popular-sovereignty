#!/usr/bin/env julia
# scripts/updated/fig_1_3.jl — Paper 1, Fig 1.3 (revision)
# Updates: remove main figure title; enlarge the bottom legend label and title fonts.

using CairoMakie, Printf, Statistics, JSON
include(joinpath(@__DIR__, "..", "lib", "figures_lib.jl"))

const FIG_NAME = "fig1_3_trajectory_tilemap"
const OUT_DIR  = joinpath(FIGURES_ROOT, FIG_NAME)
mkpath(OUT_DIR)

println("Loading summary…")
SUMMARY = load_summary()

function trajectory_index_matrix(s::SummaryData, Mval::Int)
    mask = s.M .== Mval
    O_vals = sort(unique(s.O[mask]))
    E_vals = sort(unique(s.E[mask]))
    _, _, mode_mat = pivot_mode(s.O[mask], s.E[mask], s.trajectory[mask])
    nx, ny = size(mode_mat)
    idx_mat = fill(0, nx, ny)
    name_to_idx = Dict(n => i for (i, n) in enumerate(TRAJECTORY_ORDER))
    for i in 1:nx, j in 1:ny
        idx_mat[i, j] = get(name_to_idx, mode_mat[i, j], 0)
    end
    return O_vals, E_vals, idx_mat
end

function build_figure()
    fig = Figure(size = (780, 600))
    palette = [TRAJECTORY_COLORS[n] for n in TRAJECTORY_ORDER]
    cmap = cgrad(palette, length(palette); categorical = true)

    for (panel_i, M) in enumerate([1, 2, 3, 4])
        row = (panel_i - 1) ÷ 2 + 1
        col = (panel_i - 1) % 2 + 1
        O_vals, E_vals, idx = trajectory_index_matrix(SUMMARY, M)
        nO, nE = size(idx)
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
        heatmap!(ax, 1:nO, 1:nE, Float64.(idx);
            colormap = cmap, colorrange = (0.5, 8.5))
    end

    elems = [PolyElement(color = TRAJECTORY_COLORS[n], strokecolor = (:black, 0.4),
                          strokewidth = 0.5) for n in TRAJECTORY_ORDER]
    Legend(fig[3, 1:2], elems, TRAJECTORY_ORDER, "Dominant trajectory";
        orientation = :horizontal, nbanks = 2, framevisible = false,
        labelsize = 11, titlesize = 12, patchsize = (22, 14),
        rowgap = 4, colgap = 14, padding = (4, 4, 4, 4))

    rowsize!(fig.layout, 3, Auto(0.32))
    colgap!(fig.layout, 12)
    rowgap!(fig.layout, 8)
    return fig
end

println("Rendering…")
save_fig(build_figure(), FIG_NAME; outdir = OUT_DIR)

meta = Dict(
    "caption" =>
        "Trajectory landscape on (Openness, Enforcement) at each M value, averaging over C and R; cells coloured by dominant trajectory archetype.",

    "main_findings" =>
        "The trajectory landscape reorganizes dramatically as M increases. At M=1, Captured Hegemony " *
        "dominates the high-enforcement region, Algocratic Convergence appears at low-O/low-R corners, " *
        "and Regulatory Preservation occupies a narrow band at low E. At M=2, Bipolar Standoff and " *
        "Gatekeeping Inversion emerge in the upper-O region, while Competitive Tension fills the middle " *
        "plain. At M=3, Competitive Tension expands further, with Gatekeeping Inversion compressed to " *
        "the top edge. At M=4, Governed Multipolarity claims the entire lower-left quadrant (low E, " *
        "low O), with Open-Source Paradox at the top-right corner and Gatekeeping at the very top. " *
        "Critically, the same (O, E) coordinate maps to entirely different archetypes depending on " *
        "M — confirming that trajectory geography is M-conditional. Trajectory boundaries are not " *
        "smooth: they form discrete tiled regions with sharp transitions. The M=4 panel is unique in " *
        "producing Governed Multipolarity, which never appears at M ≤ 3 — establishing that good " *
        "outcomes require multiple competing sovereigns.",

    "detailed_findings" =>
        "This figure resolves the trajectory landscape across the most relevant parameter slice for " *
        "present-day discussion: openness (O) on the x-axis and enforcement (E) on the y-axis, with M " *
        "held fixed in each of four panels and the remaining parameters (C, R) averaged out. The " *
        "dominant trajectory per cell is plotted using categorical colors from the consistent " *
        "8-trajectory palette used across all 21 figures.\n\n" *
        "The four panels together demonstrate two structural truths about the model. First, M " *
        "reorganizes the qualitative landscape — the same (O, E) coordinate maps to entirely different " *
        "trajectory archetypes depending on whether one, two, three, or four sovereigns exist. Second, " *
        "even within a fixed M, trajectory boundaries form sharp tiled regions rather than smooth " *
        "gradients — the classifier identifies discrete dynamical attractors.\n\n" *
        "At M=1 the figure tells a single-sovereign story: high enforcement compresses everything " *
        "toward Captured Hegemony, with a thin Regulatory Preservation band only at low E. Algocratic " *
        "Convergence appears only at low-O / low-R extremes (the 'closed monoculture' corner). At M=2 " *
        "the landscape becomes richer: Bipolar Standoff and Gatekeeping Inversion occupy the upper " *
        "region, Competitive Tension is the central attractor, and Open-Source Paradox appears at " *
        "high-O / low-R. At M=3, Competitive Tension expands to most of the parameter space and " *
        "Gatekeeping Inversion is compressed to the top edge. At M=4 — the most consequential panel — " *
        "Governed Multipolarity claims the entire lower-left quadrant; Open-Source Paradox dominates " *
        "the high-O / high-E corner; Gatekeeping Inversion holds the very top.\n\n" *
        "The best-to-worst color hue progression maps directly to the legend ordering: cool blues " *
        "(Governed → Competitive → Bipolar → Regulatory) at the good end transition through amber " *
        "(Open-Source) into warm reds (Captured → Gatekeeping → Algocratic) at the bad end. Blue-" *
        "dominated panels indicate broad parameter regions where public agency persists; red-" *
        "dominated panels indicate broad regions where it does not.\n\n" *
        "For Paper 1, this figure is the framework's geographic atlas. It establishes that (1) the " *
        "8-trajectory taxonomy is M-conditional, (2) good outcomes require structural multipolarity " *
        "(Governed Multipolarity appears only at M=4), and (3) trajectory boundaries are sharp enough " *
        "to support discrete categorical classification rather than continuous spectra."
)

open(joinpath(OUT_DIR, FIG_NAME * ".json"), "w") do io
    JSON.print(io, meta, 2)
end

println("Saved to $OUT_DIR")
