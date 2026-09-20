#!/bin/bash

set -e

BASE_URL="${BASE_URL:-http://localhost:8080}"

echo " Acceptance Tests"
echo " Ambiente: $BASE_URL"

echo "[1/2] Validando login con credenciales correctas..."

HTTP_OK=$(curl -s \
  -o /tmp/login-ok.json \
  -w "%{http_code}" \
  -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"usuario":"felipe","contrasena":"1234"}')

RESPUESTA_OK=$(cat /tmp/login-ok.json)

if [ "$HTTP_OK" != "200" ]; then
  echo "ERROR: se esperaba HTTP 200 y se obtuvo $HTTP_OK"
  exit 1
fi

if [[ "$RESPUESTA_OK" != *"acceso permitido"* ]]; then
  echo "ERROR: la respuesta no contiene 'acceso permitido'"
  exit 1
fi

echo "OK - HTTP $HTTP_OK - acceso permitido"

echo ""
echo "[2/2] Validando login con credenciales incorrectas..."

HTTP_ERROR=$(curl -s \
  -o /tmp/login-error.json \
  -w "%{http_code}" \
  -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"usuario":"felipe","contrasena":"incorrecta"}')

RESPUESTA_ERROR=$(cat /tmp/login-error.json)

if [ "$HTTP_ERROR" != "401" ]; then
  echo "ERROR: se esperaba HTTP 401 y se obtuvo $HTTP_ERROR"
  exit 1
fi

if [[ "$RESPUESTA_ERROR" != *"acceso rechazado"* ]]; then
  echo "ERROR: la respuesta no contiene 'acceso rechazado'"
  exit 1
fi

echo "OK - HTTP $HTTP_ERROR - acceso rechazado"

echo ""
echo " ACCEPTANCE TESTS EXITOSOS"