using Random
using DelimitedFiles
using LinearAlgebra
using StaticArrays
using CairoMakie
using Printf
using Base.Threads

include("src/mc_spins.jl")
include("src/mc_vectors.jl")
include("src/mc_hamiltonian.jl")
include("src/mc_data.jl")
include("src/mc_metropolis.jl")
include("src/mc_sim.jl")
include("src/mc_plots.jl")
include("src/mc_params.jl")



# Lectura de datos
POS = to_svec(readdlm("data/coords.txt", Float64))
FRAC_POS = to_svec(readdlm("data/frac_coords.txt", Float64))
NN1 = to_svec(readdlm("data/neighbors1.txt", Int))
NN2 = to_svec(readdlm("data/neighbors2.txt", Int))
NN3 = to_svec(readdlm("data/neighbors3.txt", Int))


# Calculo de vectores  DMI
D_ij = [get_DM_vectors(FRAC_POS, NN2[i], superlattice_matrix, i) for i in 1:length(POS)]

# ## Simnulacion con parámetros fijos
# SPINS = [random_unit_vector() for _ in 1:length(POS)]

# D = 0.33
# H = 4.0
# @time monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
# fig = plot_spins(POS, SPINS, H, D)
# display(fig)



# Simulación con parámetros variados

params = [(H, D) for H in H_range, D in D_range]

start_time = time()

@threads for (H,D) in params
    SPINS = [random_unit_vector() for _ in 1:length(POS)]
    monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
    writedlm("results/spins/H($(H))_D($(D)).txt", SPINS)
end

end_time = time()

@printf("Tiempo de ejecución: %.2f s\n", end_time - start_time)