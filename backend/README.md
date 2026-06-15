# FacturaInvent 2 — Backend (FastAPI + PostgreSQL)

API REST que centraliza todos los datos del supermercado. Las apps iOS/macOS
y Flutter son clientes de esta API.

## Requisitos

- Python 3.9+
- PostgreSQL corriendo en local (en el Mac de desarrollo: Postgres.app)

## Puesta en marcha

```bash
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# Crear la base de datos (una sola vez)
psql -d postgres -c "CREATE DATABASE facturainvent2;"

# Crear el usuario administrador (pide la contraseña por consola)
.venv/bin/python seed.py

# Arrancar el servidor (accesible desde la red local con --host 0.0.0.0)
.venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Documentación interactiva: `http://localhost:8000/docs`

## Configuración (variables de entorno)

| Variable | Default | Descripción |
|---|---|---|
| `FACTURAINVENT_DATABASE_URL` | `postgresql+asyncpg://localhost:5432/facturainvent2` | URL de PostgreSQL |
| `FACTURAINVENT_JWT_SECRET` | (secreto de desarrollo) | **Definir en producción** |
| `FACTURAINVENT_JWT_EXPIRE_HOURS` | `24` | Vigencia del token |

## Endpoints

Todas las respuestas usan el envelope `{ "data": ..., "error": null }`.
Todos los endpoints menos `/health` y `/auth/login` requieren `Authorization: Bearer <token>`.

### Auth
- `POST /auth/login` — `{username, password}` → `{token, usuario}`
- `GET /auth/me` — usuario actual
- `GET /auth/usuarios` — lista de usuarios (para filtros del historial)
- `POST /auth/usuarios` — crear cajero/admin (solo admin)

### Empresas y productos
- `GET|POST /empresas`, `GET|PUT|DELETE /empresas/{id}`
- `GET|POST /empresas/{id}/productos` (`?buscar=` para filtrar)
- `POST /empresas/{id}/productos/importar` — bulk desde XML DIAN parseado;
  deduplica por `codigo_factura` y luego `codigo_barras` (igual que v1),
  suma cantidades y actualiza precio
- `GET /empresas/{id}/productos/export.xlsx` — inventario en Excel
- `GET /productos/buscar?q=` — búsqueda global
- `PUT|DELETE /productos/{id}`

### Cuadre de caja
- `GET /cuadres?fecha_desde&fecha_hasta&usuario&limit&offset` — historial
- `GET /cuadres/nuevo-turno` — turno siguiente + base anterior automática
  (= base del día del último turno registrado)
- `POST /cuadres` — registra el cuadre; el servidor calcula `sobrante_faltante`
- `GET /cuadres/export.xlsx` — historial en Excel (mismas columnas que la hoja
  BASE DE DATOS del Excel original)
- `GET|DELETE /cuadres/{id}` (delete solo admin)

## Fórmula del sobrante/faltante

Verificada contra las 1010 filas reales de `CUADRE CAJA-1.xlsm`:

```
sobrante/faltante = base_del_dia + entregas + tarjetas + bonos + nequi_qr
                    + fact_electronica_credito − ventas_netas − base_anterior
```

> Positivo = sobrante, negativo = faltante. `total_denominaciones` es una
> columna GENERADA por PostgreSQL a partir del conteo de billetes y monedas.

## Producción (servidor del supermercado)

1. Instalar PostgreSQL y Python en el servidor local.
2. Definir `FACTURAINVENT_JWT_SECRET` con un secreto real.
3. Arrancar con `--host 0.0.0.0 --port 8000` y configurar las apps con
   `http://<ip-del-servidor>:8000`.
