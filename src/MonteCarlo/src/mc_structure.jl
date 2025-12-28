
using LinearAlgebra



function get_frac_coords(basis_frac, N)
    
    # Generación de coordenadas fraccionarias en la supercelda N x N
    frac_coords = Vector{Float64}[]

    for i in 0:N-1
        for j in 0:N-1
            for bf in basis_frac
                push!(frac_coords, (bf .+ [i, j,0.0]) ./ N)
            end
        end
    
    end
    return frac_coords
end
