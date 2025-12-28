using CairoMakie
using Base.Threads
using Printf


include("src/mc_plots.jl")
include("src/mc_data.jl")



POS = to_svec(readdlm("data/coords.txt", Float64))
H_range = 0.0:0.1:10.0
D_range = 0.0:0.1:10.0


params = [(H, D) for H in H_range, D in D_range]

start_time = time()

@threads for (H,D) in params
    SPINS = to_svec(readdlm("results/spins/H($(H))_D($(D)).txt", Float64))
    fig = plot_spins(POS, SPINS, H, D)
    save("results/images/H($(H))_D($(D)).png", fig)
end
end_time = time()

@printf("Tiempo de ejecución: %.2f s\n", end_time - start_time)
