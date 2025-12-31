"""
    analyze_shells_pbc(coords, s_matrix, ranges)
Clasificación de vecinos mediante convención de imagen mínima.
"""
function analyze_neighbors_pbc(frac_coords, s_matrix, ranges)
    natoms = length(frac_coords)
    n_ranges = length(ranges)
    
    # Estructura de salida: lista de listas de vecinos
    neighbors = [ [Int[] for _ in 1:natoms] for _ in 1:n_ranges ]
    
    for i in 1:natoms
        fi = frac_coords[i]
        for j in 1:natoms
            i == j && continue
            
            # Imagen mínima: todo con SVectors
            df = fi - frac_coords[j]
            # SVector permite operaciones elemento a elemento eficientes
            df_pbc = df - map(round, df)
            
            # Multiplicación Matriz-Vector de StaticArrays (sin garbage collection)
            dr = s_matrix * df_pbc
            dist = norm(dr)
            
            for r in 1:n_ranges
                if ranges[r][1] <= dist < ranges[r][2]
                    push!(neighbors[r][i], j)
                    break
                end
            end
        end
    end
    return neighbors
end