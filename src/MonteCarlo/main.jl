using Random
using DelimitedFiles
using LinearAlgebra
using StaticArrays
using CairoMakie
using Printf
using Base.Threads


# 1. Usa expanduser para que la ruta sea válida
const project_path = expanduser("~/Desktop/MitchellProjects/PMT")
const montecarlo_path = joinpath(project_path, "src/MonteCarlo")
const results_path = joinpath(project_path, "results/MonteCarlo")

# 2. Crea las carpetas de resultados si no existen antes de empezar el loop
mkpath(joinpath(results_path, "spins/HvsT"))
mkpath(joinpath(results_path, "images/HvsT"))


# 3. Incluye los archivos de funciones
include(joinpath(montecarlo_path, "src/mc_spins.jl"))
include(joinpath(montecarlo_path, "src/mc_vectors.jl"))
include(joinpath(montecarlo_path, "src/mc_hamiltonian.jl"))
include(joinpath(montecarlo_path, "src/mc_data.jl"))
include(joinpath(montecarlo_path, "src/mc_metropolis.jl"))
include(joinpath(montecarlo_path, "src/mc_sim.jl"))
include(joinpath(montecarlo_path, "src/mc_plots.jl"))
include(joinpath(montecarlo_path, "src/mc_params.jl"))



# # Lectura de datos
# POS = to_svec(readdlm("data/coords.txt", Float64))
# FRAC_POS = to_svec(readdlm("data/frac_coords.txt", Float64))
# NN1 = to_svec(readdlm("data/neighbors1.txt", Int))
# NN2 = to_svec(readdlm("data/neighbors2.txt", Int))
# NN3 = to_svec(readdlm("data/neighbors3.txt", Int))

POS = to_svec(readdlm(joinpath(montecarlo_path, "data/coords.txt"), Float64))
FRAC_POS = to_svec(readdlm(joinpath(montecarlo_path, "data/frac_coords.txt"), Float64))
NN1 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors1.txt"), Int))
NN2 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors2.txt"), Int))
NN3 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors3.txt"), Int))


# Calculo de vectores  DMI
D_ij = [get_DM_vectors(FRAC_POS, NN2[i], superlattice_matrix, i) for i in 1:length(POS)]

## Simnulacion con parámetros fijos
SPINS = [random_unit_vector() for _ in 1:length(POS)]

H = 4.0
T = 0.4 + eps()
# T_range = [T_init*(T_final/T_init)^(t/T_steps) for t in 0:T_steps]
B_range = (1/(Kb*(T_init*(T/T_init)^(t/T_steps))) for t in 0:T_steps) 

@time monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
title = @sprintf("H = %0.2f, T = %0.2f, D = %0.2f", H, T, D)
    writedlm(joinpath(results_path, "spins/HvsT/$(title).txt"), SPINS)
    fig = plot_spins(POS, SPINS, title)
    save(joinpath(results_path, "images/HvsT/$(title).png"), fig)



# # Simulación con parámetros variados

# params = [(H, T) for H in H_range, T in T_range]

# start_time = time()

# @threads for (H,T) in params
#     SPINS = [random_unit_vector() for _ in 1:length(POS)]
#     B_range = (1/(Kb*(T_init*(T/T_init)^(t/T_steps))) for t in 0:T_steps)
#     monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
#     title = @sprintf("H = %0.2f, T = %0.2f, D = %0.2f", H, T, D)
#     writedlm(joinpath(results_path, "spins/HvsT/$(title).txt"), SPINS)
#     fig = plot_spins(POS, SPINS, title)
#     save(joinpath(results_path, "images/HvsT/$(title).png"), fig)
# end

# end_time = time()

# @printf("Tiempo de ejecución: %.2f min\n", (end_time - start_time) / 60.0)