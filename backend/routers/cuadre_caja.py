from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from excel import cuadres_a_xlsx
from models import CuadreCaja, Usuario
from respuestas import ok
from schemas import CuadreCajaCreate, CuadreCajaOut, NuevoTurnoOut
from security import get_current_user, require_admin

router = APIRouter(prefix="/cuadres", tags=["cuadre de caja"])


async def _ultimo_cuadre(db: AsyncSession) -> Optional[CuadreCaja]:
    result = await db.execute(
        select(CuadreCaja).order_by(CuadreCaja.numero_turno.desc()).limit(1)
    )
    return result.scalar_one_or_none()


def _filtrar(query, fecha_desde, fecha_hasta, usuario):
    if fecha_desde is not None:
        query = query.where(CuadreCaja.fecha >= fecha_desde)
    if fecha_hasta is not None:
        query = query.where(CuadreCaja.fecha <= fecha_hasta)
    if usuario:
        query = query.where(CuadreCaja.usuario_nombre.ilike(f"%{usuario}%"))
    return query


@router.get("")
async def historial(
    fecha_desde: Optional[date] = None,
    fecha_hasta: Optional[date] = None,
    usuario: Optional[str] = None,
    limit: int = 100,
    offset: int = 0,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = _filtrar(select(CuadreCaja), fecha_desde, fecha_hasta, usuario)
    query = query.order_by(CuadreCaja.numero_turno.desc()).limit(limit).offset(offset)
    result = await db.execute(query)
    return ok([CuadreCajaOut.model_validate(c).model_dump(mode="json") for c in result.scalars()])


@router.get("/nuevo-turno")
async def nuevo_turno(
    _: Usuario = Depends(get_current_user), db: AsyncSession = Depends(get_db)
):
    """Número de turno siguiente y base anterior (= base del día del último turno)."""
    ultimo = await _ultimo_cuadre(db)
    datos = NuevoTurnoOut(
        numero_turno=(ultimo.numero_turno + 1) if ultimo else 1,
        base_anterior=ultimo.base_del_dia if ultimo else 0,
    )
    return ok(datos.model_dump())


@router.get("/export.xlsx")
async def exportar(
    fecha_desde: Optional[date] = None,
    fecha_hasta: Optional[date] = None,
    usuario: Optional[str] = None,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = _filtrar(select(CuadreCaja), fecha_desde, fecha_hasta, usuario)
    result = await db.execute(query.order_by(CuadreCaja.numero_turno.desc()))
    buffer = cuadres_a_xlsx(list(result.scalars()))
    return StreamingResponse(
        buffer,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": 'attachment; filename="cuadres-caja.xlsx"'},
    )


@router.post("")
async def crear(
    body: CuadreCajaCreate,
    usuario: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    ultimo = await _ultimo_cuadre(db)

    numero_turno = body.numero_turno
    if numero_turno is None:
        numero_turno = (ultimo.numero_turno + 1) if ultimo else 1

    base_anterior = body.base_anterior
    if base_anterior is None:
        base_anterior = ultimo.base_del_dia if ultimo else 0

    cuadre = CuadreCaja(
        numero_turno=numero_turno,
        fecha=body.fecha,
        hora=body.hora,
        usuario_id=usuario.id,
        usuario_nombre=usuario.nombre,
        jornada=body.jornada,
        ventas_netas=body.ventas_netas,
        entregas=body.entregas,
        tarjetas=body.tarjetas,
        bonos=body.bonos,
        nequi_qr=body.nequi_qr,
        fact_electronica_credito=body.fact_electronica_credito,
        base_del_dia=body.base_del_dia,
        base_anterior=base_anterior,
        billetes_20000=body.billetes_20000,
        billetes_10000=body.billetes_10000,
        billetes_5000=body.billetes_5000,
        billetes_2000=body.billetes_2000,
        billetes_1000=body.billetes_1000,
        monedas_500=body.monedas_500,
        monedas_200=body.monedas_200,
        monedas_100=body.monedas_100,
        monedas_50=body.monedas_50,
    )
    cuadre.sobrante_faltante = cuadre.calcular_sobrante_faltante()
    db.add(cuadre)
    await db.commit()
    await db.refresh(cuadre)
    return ok(CuadreCajaOut.model_validate(cuadre).model_dump(mode="json"))


@router.get("/{cuadre_id}")
async def detalle(
    cuadre_id: int,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    cuadre = await db.get(CuadreCaja, cuadre_id)
    if cuadre is None:
        raise HTTPException(status_code=404, detail="Cuadre no encontrado")
    return ok(CuadreCajaOut.model_validate(cuadre).model_dump(mode="json"))


@router.delete("/{cuadre_id}")
async def eliminar(
    cuadre_id: int,
    _: Usuario = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    cuadre = await db.get(CuadreCaja, cuadre_id)
    if cuadre is None:
        raise HTTPException(status_code=404, detail="Cuadre no encontrado")
    await db.delete(cuadre)
    await db.commit()
    return ok(True)
