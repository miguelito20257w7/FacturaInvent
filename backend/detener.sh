#!/bin/bash
# Detiene la API de FacturaInvent 2. PostgreSQL se deja corriendo
# (ciérralo desde la app Postgres si también lo quieres apagar).
cd "$(dirname "$0")"

if pgrep -f "uvicorn main:app" > /dev/null; then
    pkill -f "uvicorn main:app"
    echo "API detenida."
else
    echo "La API no estaba corriendo."
fi
rm -f api.pid
