using StaticArrays

function metropolis(MCS::Int64, Beta::Float64, δ::Float64,
                    SP::Vector{SVector{3, Float64}}, 
                    NN1::Vector{SVector{3, Int64}}, 
                    NN2::Vector{SVector{6, Int64}}, 
                    NN3::Vector{SVector{3, Int64}}, 
                    D_ij::Vector{SVector{6, SVector{3, Float64}}},
                    J1::Float64, J2::Float64, J3::Float64, D::Float64, H::Float64)
    cambiados = 0
    @inbounds for i in 1:MCS
        sp_i = SP[i]
        
        # Obtención ultra-rápida de vecinos
        sp_n1 = SP[NN1[i]]
        sp_n2 = SP[NN2[i]]
        sp_n3 = SP[NN3[i]]
        dm_v  = D_ij[i]
        
        sp_p = propose_spin(sp_i, δ)
        
        dE = Delta_E(sp_i, sp_p, sp_n1, sp_n2, sp_n3, dm_v, J1, J2, J3, D, H)
        
        if dE <= 0 || rand() < exp(-dE * Beta)
            SP[i] = sp_p
            cambiados += 1
        end
    end
    return cambiados / MCS  
end