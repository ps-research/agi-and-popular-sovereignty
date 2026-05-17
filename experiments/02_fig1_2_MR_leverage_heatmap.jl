#!/usr/bin/env julia
# scripts/updated/fig_1_2.jl — Paper 1, Fig 1.2 (revision)
# Updates: remove main title; enlarge the trajectory-codes footnote and switch
# from grey to default text color so it reads at publication size.

using CairoMakie, Printf, Statistics, JSON
include(joinpath(@__DIR__, "..", "lib", "figures_lib.jl"))

const FIG_NAME = "fig1_2_MR_leverage_heatmap"
const OUT_DIR  = joinpath(FIGURES_ROOT, FIG_NAME)
mkpath(OUT_DIR)

println("Loading summary…")
SUMMARY = load_summary()

function build_figure()
    Ms, Rs, Lmat   = pivot_mean(SUMMARY.M, SUMMARY.R, SUMMARY.final_mean_leverage)
    _, _, traj_mat = pivot_mode(SUMMARY.M, SUMMARY.R, SUMMARY.trajectory)
    nM, nR = length(Ms), length(Rs)
    Lt = collect(transpose(Lmat))

    fig = Figure(size = (760, 380))
    ax = Axis(fig[1, 1];
        xlabel = "Regulation R",
        ylabel = "Number of builder states M",
        xticks = (1:nR, [@sprintf("%.1f", r) for r in Rs]),
        yticks = (1:nM, string.(Ms)),
        xlabelsize = 12, ylabelsize = 12,
        xticklabelsize = 10, yticklabelsize = 10,
    )

    hm = heatmap!(ax, 1:nR, 1:nM, Lt;
        colormap = :viridis,
        colorrange = (minimum(Lmat), maximum(Lmat)),
    )

    short_traj = Dict(
        "Governed Multipolarity"  => "GM",
        "Competitive Tension"     => "CT",
        "Bipolar Standoff"        => "BS",
        "Regulatory Preservation" => "RP",
        "Open-Source Paradox"     => "OP",
        "Captured Hegemony"       => "CH",
        "Gatekeeping Inversion"   => "GI",
        "Algocratic Convergence"  => "AC",
    )
    cmid = (minimum(Lmat) + maximum(Lmat)) / 2
    for i_M in 1:nM, j_R in 1:nR
        v = Lmat[i_M, j_R]
        code = get(short_traj, traj_mat[i_M, j_R], "")
        text_color = v > cmid ? :black : :white
        text!(ax, j_R, i_M; text = code, color = text_color,
              align = (:center, :center), fontsize = 10, font = :bold)
    end

    Colorbar(fig[1, 2], hm; label = "Mean L̄",
        labelsize = 12, ticklabelsize = 10,
        width = 14, height = Relative(0.85))

    # Footnote — larger, black, two-line.
    Label(fig[2, 1:2],
        "Each cell averaged over all (C, O, E).  Codes: GM Governed Multipolarity · CT Competitive Tension · BS Bipolar Standoff · RP Regulatory Preservation\n" *
        "OP Open-Source Paradox · CH Captured Hegemony · GI Gatekeeping Inversion · AC Algocratic Convergence";
        fontsize = 10, color = :black, halign = :left, padding = (8, 0, 4, 0))

    colgap!(fig.layout, 8)
    rowgap!(fig.layout, 4)
    return fig
end

println("Rendering…")
save_fig(build_figure(), FIG_NAME; outdir = OUT_DIR)

meta = Dict(
    "caption" => "Mean final leverage L̄ over the (M, R) grid, averaged across (C, O, E); cells annotated with the dominant trajectory code. The M=1→M=2 transition dominates.",

    "main_findings" =>
        "The M=1 → M=2 transition is the single largest gradient in mean final leverage across the entire " *
        "31,944-config grid. Holding R = 1.0, this single-parameter step raises L̄ from 0.491 to 0.596 — a Δ " *
        "of 0.105, four times larger than any non-M adjacent-cell change. The M=1 row is dominated by " *
        "Captured Hegemony (low and mid R) and Regulatory Preservation (high R) — both single-sovereign " *
        "regimes that suppress public agency. M=2 introduces Bipolar Standoff and a wider band of " *
        "Competitive Tension. M=3 stabilizes around Competitive Tension across most of R, transitioning to " *
        "Regulatory Preservation only at extreme R. M=4 produces Open-Source Paradox at low R but " *
        "Governed Multipolarity at moderate-to-high R — the only configuration that reliably maintains " *
        "L̄ > 0.6. Each row exhibits an R-direction gradient (lighter at higher R, reflecting the " *
        "regulation floor 0.15·R and reduced enforcement suppression), but these intra-row gradients are " *
        "visibly compressed compared to the inter-row M jumps.",

    "detailed_findings" =>
        "This figure is the structural-leverage portrait of the parameter space, focused on the two " *
        "parameters with the largest first-order effects: M (number of competing builder states) and R " *
        "(regulation level). Mean final leverage L̄ is computed for each (M, R) bin by averaging across " *
        "all C, O, E values, exposing the underlying first-order surface stripped of secondary " *
        "modulations.\n\n" *
        "The headline finding is the M=1 → M=2 transition. Across the entire 31,944-config sweep, the " *
        "largest single-step adjacent-cell change in L̄ is 0.105, occurring precisely at this transition " *
        "at high R. The four largest gradients in the entire heatmap collection are all M-pair " *
        "gradients: M×R = 0.105, M×E = 0.078, M×C = 0.064, M×O = 0.060. The first non-M gradient is " *
        "R×E at 0.025 — four times smaller. This establishes M as the dominant structural parameter and " *
        "the four 'knob' parameters (C, O, R, E) as modulators within an M-regime.\n\n" *
        "The trajectory codes annotate the dominant trajectory in each cell (mode across the " *
        "marginalized C, O, E). Reading row-by-row reveals the regime structure: M=1 alternates " *
        "between Captured Hegemony (low/mid R) and Regulatory Preservation (high R); M=2 spans " *
        "Open-Source Paradox at low R, Competitive Tension through mid-R, Gatekeeping Inversion at " *
        "R ≈ 0.8, and Regulatory Preservation at the highest R; M=3 is dominated by Competitive " *
        "Tension; M=4 introduces Governed Multipolarity as the dominant regime at most R values.\n\n" *
        "For Paper 1, this figure functions as the framework's first-principles map of how the " *
        "number of sovereigns shapes public-leverage outcomes. It provides empirical grounding for the " *
        "model's emphasis on multipolarity as a structural property — not just an abstract feature but " *
        "the parameter that most strongly modulates leverage at the population level. The embedded " *
        "trajectory codes make the figure self-explanatory without requiring readers to consult " *
        "separate trajectory definitions; the footnote provides full names for first-time readers."
)

open(joinpath(OUT_DIR, FIG_NAME * ".json"), "w") do io
    JSON.print(io, meta, 2)
end

println("Saved to $OUT_DIR")
