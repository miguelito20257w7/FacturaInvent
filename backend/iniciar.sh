#!/bin/bash
# Arranca FacturaInvent 2: PostgreSQL (si hace falta) + la API en el puerto 8000.
cd "$(dirname "$0")"

PG=/Applications/Postgres.app/Contents/Versions/latest/bin
if ! "$PG/pg_isready" -q; then
    echo "Arrancando PostgreSQL (Postgres.app)…"
    open -a Postgres
    for _ in $(seq 1 15); do
        "$PG/pg_isready" -q && break
        sleep 1
    done
    if ! "$PG/pg_isready" -q; then
        echo "PostgreSQL no respondió. Abre la app Postgres y vuelve a intentar."
        exit 1
    fi
fi

if pgrep -f "uvicorn main:app" > /dev/null; then
    echo "La API ya estaba corriendo: http://localhost:8000"
    exit 0
fi

nohup .venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000 >> api.log 2>&1 &
echo $! > api.pid

sleep 2
if curl -s -m 3 http://localhost:8000/health > /dev/null; then
    IP=$(ipconfig getifaddr en0 2>/dev/null)
    echo "API corriendo:"
    echo "  - En este Mac:    http://localhost:8000"
    [ -n "$IP" ] && echo "  - En la red local: http://$IP:8000"
    echo "Log: backend/api.log"
else
    echo "La API no arrancó. Revisa backend/api.log"
    exit 1
fi
