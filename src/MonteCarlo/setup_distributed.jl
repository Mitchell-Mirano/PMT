using JSON3
using Logging
using Base.Threads

# Configuración de constantes y rutas del sistema
const CONFIG_FILE = "config/cluster.json"
const MAX_CONCURRENT_OPERATIONS = 8  # Límite de conexiones SSH simultáneas

"""
    setup_worker(worker::JSON3.Object)

Ejecuta la configuración remota de un nodo de forma atómica.
"""
function setup_node(manager_node::JSON3.Object, remote_node::JSON3.Object)

    host_name = remote_node.hostname
    julia_binary_path = remote_node.julia_binary
    node_source_path = joinpath(manager_node.project, manager_node.source_path)
    
    @info "Iniciando configuración del nodo: $host_name::$node_source_path"

    try
        # 1. Preparación del entorno de directorios
        run(`ssh $host_name "mkdir -p $node_source_path"`)

        
        manager_source_path = joinpath(manager_node.project_root, manager_node.source_path)

        @info "Sincronizando código entre: $manager_source_path/ y $host_name::$node_source_path"
        
        run(`rsync -az $manager_source_path/ $host_name:$node_source_path`)

        # 3. Despliegue de lógica de instanciación remota
        julia_cmd = "using Pkg; Pkg.instantiate(); Pkg.precompile();"
        remote_exec = "cd $node_source_path && $julia_binary_path --project=. -e '$julia_cmd'"
        
        run(`ssh $host_name $remote_exec`)

        @info "Configuración completada exitosamente en: $host_name"
    catch e
        @error "Fallo en la configuración del nodo $host_name" exception=(e, catch_backtrace())
    end
end

"""
    main()

Orquestador principal que gestiona el ciclo de vida del aprovisionamiento.
"""
function main()
    if !isfile(CONFIG_FILE)
        @error "Archivo de configuración no encontrado: $CONFIG_FILE"
        exit(1)
    end

    cluster_data = open(JSON3.read, CONFIG_FILE)
    manager_node = cluster_data.manager_node
    remote_nodes = cluster_data.remote_nodes
    
    total_nodes = length(cluster_data.remote_nodes)
    @info "Detección de $total_nodes nodos para aprovisionamiento."

    # Implementación de un semáforo mediante un canal para limitar la carga del sistema
    semaphore = Channel{Nothing}(MAX_CONCURRENT_OPERATIONS)

    @info "Iniciando ejecución concurrente (Límite: $MAX_CONCURRENT_OPERATIONS)"

    @sync for node in remote_nodes
        # Adquisición de un slot en el semáforo (bloqueante si el canal está lleno)
        put!(semaphore, nothing)
        
        @async begin
            try
                setup_node(manager_node, node)
            finally
                # Liberación del slot tras finalizar la tarea (éxito o fallo)
                take!(semaphore)
            end
        end
    end

    @info "Proceso de aprovisionamiento global finalizado."
end

# Punto de entrada al programa
main()