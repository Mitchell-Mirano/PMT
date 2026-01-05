#!/bin/bash

# Configuración de variables
IP_WORKER="192.168.1.47"
DEST_PATH="~/Desktop/MitchellProjects/TesisMaestria/src/MonteCarlo/"

# 1. Sincroniza archivos vía rsync (Código y entorno)
echo "------------------------------------------"
echo "1. Sincronizando archivos con el Worker..."
rsync -avzP  ./ luz@$IP_WORKER:$DEST_PATH

# 2. Activar el servidor NFS
echo "2. Activando servidor NFS (Maestra)..."
sudo systemctl start nfs-kernel-server

# 3. Ejecuta la simulación
echo "3. Iniciando simulación en Julia..."
echo "------------------------------------------"

# Usamos un bloque 'trap' para asegurar que el NFS se apague 
# aunque canceles el script con Ctrl+C o Julia de un error.
trap 'echo "Apagando NFS..."; sudo systemctl stop nfs-kernel-server; exit' INT TERM EXIT

# Ejecución de Julia
julia --project=. distributed.jl

# El bloque 'trap' anterior se encargará de ejecutar el stop al finalizar
echo "------------------------------------------"
echo "Simulación finalizada. NFS desactivado automáticamente."
