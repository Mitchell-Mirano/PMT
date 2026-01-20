#!/bin/bash

# Configuración de variables (Deben coincidir con tu script de ejecución)
LOCAL_SRC="$HOME/Desktop/MitchellProjects/PMT/src/MonteCarlo/"


WORKER_NAME="MITCHELL_OMEN_UBUNTU"
JULIA_PATH="/home/mitchellmirano/.juliaup/bin/julia"
REMOTE_PROJECT="Desktop/MitchellProjects/PMT/"
REMOTE_SRC="${REMOTE_PROJECT}src/MonteCarlo/"

echo "=========================================================="
echo "   CONFIGURACIÓN INICIAL DEL CLÚSTER (SETUP WORKER)       "
echo "=========================================================="

# 1. Crear directorios necesarios en el Worker
echo "1. Creando directorios en el Worker..."
ssh ${WORKER_NAME} "mkdir -p ${REMOTE_SRC}"

# 2. Sincronizar archivos de entorno (Project.toml y Manifest.toml)
# Solo enviamos estos archivos para preparar el entorno antes del código pesado
echo "2. Enviando archivos de entorno (.toml)..."
rsync -az "${LOCAL_SRC}Project.toml" "${LOCAL_SRC}Manifest.toml" ${WORKER_NAME}:${REMOTE_SRC}

# 3. Instalar y Precompilar librerías en el Worker
echo "3. Instalando y precompilando librerías Julia en el Worker..."
echo "   (Esto puede tardar unos minutos la primera vez)"

ssh ${WORKER_NAME} "cd ${REMOTE_SRC} && ${JULIA_PATH} --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); println(\"--- Entorno listo en el Worker ---\")'"

# echo "4. Eliminando archivos del Worker..."
# ssh ${WORKER_NAME} "rm -rf ${REMOTE_PROJECT}"

echo "=========================================================="
echo "   SETUP FINALIZADO PARA EL WORKER: ${WORKER_NAME}"
echo "=========================================================="