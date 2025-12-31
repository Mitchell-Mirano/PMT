using CairoMakie
using Printf
using StaticArrays



function plot_red(coords::Vector{SVector{3, Float64}})
    x = [c[1] for c in coords]
    y = [c[2] for c in coords]


    fig = Figure(size = (1600, 900), backgroundcolor = :white)

    ax1 = Axis(
        fig[1, 1],
        aspect = DataAspect(),
        title = "Supercelda con Padding de Red",
        xgridvisible = true,
        ygridvisible = true,
        # Ajuste de márgenes automáticos (proporcional al rango)
        xautolimitmargin = (0.1, 0.1),
        yautolimitmargin = (0.1, 0.1)
    )

    # Visualización
    scatter!(ax1, x, y, 
        color = :dodgerblue, 
        markersize = 15, 
        strokewidth = 1, 
        strokecolor = :black
    )

    labels = ["$i" for i in 1:length(x)]
    text!(ax1, x, y; 
        text = labels, 
        align = (:center, :top), 
        offset = (0, -12),
        fontsize = 10
    )

    return fig
end


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
