using CairoMakie

function plot_spins(COORDS::Vector{SVector{3, Float64}}, SPINS::Vector{SVector{3, Float64}},H::Float64, D::Float64)
    spin_scale = 2
    # Convertimos a matrices solo para el plot
    P = stack(COORDS)'
    S = stack(SPINS)'

    fig = Figure(size = (800, 600))
    ax = Axis(fig[1, 1], title = "MC Skyrmions (StaticArrays)")

    arrows_plot = arrows!(
        ax,
        P[:, 1], P[:, 2], P[:, 3],
        S[:, 1], S[:, 2], S[:, 3];
        color = S[:, 3],
        colormap = :rainbow,
        lengthscale = spin_scale,
        shaftradius = 0.2, tipradius = 0.5, tiplength = 1
    )

    Colorbar(fig[1, 2], arrows_plot, label = "S_z")

    ax.aspect = DataAspect()

    ax.title = @sprintf("H = %.2f, D = %.2f", H, D)
    return fig
end
