using JSON3
using Logging

# --- Configuración de rutas locales ---
const CONFIG_FILE = "config/cluster.json"

"""
    sync_node_code(worker::JSON3.Object)

Gestiona la creación de directorios remotos y la transferencia de código
hacia un nodo específico utilizando rsync sobre SSH.
"""
function sync_node_code(manager_node::JSON3.Object, remote_node::JSON3.Object)
    host_name = remote_node.hostname
    node_project_path = manager_node.project
    
    # Construcción de rutas remotas
    manager_node_source_path = joinpath(manager_node.project_root, manager_node.source_path)
    node_source_path = joinpath(node_project_path, manager_node.source_path)
    node_output_path = joinpath(node_project_path, manager_node.output_path)

    @info "Sincronizando código con el nodo: $host_name"

    try
        # 1. Asegurar existencia de directorios remotos
        run(`ssh $host_name "mkdir -p $node_source_path $node_output_path"`)

        # 2. Sincronización de archivos mediante rsync
        # El uso de --info=progress2 es opcional; se omite para limpieza de logs en paralelo
        run(`rsync -az $manager_node_source_path/ $host_name:$node_source_path`)
        
        @info "Sincronización exitosa: $host_name"
    catch e
        @error "Fallo en la comunicación con el nodo $host_name" exception=(e, catch_backtrace())
    end
end


"""
    sync_node_results(worker::JSON3.Object)

Gestiona la recuperación de resultados de un nodo utilizando rsync sobre SSH.
"""
function fetch_results_to_manager(manager_node::JSON3.Object, remote_node::JSON3.Object)

    host_name = remote_node.hostname
    node_project_path = manager_node.project
    
    # Construcción de rutas remotas
    manager_node_output_path = joinpath(manager_node.project_root, manager_node.output_path)
    node_output_path = joinpath(node_project_path, manager_node.output_path)


    @info "Recuperando resultados del nodo: $host_name y eliminando directorios remotos"

    try
        # 1. Sincronización de archivos mediante rsync
        # El uso de --info=progress2 es opcional; se omite para limpieza de logs en paralelo
        run(`rsync -az $host_name:$node_output_path $manager_node_output_path/`)
        
        @info "Recuperación de resultados exitosa de nodo: $host_name"

        # 2. Eliminación de directorios remotos
        run(`ssh $host_name "rm -rf $node_project_path"`)
        
        @info "Eliminación de directorios remotos exitosa: $host_name"
    catch e
        @error "Fallo en la comunicación con el nodo $host_name" exception=(e, catch_backtrace())
    end
end


"""
    main()

Función principal que orquesta la sincronización paralela y la ejecución
de la simulación de Monte Carlo.
"""
function main()
    # Verificación de integridad de la configuración
    if !isfile(CONFIG_FILE)
        @error "Archivo de configuración no detectado: $CONFIG_FILE"
        exit(1)
    end

    # Carga y deserialización de la infraestructura de nodos
    cluster_data = open(JSON3.read, CONFIG_FILE)
    manager_node = cluster_data.manager_node
    remote_nodes = cluster_data.remote_nodes

    @info "------------------------------------------"
    @info "1. Iniciando sincronización de $(length(remote_nodes)) nodos..."

    # Sincronización concurrente de todos los nodos
    @sync for node in remote_nodes
        @async sync_node_code(manager_node, node)
    end

    @info "------------------------------------------"
    @info "2. Iniciando simulación distribuida"
    
    try
        # Ejecución del proceso de simulación principal
        run(`julia --project=. distributed.jl`)
    catch e
        @error "Error durante la ejecución de la simulación" exception=e
    end

    @info "------------------------------------------"
    @info "3. Recuperando resultados..."

    # Recuperación de resultados de todos los nodos
    @sync for node in remote_nodes
        @async fetch_results_to_manager(manager_node, node)
    end
    
    @info "------------------------------------------"
    @info "simulación distribuida finalizada."
end

# Ejecución del punto de entrada
main()