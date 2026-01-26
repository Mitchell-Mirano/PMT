using Distributed
using JSON3


CONFIG_FILE = "config/cluster.json"



# 1. Configuración de Workers
if nprocs() == 1
    # AGREGAR CORES LOCALES AUTOMÁTICAMENTE
    # Usamos todos los hilos disponibles menos 1 para que la laptop no se congele
    cores_locales = Sys.CPU_THREADS - 4
    println("Detectados $(Sys.CPU_THREADS) cores locales. Activando $cores_locales...")
    addprocs(cores_locales)


    cluster_data = open(JSON3.read, CONFIG_FILE)
    manager_node = cluster_data.manager_node
    remote_nodes = cluster_data.remote_nodes


    for node in remote_nodes
        println("Conectando con $(node.hostname)...")
        addprocs([(node.hostname, :auto)], 
                 tunnel=true, 
                 dir=joinpath(node.project_root, manager_node.source_path),
                 exename=node.julia_binary,
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

    cluster_data = open(JSON3.read, CONFIG_FILE)
    manager_node = cluster_data.master


    const project_path = joinpath(homedir(),manager_node.project)
    const code_path = joinpath(project_path, manager_node.source_path)
    const output_path = joinpath(project_path, manager_node.output_path)

    mkpath(joinpath(output_path, "spins/HvsT"))
    mkpath(joinpath(output_path, "images/HvsT"))
    
    include(joinpath(code_path, "src/mc_spins.jl"))
    include(joinpath(code_path, "src/mc_vectors.jl"))
    include(joinpath(code_path, "src/mc_hamiltonian.jl"))
    include(joinpath(code_path, "src/mc_data.jl"))
    include(joinpath(code_path, "src/mc_metropolis.jl"))
    include(joinpath(code_path, "src/mc_sim.jl"))
    include(joinpath(code_path, "src/mc_plots.jl"))
    include(joinpath(code_path, "src/mc_params.jl"))

    # Lectura de datos usando rutas unidas explícitamente
    POS = to_svec(readdlm(joinpath(code_path, "data/coords.txt"), Float64))
    FRAC_POS = to_svec(readdlm(joinpath(code_path, "data/frac_coords.txt"), Float64))
    NN1 = to_svec(readdlm(joinpath(code_path, "data/neighbors1.txt"), Int))
    NN2 = to_svec(readdlm(joinpath(code_path, "data/neighbors2.txt"), Int))
    NN3 = to_svec(readdlm(joinpath(code_path, "data/neighbors3.txt"), Int))
    
    D_ij = [get_DM_vectors(FRAC_POS, NN2[i], superlattice_matrix, i) for i in 1:length(POS)]
end

# 3. Función de tarea
@everywhere function job(H, T)
    SPINS = [random_unit_vector() for _ in 1:length(POS)]
    B_range = (1/(Kb*(T_init*(T/T_init)^(t/T_steps))) for t in 0:T_steps)
    monte_carlo(SPINS, NN1, NN2, NN3, D_ij, B_range, N_term, N_prod, δ_init, J1, J2, J3, D, H)
    
    title = @sprintf("H = %0.2f, T = %0.2f, D = %0.2f", H, T, D)
    writedlm(joinpath(output_path, "spins/HvsT/$(title).txt"), SPINS)
    fig = plot_spins(POS, SPINS, title)
    save(joinpath(output_path, "images/HvsT/$(title).png"), fig)
    
    return "Finalizado: $title en el nodo $(myid()) de la máquina $(gethostname())"
end

# 4. Lanzamiento
params = [(H, T) for H in H_range, T in T_range]


start_time = time_ns()

println("Lanzando pmap en $(nprocs()) procesos...")
mensajes = pmap(params) do (H, T)
    job(H, T)
end

foreach(println, mensajes)

elapsed_min = (time_ns() - start_time) / 60e9
@printf("Tiempo total: %.2f min\n", elapsed_min)