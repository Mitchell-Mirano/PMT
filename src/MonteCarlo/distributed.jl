using Distributed


# 1. Configuración de Workers
if nprocs() == 1
    # AGREGAR CORES LOCALES AUTOMÁTICAMENTE
    # Usamos todos los hilos disponibles menos 1 para que la laptop no se congele
    cores_locales = Sys.CPU_THREADS - 2
    println("Detectados $(Sys.CPU_THREADS) cores locales. Activando $cores_locales...")
    addprocs(cores_locales)

    # AGREGAR CORES REMOTOS (Laptop B)
    workers_config = [
        (
            "luz@192.168.1.47", 
            "/home/luz/Desktop/MitchellProjects/TesisMaestria/src/MonteCarlo", 
            "/home/luz/.juliaup/bin/julia"
        )
    ]

    for (maquina, ruta, ejecutable) in workers_config
        println("Conectando con $maquina...")
        addprocs([(maquina, :auto)], 
                 tunnel=true, 
                 dir=ruta,
                 exename=ejecutable,
                 exeflags="--project") 
    end
end


# 2. Carga en todos los nodos (Manager y Workers)
@everywhere begin
    using Pkg
    # Al usar 'dir' en addprocs, Julia ya inició en la carpeta correcta.
    # Pero nos aseguramos activando el proyecto en el directorio actual.
    Pkg.activate(".") 
    
    using Random, DelimitedFiles, LinearAlgebra, StaticArrays, CairoMakie, Printf


    const project_path = expanduser("~/Desktop/MitchellProjects/TesisMaestria")
    const montecarlo_path = joinpath(project_path, "src/MonteCarlo")
    const results_path = joinpath(project_path, "results/MonteCarlo")

    mkpath(joinpath(results_path, "spins/HvsT"))
    mkpath(joinpath(results_path, "images/HvsT"))
    
    include(joinpath(montecarlo_path, "src/mc_spins.jl"))
    include(joinpath(montecarlo_path, "src/mc_vectors.jl"))
    include(joinpath(montecarlo_path, "src/mc_hamiltonian.jl"))
    include(joinpath(montecarlo_path, "src/mc_data.jl"))
    include(joinpath(montecarlo_path, "src/mc_metropolis.jl"))
    include(joinpath(montecarlo_path, "src/mc_sim.jl"))
    include(joinpath(montecarlo_path, "src/mc_plots.jl"))
    include(joinpath(montecarlo_path, "src/mc_params.jl"))

    # Lectura de datos usando rutas unidas explícitamente
    POS = to_svec(readdlm(joinpath(montecarlo_path, "data/coords.txt"), Float64))
    FRAC_POS = to_svec(readdlm(joinpath(montecarlo_path, "data/frac_coords.txt"), Float64))
    NN1 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors1.txt"), Int))
    NN2 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors2.txt"), Int))
    NN3 = to_svec(readdlm(joinpath(montecarlo_path, "data/neighbors3.txt"), Int))
    
    D_ij = [get_DM_vectors(FRAC_POS, NN2[i], superlattice_matrix, i) for i in 1:length(POS)]
end

# 3. Función de tarea
@everywhere function tarea_completa(H, T)
    SPINS = [random_unit_vector() for _ in 1:length(POS)]
    B_range = (1/(Kb*(T_init*(T/T_init)^(t/T_steps))) for t in 0:T_steps)
    monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
    
    title = @sprintf("H = %0.2f, T = %0.2f, D = %0.2f", H, T, D)
    writedlm(joinpath(results_path, "spins/HvsT/$(title).txt"), SPINS)
    fig = plot_spins(POS, SPINS, title)
    save(joinpath(results_path, "images/HvsT/$(title).png"), fig)
    
    return "Finalizado: $title en el nodo $(myid()) de la máquina $(gethostname())"
end

# 4. Lanzamiento
params = [(H, T) for H in H_range, T in T_range]
start_time = time()

println("Lanzando pmap en $(nprocs()) procesos...")
mensajes = pmap(params) do (H, T)
    tarea_completa(H, T)
end

foreach(println, mensajes)
@printf("Tiempo total: %.2f min\n", (time() - start_time) / 60.0)