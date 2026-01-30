using  LinearAlgebra
using StaticArrays

function Delta_E(sp_i::SVector{3, Float64}, 
                 sp_p::SVector{3, Float64},
                 sp_n1::SVector{3, SVector{3, Float64}}, 
                 sp_n2::SVector{6, SVector{3, Float64}},
                 sp_n3::SVector{3, SVector{3, Float64}},
                 DM_v::SVector{6, SVector{3, Float64}},
                 J1::Float64, 
                 J2::Float64, 
                 J3::Float64, 
                 D::Float64, 
                 H::Float64)

    dsp = sp_p - sp_i
    ku = 0.034
    g = 2.0
    ub = 0.05788
    g_ub = g * ub

    # Heisenberg: Suma componente a componente automática con SVectors
    field_heis = J1 * sum(sp_n1) + J2 * sum(sp_n2) + J3 * sum(sp_n3)
    dE_heisenberg = -dot(dsp, field_heis)

    # Anisotropía
    dE_anisotropy = -ku * (sp_p[3]^2 - sp_i[3]^2)

    # DMI: D * (Si x Sj) * Dij -> Campo efectivo h_dmi = Sj x Dij
    h_dmi = zero(SVector{3, Float64})
    for j in 1:6
        h_dmi += cross(sp_n2[j], DM_v[j])
    end
    dE_dmi = -D * dot(dsp, h_dmi)

    # Zeeman
    dE_zeeman = -g_ub * H * dsp[3]

    return dE_heisenberg + dE_anisotropy + dE_dmi + dE_zeeman
end
