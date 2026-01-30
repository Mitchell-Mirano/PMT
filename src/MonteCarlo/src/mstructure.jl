using LinearAlgebra
using StaticArrays



function get_frac_coords(basis_frac, N)
    # Pre-asignamos el tamaño exacto para evitar push! constantes
    # El tipo es Vector de SVector{3, Float64}
    natoms = length(basis_frac) * N * N
    frac_coords = Vector{SVector{3, Float64}}(undef, natoms)
    
    idx = 1
    for i in 0:N-1
        for j in 0:N-1
            for bf in basis_frac
                # Operaciones aritméticas entre SVectors son extremadamente rápidas
                frac_coords[idx] = (bf + SVector(Float64(i), Float64(j), 0.0)) / N
                idx += 1
            end
        end
    end
    return frac_coords
end
