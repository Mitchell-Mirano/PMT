#!/bin/bash

# Configuración de variables (Usamos $HOME para rutas absolutas seguras)
WORKER_NAME="MITCHELL_OMEN_UBUNTU"

# Rutas en la Maestra (A)
LOCAL_SRC="$HOME/Desktop/MitchellProjects/PMT/src/MonteCarlo/"
LOCAL_RESULTS="$HOME/Desktop/MitchellProjects/PMT/results/MonteCarlo/"

# Rutas en el Worker (B) - Relativas al Home del usuario 'luz'
REMOTE_PROJECT="Desktop/MitchellProjects/PMT/"
# REMOTE_SRC="Desktop/MitchellProjects/PMT/src/MonteCarlo/"
REMOTE_SRC="${REMOTE_PROJECT}src/MonteCarlo/"
# REMOTE_RESULTS="Desktop/MitchellProjects/PMT/results/MonteCarlo/"
REMOTE_RESULTS="${REMOTE_PROJECT}results/MonteCarlo/"

# 1. Sincroniza archivos vía rsync
echo "------------------------------------------"
echo "1. Sincronizando código con el Worker: ${WORKER_NAME}"
# Creamos la carpeta remota por si no existe antes de enviar
ssh ${WORKER_NAME} "mkdir -p ${REMOTE_SRC} ${REMOTE_RESULTS}"

rsync -az --info=progress2 "${LOCAL_SRC}" ${WORKER_NAME}:${REMOTE_SRC}

echo "------------------------------------------"
echo "2. Iniciando simulación en Julia..."
julia --project=. distributed.jl

echo "------------------------------------------"
echo "3. Recuperando archivos de resultados..."
# El / final en la ruta remota copia el contenido, no la carpeta
rsync -az --info=progress2 "${LOCAL_RESULTS}/" ${WORKER_NAME}:${REMOTE_RESULTS}/ 

echo "------------------------------------------"
# echo "4. Eliminando archivos del Worker ${IP_WORKER}..."
# ssh ${WORKER_NAME} "rm -rf ${REMOTE_PROJECT}"
echo "4. Eliminando los resultados de la Maestra..."
rm -rf ${LOCAL_RESULTS}

echo "------------------------------------------"
echo "Proceso finalizado con éxito."