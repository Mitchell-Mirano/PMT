using StaticArrays

# --- Parámetros de red (Cr) ---
const a_len = 6.15409
const b_len = 6.15374
const gamma = deg2rad(120.0530)
const N = 12 # Cantidad de atomos

# Usamos SVector para los vectores base y SMatrix para la matriz de la supercelda
const v1 = SVector(a_len, 0.0, 0.0)
const v2 = SVector(b_len * cos(gamma), b_len * sin(gamma), 0.0)
const v3 = SVector(0.0, 0.0, 1.0) 

# Ranges para encontrar vecinos
const ranges = [
    (0.1, 4.0),
    (4.0, 6.8),
    (6.8, 7.5)
    ]

# La matriz de supercelda ahora es una SMatrix de 3x3
const superlattice_matrix = SMatrix{3,3,Float64}(hcat(N * v1, N * v2, v3))

# Definimos las posiciones de los atomos de la celda base en coordenadas fraccionarias
const basis_frac = [SVector(0.99993, 0.00006, 0.0), 
                    SVector(0.66674, 0.33327, 0.0)]


# --- Parámetros de simulación ---

Kb::Float64 = 1.0
T_init::Float64 = 300.0
T_steps::Int64 = 20 

N_term::Int64 = 100_000
N_prod::Int64 = 100_000
δ_init::Float64 = 60.0


J1::Float64 = 3.5  
J2::Float64 = -0.136
J3::Float64 = -0.64

D::Float64 = 0.33

points::Int64 = 10
H_range = collect(LinRange(0.0, 10.0, points))
D_range = collect(LinRange(0.0, 1.0, points))
T_range = collect(LinRange(eps(),100.0, points))
