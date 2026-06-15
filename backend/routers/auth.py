from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from models import Usuario
from respuestas import ok
from schemas import LoginRequest, LoginResponse, UsuarioCreate, UsuarioOut
from security import create_token, get_current_user, hash_password, require_admin, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Usuario).where(Usuario.username == body.username.lower()))
    usuario = result.scalar_one_or_none()
    if usuario is None or not verify_password(body.password, usuario.password_hash):
        raise HTTPException(status_code=401, detail="Usuario o contraseña incorrectos")
    respuesta = LoginResponse(token=create_token(usuario), usuario=UsuarioOut.model_validate(usuario))
    return ok(respuesta.model_dump())


@router.get("/me")
async def me(usuario: Usuario = Depends(get_current_user)):
    return ok(UsuarioOut.model_validate(usuario).model_dump())


@router.get("/usuarios")
async def listar_usuarios(
    _: Usuario = Depends(get_current_user), db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Usuario).order_by(Usuario.nombre))
    usuarios = [UsuarioOut.model_validate(u).model_dump() for u in result.scalars()]
    return ok(usuarios)


@router.post("/usuarios")
async def crear_usuario(
    body: UsuarioCreate,
    _: Usuario = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    existente = await db.execute(select(Usuario).where(Usuario.username == body.username.lower()))
    if existente.scalar_one_or_none() is not None:
        raise HTTPException(status_code=409, detail="Ese username ya existe")
    usuario = Usuario(
        nombre=body.nombre.strip().upper(),
        username=body.username.lower(),
        password_hash=hash_password(body.password),
        rol=body.rol,
    )
    db.add(usuario)
    await db.commit()
    await db.refresh(usuario)
    return ok(UsuarioOut.model_validate(usuario).model_dump())
