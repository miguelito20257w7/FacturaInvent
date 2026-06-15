import os

# URL de PostgreSQL. En desarrollo: PostgreSQL local del Mac.
# En producción: el servidor local del supermercado.
DATABASE_URL = os.environ.get(
    "FACTURAINVENT_DATABASE_URL",
    "postgresql+asyncpg://localhost:5432/facturainvent2",
)

# Secreto para firmar JWT. En producción definir FACTURAINVENT_JWT_SECRET.
JWT_SECRET = os.environ.get("FACTURAINVENT_JWT_SECRET", "dev-secret-cambiar-en-produccion")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_HOURS = int(os.environ.get("FACTURAINVENT_JWT_EXPIRE_HOURS", "24"))
