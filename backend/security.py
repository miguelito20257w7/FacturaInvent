from datetime import datetime, timedelta, timezone
from typing import Optional

import bcrypt
import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

import config
from database import get_db
from models import Usuario

_bearer = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


def create_token(usuario: Usuario) -> str:
    payload = {
        "sub": str(usuario.id),
        "username": usuario.username,
        "rol": usuario.rol,
        "exp": datetime.now(timezone.utc) + timedelta(hours=config.JWT_EXPIRE_HOURS),
    }
    return jwt.encode(payload, config.JWT_SECRET, algorithm=config.JWT_ALGORITHM)


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
    db: AsyncSession = Depends(get_db),
) -> Usuario:
    if credentials is None:
        raise HTTPException(status_code=401, detail="Falta el token de autenticación")
    try:
        payload = jwt.decode(
            credentials.credentials, config.JWT_SECRET, algorithms=[config.JWT_ALGORITHM]
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="El token expiró, inicia sesión de nuevo")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")

    usuario = await db.get(Usuario, int(payload["sub"]))
    if usuario is None:
        raise HTTPException(status_code=401, detail="El usuario ya no existe")
    return usuario


async def require_admin(usuario: Usuario = Depends(get_current_user)) -> Usuario:
    if usuario.rol != "admin":
        raise HTTPException(status_code=403, detail="Se requiere rol de administrador")
    return usuario
