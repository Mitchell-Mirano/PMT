function get_DM_vectors(frac_coords::Vector{SVector{3, Float64}}, 
                        neighbors2::SVector{6, Int64}, 
                        superlattice_matrix::SMatrix{3, 3, Float64, 9}, 
                        i::Int64)
    rot_angle = deg2rad(6.69)
    # Matriz de rotación estática
    R = @SMatrix [cos(rot_angle) -sin(rot_angle) 0; 
                  sin(rot_angle)  cos(rot_angle) 0;
                  0              0              1]

    pos_i = frac_coords[i]
    
    # Replicamos exactamente la lógica original vector por vector
    DM_vectors = ntuple(j -> begin
        idx_n2 = neighbors2[j]
        pos_j = frac_coords[idx_n2]
        
        df_ij = pos_i - pos_j
        df_ij_pbc = df_ij - round.(df_ij) # PBC
        cart_pos = superlattice_matrix * df_ij_pbc
        
        # Originalmente: stack(dff)' * R. Para vectores columna es: R' * v
        dm_rot = R' * cart_pos 
        return normalize(dm_rot)
    end, 6)

    return SVector{6, SVector{3, Float64}}(DM_vectors)
end