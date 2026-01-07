#!/bin/bash

# Configuración de variables (Deben coincidir con tu script de ejecución)
LOCAL_SRC="$HOME/Desktop/MitchellProjects/TesisMaestria/src/MonteCarlo/"


IP_WORKER="192.168.1.47"
USER_WORKER="luz"
JULIA_PATH="/home/luz/.juliaup/bin/julia"
REMOTE_PROJECT="Desktop/MitchellProjects/TesisMaestria/"
REMOTE_SRC="${REMOTE_PROJECT}src/MonteCarlo/"

echo "=========================================================="
echo "   CONFIGURACIÓN INICIAL DEL CLÚSTER (SETUP WORKER)       "
echo "=========================================================="

# 1. Crear directorios necesarios en el Worker
echo "1. Creando directorios en el Worker..."
ssh ${USER_WORKER}@${IP_WORKER} "mkdir -p ${REMOTE_SRC}"

# 2. Sincronizar archivos de entorno (Project.toml y Manifest.toml)
# Solo enviamos estos archivos para preparar el entorno antes del código pesado
echo "2. Enviando archivos de entorno (.toml)..."
rsync -az "${LOCAL_SRC}Project.toml" "${LOCAL_SRC}Manifest.toml" ${USER_WORKER}@${IP_WORKER}:${REMOTE_SRC}

# 3. Instalar y Precompilar librerías en el Worker
echo "3. Instalando y precompilando librerías Julia en el Worker..."
echo "   (Esto puede tardar unos minutos la primera vez)"

ssh ${USER_WORKER}@${IP_WORKER} "cd ${REMOTE_SRC} && ${JULIA_PATH} --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); println(\"--- Entorno listo en el Worker ---\")'"

echo "4. Eliminando archivos del Worker..."
ssh ${USER_WORKER}@${IP_WORKER} "rm -rf ${REMOTE_PROJECT}"

echo "=========================================================="
echo "   SETUP FINALIZADO PARA EL WORKER: ${IP_WORKER}"
echo "=========================================================="