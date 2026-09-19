#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Debe indicar la versión a desplegar"
  echo "Ejemplo: ./deploy/deploy.sh 1.1"
  exit 1
fi

VERSION="$1"
IMAGEN="examen-automatizacion"
CONTENEDOR="examen-login-test"

IMAGEN_NUEVA="${IMAGEN}:${VERSION}"
IMAGEN_ESTABLE="${IMAGEN}:stable"

echo "Construyendo versión $VERSION..."
docker build -t "$IMAGEN_NUEVA" .

echo "Desplegando versión $VERSION..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTENEDOR}$"; then
  docker rm -f "$CONTENEDOR"
fi

docker run -d \
  --name "$CONTENEDOR" \
  -p 8080:8080 \
  "$IMAGEN_NUEVA"

sleep 3

echo ""
echo "Ejecutando acceptance tests..."

if BASE_URL=http://localhost:8080 ./deploy/acceptance-tests.sh; then

  echo ""
  echo "Acceptance tests correctos"

  docker tag "$IMAGEN_NUEVA" "$IMAGEN_ESTABLE"

  echo "Versión $VERSION marcada como stable"
  echo "DESPLIEGUE COMPLETADO CORRECTAMENTE"

else

  echo ""
  echo "Fallaron los acceptance tests"
  echo "Ejecutando rollback..."

  ./deploy/rollback.sh

  exit 1
fi