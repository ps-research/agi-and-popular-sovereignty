#!/usr/bin/env julia
# scripts/updated/fig_1_1.jl
# Paper 1, Fig 1.1 — Two-family L(t) overlay
# Updates from review:
#   - remove main figure title
#   - move "decline mode" legend from the bottom (horizontal) to under the
#     trajectory legend on the right (vertical)
#   - bump legend label/title font sizes for readability

using CairoMakie, Printf, Statistics, JSON
include(joinpath(@__DIR__, "..", "lib", "figures_lib.jl"))

const FIG_NAME = "fig1_1_two_family_Lt"
const OUT_DIR  = joinpath(FIGURES_ROOT, FIG_NAME)
mkpath(OUT_DIR)

println("Loading data…")
TS_BY_NAME = Dict{String, TS}()
for ex in EXEMPLARS
    TS_BY_NAME[ex.name] = load_ts(ex.M, ex.C, ex.O, ex.R, ex.E)
end

function build_figure()
    fig = Figure(size = (740, 400))
    ax = Axis(fig[1, 1];
        xlabel = "Timestep t",
        ylabel = "Mean leverage L̄(t)",
        xticks = 0:20:100,
        yticks = 0:0.1:1.0,
        limits = ((0, 100), (0.2, 1.0)),
        xlabelsize = 12, ylabelsize = 12,
        xticklabelsize = 10, yticklabelsize = 10,
    )

    for name in TRAJECTORY_ORDER
        ts = TS_BY_NAME[name]
        times, L = mean_series(ts, "leverage")
        ls = name in DECELERATING_TRAJECTORIES ? :dash : :solid
        lines!(ax, times, L;
            color = TRAJECTORY_COLORS[name],
            linewidth = 2.4,
            linestyle = ls,
            label = name)
    end

    # Coalition threshold
    hlines!(ax, [0.3]; color = (:gray30, 0.7), linestyle = :dot, linewidth = 1)
    text!(ax, 1.5, 0.31; text = "T_leverage = 0.30",
          color = (:gray30, 0.9), align = (:left, :bottom), fontsize = 10)

    # Stacked legends on the right
    gl = fig[1, 2] = GridLayout()
    Legend(gl[1, 1], ax, "Trajectory archetype";
        framevisible = false, labelsize = 10.5, titlesize = 11.5,
        patchsize = (26, 14), rowgap = 3,
        padding = (8, 6, 4, 4))

    elem_solid = LineElement(color = :black, linewidth = 2.2)
    elem_dash  = LineElement(color = :black, linewidth = 2.2, linestyle = :dash)
    Legend(gl[2, 1], [elem_solid, elem_dash],
        ["Accelerating", "Decelerating"], "Decline mode";
        framevisible = false, labelsize = 10.5, titlesize = 11.5,
        patchsize = (26, 14), rowgap = 3,
        padding = (8, 6, 4, 4))

    rowgap!(gl, 4)
    colgap!(fig.layout, 6)
    return fig
end

println("Rendering…")
fig = build_figure()
save_fig(fig, FIG_NAME; outdir = OUT_DIR)

# ─── Metadata ────────────────────────────────────────────────────────

meta = Dict(
    "caption" => "Mean leverage L̄(t) for eight trajectory exemplars over 100 timesteps; six accelerating (solid) vs. two decelerating (dashed) decline modes, with the T_leverage = 0.30 coalition threshold.",

    "main_findings" =>
        "The eight trajectory exemplars cluster into two qualitatively distinct decline modes. The six " *
        "accelerating trajectories (Governed Multipolarity, Competitive Tension, Bipolar Standoff, " *
        "Regulatory Preservation, Open-Source Paradox, Gatekeeping Inversion) begin at high leverage " *
        "(L̄(0) ≈ 0.74–0.97) and decline slowly at first, then accelerate — their late-phase rate is " *
        "2.1× to 3.6× their early-phase rate. The two decelerating trajectories (Captured Hegemony, " *
        "Algocratic Convergence) begin already suppressed at L̄(0) ≈ 0.58 because of maximum " *
        "enforcement (E=1.0); they decline rapidly in the first quarter and plateau by t ≈ 70. " *
        "Counter-intuitively, Governed Multipolarity has the largest total decline (range = 0.40) " *
        "despite being the 'best' archetype, because it starts highest. Only Open-Source Paradox and " *
        "Captured Hegemony terminate near the T_leverage = 0.30 coalition threshold within 100 " *
        "timesteps; all accelerating trajectories project to cross it on extrapolation. Decline mode " *
        "is governed by the initial governance posture, not by trajectory class — a structural rather " *
        "than emergent property.",

    "detailed_findings" =>
        "This figure provides the primary visual evidence for the paper's central claim that the eight " *
        "nominal trajectory archetypes resolve into two dynamical decline modes governed by the initial " *
        "enforcement-suppression baseline. Plotted is mean leverage L̄(t) across all simulated state " *
        "archetypes at each timestep, for the score-margin-best exemplar of each of the eight " *
        "trajectory classes (Algocratic Convergence is overridden to the canonical spec preset " *
        "M=1, C=1, O=0, R=0, E=1).\n\n" *
        "The bifurcation in L̄(0) — spanning 0.58 to 0.97 — is itself a methodological finding. It " *
        "demonstrates that the steady-state suppression formula (1 − 0.4·(1 − 0.5R)·E) takes effect at " *
        "initialization, before any capability evolution has occurred. Configurations with high E and " *
        "low R strip leverage from the unsuppressed baseline of ≈0.97 (computed from population × κ_0) " *
        "down to 0.58 immediately. Without this initialization adjustment, the simulation would show a " *
        "spurious cliff at t = 0 → 1 unrelated to dynamics; one of our model verifications confirms " *
        "the absence of such a cliff post-fix.\n\n" *
        "Once initialized correctly, the six accelerating trajectories show a smooth concave-down " *
        "shape: rate ≈ 0.001 per step over t ∈ [0, 25], rising to ≈ 0.003–0.004 by t ∈ [75, 100]. " *
        "This acceleration reflects compounding effects in the dispensability formula as κ evolves — " *
        "dot(d_i, κ) grows faster as κ approaches the inflection points of the underlying capability " *
        "dynamics, and once one dimension crosses the κ_s recursive threshold all dimensions amplify. " *
        "The two decelerating trajectories show the opposite shape (concave-up early decline followed " *
        "by plateau) because their starting baseline is already near the floor of what governance " *
        "permits — most of the loss is structural and instantaneous, and what remains is residual " *
        "capability gain that pushes L̄ down only slowly.\n\n" *
        "For Paper 1, this figure functions as the framework's empirical signature: the trajectory " *
        "typology is not arbitrary, each class has a predictable rate signature, and the two decline " *
        "modes provide a falsifiable structural distinction. The dashed-line group provides a useful " *
        "counter-example for naive 'monotone-decline' intuition — under maximum enforcement, the model " *
        "actually predicts a decelerating arc, with most of the agency loss locked in at t = 0. " *
        "The T_leverage = 0.30 horizontal line indicates where coalitions become formally non-viable " *
        "under the model's collective-action thresholds (Phase 7 of the simulation loop)."
)

open(joinpath(OUT_DIR, FIG_NAME * ".json"), "w") do io
    JSON.print(io, meta, 2)
end

println("Saved to $OUT_DIR")
println("  PDF:  $FIG_NAME.pdf")
println("  PNG:  $FIG_NAME.png")
println("  JSON: $FIG_NAME.json")
