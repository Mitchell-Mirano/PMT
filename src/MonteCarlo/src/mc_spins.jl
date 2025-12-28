using LinearAlgebra
using StaticArrays

function random_unit_vector()
    # Generación eficiente de vector aleatorio inmutable
    return normalize(SVector{3, Float64}(2*rand(3) .- 1))
end

function propose_spin(P::SVector{3, Float64}, δ::Float64)
    η = random_unit_vector()
    return normalize(P + δ * η)
end