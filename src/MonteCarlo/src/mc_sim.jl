using  StaticArrays


function monte_carlo(SP::Vector{SVector{3, Float64}},
                     NN1::Vector{SVector{3, Int64}},
                     NN2::Vector{SVector{6, Int64}},
                     NN3::Vector{SVector{3, Int64}},
                     D_ij::Vector{SVector{6, SVector{3, Float64}}},
                     B_range::Base.Generator, 
                     N_term::Int64, 
                     N_prod::Int64, 
                     δ_init::Float64, 
                     J1::Float64, 
                     J2::Float64, 
                     J3::Float64, 
                     D::Float64, 
                     H::Float64)
    MCS = length(SP)
    δ = δ_init
    for Beta in B_range
        for _ in 1:N_term
            R = metropolis(MCS, Beta, δ, SP, NN1, NN2, NN3, D_ij, J1, J2, J3, D, H)
            if R == 1.0 || δ > δ_init
                δ = δ_init
            else
                δ = δ*(0.5/(1-R))
            end
        end
        for _ in 1:N_prod
            metropolis(MCS, Beta, δ, SP, NN1, NN2, NN3, D_ij, J1, J2, J3, D, H)
        end
    end
end