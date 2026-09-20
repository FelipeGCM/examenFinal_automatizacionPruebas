#!/bin/bash

set -e

CONTENEDOR="examen-login-test"
IMAGEN_ESTABLE="examen-automatizacion:stable"

echo "Iniciando rollback..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTENEDOR}$"; then
  echo "Eliminando contenedor actual..."
  docker rm -f "$CONTENEDOR"
fi

echo "Levantando versión estable..."
docker run -d \
  --name "$CONTENEDOR" \
  -p 8080:8080 \
  "$IMAGEN_ESTABLE"

sleep 3

echo "Validando versión recuperada..."
BASE_URL=http://localhost:8080 ./deploy/acceptance-tests.sh

echo ""
echo "ROLLBACK COMPLETADO CORRECTAMENTE"