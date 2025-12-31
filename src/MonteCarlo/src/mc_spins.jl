using LinearAlgebra
using StaticArrays


# function random_unit_vector()

# # Generación eficiente de vector aleatorio inmutable

# return normalize(SVector{3, Float64}(2*rand(3) .- 1))

# end



# function propose_spin(P::SVector{3, Float64}, δ::Float64)

# η = random_unit_vector()

# return normalize(P + δ * η)

# end


# 1. Propose spin sin alocaciones
function random_unit_vector()
    # randn para SVector es muy eficiente y no aloca en el heap
    return normalize(randn(SVector{3, Float64}))
end

function propose_spin(P::SVector{3, Float64}, δ::Float64)
    return normalize(P + δ * random_unit_vector())
end