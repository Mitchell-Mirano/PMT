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
# --- Algoritmo MC ---


# --- Inicialización y Ejecución ---

# Parámetros de red
const a_len, b_len = 6.15409, 6.15374
const gamma = deg2rad(120.0530)
const N_size = 12

v1 = SVector{3}(a_len, 0.0, 0.0)
v2 = SVector{3}(b_len * cos(gamma), b_len * sin(gamma), 0.0)
v3 = SVector{3}(0.0, 0.0, 0.0)
super_mat = SMatrix{3,3}(hcat(N_size * v1, N_size * v2, N_size * v3))

POS = to_svec(readdlm("data/coords.txt", Float64))
FRAC_POS = to_svec(readdlm("data/frac_coords.txt", Float64))
NN1 = to_svec(readdlm("data/neighbors1.txt", Int))
NN2 = to_svec(readdlm("data/neighbors2.txt", Int))
NN3 = to_svec(readdlm("data/neighbors3.txt", Int))

D_ij = [get_DM_vectors(FRAC_POS, NN2[i], super_mat, i) for i in 1:length(POS)]


Kb = 1
T_init = 10
T_final = 0.01
T_decay = 0.85
T_steps = Int(round(log(T_final/T_init)/log(T_decay)))
T_range = [T_init*(T_final/T_init)^(t/T_steps) for t in 0:T_steps]
B_range = [1/(Kb*T) for T in T_range]

N_term = 100000
N_prod = 1000
δ_init = 0.6


J1 = 3.5  
J2 = -0.136
J3 = -0.64

# H_range = 0.0:0.1:10.0
# D_range = 0.0:0.1:10.0

# params = [(H, D) for H in H_range, D in D_range]

# start_time = time()

# @threads for (H,D) in params
#     SPINS = [random_unit_vector() for _ in 1:length(POS)]
#     monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
#     writedlm("results/spins/H($(H))_D($(D)).txt", SPINS)
# end

# end_time = time()

# @printf("Tiempo de ejecución: %.2f s\n", end_time - start_time)

SPINS = [random_unit_vector() for _ in 1:length(POS)]

D = 0.9
H = 4.0
monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
fig = plot_spins(POS, SPINS, H, D)
display(fig)