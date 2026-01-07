#!/bin/bash

# Configuración de variables (Usamos $HOME para rutas absolutas seguras)
IP_WORKER="192.168.1.47"
USER_WORKER="luz"

# Rutas en la Maestra (A)
LOCAL_SRC="$HOME/Desktop/MitchellProjects/TesisMaestria/src/MonteCarlo/"
LOCAL_RESULTS="$HOME/Desktop/MitchellProjects/TesisMaestria/results/MonteCarlo/"

# Rutas en el Worker (B) - Relativas al Home del usuario 'luz'
REMOTE_PROJECT="Desktop/MitchellProjects/TesisMaestria/"
# REMOTE_SRC="Desktop/MitchellProjects/TesisMaestria/src/MonteCarlo/"
REMOTE_SRC="${REMOTE_PROJECT}src/MonteCarlo/"
# REMOTE_RESULTS="Desktop/MitchellProjects/TesisMaestria/results/MonteCarlo/"
REMOTE_RESULTS="${REMOTE_PROJECT}results/MonteCarlo/"

# 1. Sincroniza archivos vía rsync
echo "------------------------------------------"
echo "1. Sincronizando código con el Worker: ${IP_WORKER}"
# Creamos la carpeta remota por si no existe antes de enviar
ssh ${USER_WORKER}@${IP_WORKER} "mkdir -p ${REMOTE_SRC} ${REMOTE_RESULTS}"

rsync -az --info=progress2 "${LOCAL_SRC}" ${USER_WORKER}@${IP_WORKER}:${REMOTE_SRC}

echo "------------------------------------------"
echo "2. Iniciando simulación en Julia..."
julia --project=. distributed.jl

echo "------------------------------------------"
echo "3. Recuperando archivos de resultados..."
# El / final en la ruta remota copia el contenido, no la carpeta
rsync -az --info=progress2 ${USER_WORKER}@${IP_WORKER}:${REMOTE_RESULTS}/ "${LOCAL_RESULTS}/"

echo "------------------------------------------"
echo "4. Eliminando archivos del Worker ${IP_WORKER}..."
ssh ${USER_WORKER}@${IP_WORKER} "rm -rf ${REMOTE_PROJECT}"

echo "------------------------------------------"
echo "Proceso finalizado con éxito."