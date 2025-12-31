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
    (6.8, 7.5)]

# La matriz de supercelda ahora es una SMatrix de 3x3
const superlattice_matrix = SMatrix{3,3,Float64}(hcat(N * v1, N * v2, v3))

# Definimos las posiciones de los atomos de la celda base en coordenadas fraccionarias
const basis_frac = [SVector(0.99993, 0.00006, 0.0), 
                    SVector(0.66674, 0.33327, 0.0)]


# --- Parámetros de simulación ---

Kb = 1
T_init = 10
T_final = 0.01
T_decay = 0.85
T_steps = Int(round(log(T_final/T_init)/log(T_decay)))
T_range = [T_init*(T_final/T_init)^(t/T_steps) for t in 0:T_steps]
B_range = [1/(Kb*T) for T in T_range]

N_term = 100_000
N_prod = 100_000
δ_init = 60.0


J1 = 3.5  
J2 = -0.136
J3 = -0.64

H_range = range(0.0, 10.0, 10)
D_range = range(0.0, 1.0, 10)
T_final_range = range(0.0,100.0,100)
