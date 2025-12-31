using LinearAlgebra
using CairoMakie
using DelimitedFiles
using StaticArrays

include("src/mc_structure.jl")
include("src/mc_neighbors.jl")
include("src/mc_plots.jl")
include("src/mc_params.jl")

# Calculo de coordenadas fraccionarias
frac_coords = get_frac_coords(basis_frac, N)
writedlm("data/frac_coords.txt", frac_coords)

# Calculo de coordenadas reales(cartesianas)
coords = [superlattice_matrix * c for c in frac_coords]
writedlm("data/coords.txt", coords)

# Busqueda de vecinos
@time neighbor_shells = analyze_neighbors_pbc(frac_coords, superlattice_matrix, ranges)

# Guardado de vecinos en archivos por nivel
for i in 1:length(ranges)
    writedlm("data/neighbors$i.txt", neighbor_shells[i])
end

# Generamos el grafico de red
fig = plot_red(coords)

# Guardamos el grafico
save("data/red.png", fig)

display(fig)