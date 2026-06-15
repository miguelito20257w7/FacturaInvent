from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from models import Empresa, Usuario
from respuestas import ok
from schemas import EmpresaCreate, EmpresaOut, EmpresaUpdate
from security import get_current_user

router = APIRouter(prefix="/empresas", tags=["empresas"])


async def _empresa_o_404(empresa_id: int, db: AsyncSession) -> Empresa:
    empresa = await db.get(Empresa, empresa_id)
    if empresa is None:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa


@router.get("")
async def listar(_: Usuario = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Empresa).order_by(Empresa.nombre))
    return ok([EmpresaOut.model_validate(e).model_dump(mode="json") for e in result.scalars()])


@router.post("")
async def crear(
    body: EmpresaCreate,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    existente = await db.execute(select(Empresa).where(Empresa.nit == body.nit))
    if existente.scalar_one_or_none() is not None:
        raise HTTPException(status_code=409, detail="Ya existe una empresa con ese NIT")
    empresa = Empresa(nombre=body.nombre, nit=body.nit)
    db.add(empresa)
    await db.commit()
    await db.refresh(empresa)
    return ok(EmpresaOut.model_validate(empresa).model_dump(mode="json"))


@router.get("/{empresa_id}")
async def detalle(
    empresa_id: int,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    empresa = await _empresa_o_404(empresa_id, db)
    return ok(EmpresaOut.model_validate(empresa).model_dump(mode="json"))


@router.put("/{empresa_id}")
async def actualizar(
    empresa_id: int,
    body: EmpresaUpdate,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    empresa = await _empresa_o_404(empresa_id, db)
    if body.nombre is not None:
        empresa.nombre = body.nombre
    if body.nit is not None:
        empresa.nit = body.nit
    await db.commit()
    await db.refresh(empresa)
    return ok(EmpresaOut.model_validate(empresa).model_dump(mode="json"))


@router.delete("/{empresa_id}")
async def eliminar(
    empresa_id: int,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    empresa = await _empresa_o_404(empresa_id, db)
    await db.delete(empresa)
    await db.commit()
    return ok(True)
