"""
    analyze_shells_pbc(coords, s_matrix, ranges)
Clasificación de vecinos mediante convención de imagen mínima.
"""
function analyze_neighbors_pbc(frac_coords, superlattice_matrix, ranges)
    neigbors = Dict(order => [Int[] for _ in 1:natoms] for order in keys(ranges))
    
    for i in 1:natoms
        for j in 1:natoms
            i == j && continue
            
            # Imagen mínima en espacio fraccionario
            df = frac_coords[i] .- frac_coords[j]
            df = df .- round.(df)
            
            # Distancia en espacio real
            dr = superlattice_matrix * df
            dist = norm(dr)
            
            for (order, r_bound) in ranges
                if r_bound[1] <= dist < r_bound[2]
                    push!(neigbors[order][i], j)
                    break
                end
            end
        end
    end
    return neigbors
end