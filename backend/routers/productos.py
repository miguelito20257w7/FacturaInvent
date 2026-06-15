from typing import List

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from excel import inventario_a_xlsx
from models import Empresa, Producto, Usuario
from respuestas import ok
from schemas import ProductoCreate, ProductoImportItem, ProductoOut, ProductoUpdate
from security import get_current_user

router = APIRouter(tags=["productos"])


async def _empresa_o_404(empresa_id: int, db: AsyncSession) -> Empresa:
    empresa = await db.get(Empresa, empresa_id)
    if empresa is None:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa


async def _producto_o_404(producto_id: int, db: AsyncSession) -> Producto:
    producto = await db.get(Producto, producto_id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return producto


@router.get("/empresas/{empresa_id}/productos")
async def listar(
    empresa_id: int,
    buscar: str = "",
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _empresa_o_404(empresa_id, db)
    query = select(Producto).where(Producto.empresa_id == empresa_id)
    if buscar:
        patron = f"%{buscar}%"
        query = query.where(
            Producto.nombre.ilike(patron)
            | Producto.codigo_barras.ilike(patron)
            | Producto.codigo_factura.ilike(patron)
            | Producto.codigo_interno.ilike(patron)
        )
    result = await db.execute(query.order_by(Producto.nombre))
    return ok([ProductoOut.model_validate(p).model_dump() for p in result.scalars()])


@router.get("/productos/buscar")
async def buscar_global(
    q: str,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Búsqueda en todas las empresas (tab Buscar)."""
    patron = f"%{q}%"
    query = (
        select(Producto)
        .where(
            Producto.nombre.ilike(patron)
            | Producto.codigo_barras.ilike(patron)
            | Producto.codigo_factura.ilike(patron)
            | Producto.codigo_interno.ilike(patron)
        )
        .order_by(Producto.nombre)
        .limit(200)
    )
    result = await db.execute(query)
    return ok([ProductoOut.model_validate(p).model_dump() for p in result.scalars()])


@router.post("/empresas/{empresa_id}/productos")
async def crear(
    empresa_id: int,
    body: ProductoCreate,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _empresa_o_404(empresa_id, db)
    producto = Producto(empresa_id=empresa_id, **body.model_dump())
    db.add(producto)
    await db.commit()
    await db.refresh(producto)
    return ok(ProductoOut.model_validate(producto).model_dump())


@router.post("/empresas/{empresa_id}/productos/importar")
async def importar(
    empresa_id: int,
    items: List[ProductoImportItem],
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Importación masiva desde XML DIAN ya parseado por el cliente.

    Deduplicación igual que v1: primero por codigo_factura, luego por
    codigo_barras. Si existe se actualiza precio/nombre y se suma la
    cantidad; si no, se crea.
    """
    await _empresa_o_404(empresa_id, db)
    parsed = items

    result = await db.execute(select(Producto).where(Producto.empresa_id == empresa_id))
    existentes = list(result.scalars())
    por_codigo_factura = {p.codigo_factura: p for p in existentes if p.codigo_factura}
    por_codigo_barras = {p.codigo_barras: p for p in existentes if p.codigo_barras}

    creados, actualizados = 0, 0
    for item in parsed:
        producto = None
        if item.codigo_factura and item.codigo_factura in por_codigo_factura:
            producto = por_codigo_factura[item.codigo_factura]
        elif item.codigo_barras and item.codigo_barras in por_codigo_barras:
            producto = por_codigo_barras[item.codigo_barras]

        if producto is not None:
            producto.nombre = item.nombre
            producto.precio = item.precio
            producto.cantidad_productos += item.cantidad
            producto.tiene_descuento = item.tiene_descuento
            if item.codigo_barras and not producto.codigo_barras:
                producto.codigo_barras = item.codigo_barras
            actualizados += 1
        else:
            producto = Producto(
                empresa_id=empresa_id,
                codigo_factura=item.codigo_factura,
                codigo_barras=item.codigo_barras,
                nombre=item.nombre,
                cantidad_productos=item.cantidad,
                precio=item.precio,
                tiene_descuento=item.tiene_descuento,
            )
            db.add(producto)
            if item.codigo_factura:
                por_codigo_factura[item.codigo_factura] = producto
            if item.codigo_barras:
                por_codigo_barras[item.codigo_barras] = producto
            creados += 1

    await db.commit()
    return ok({"creados": creados, "actualizados": actualizados})


@router.get("/empresas/{empresa_id}/productos/export.xlsx")
async def exportar(
    empresa_id: int,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    empresa = await _empresa_o_404(empresa_id, db)
    result = await db.execute(
        select(Producto).where(Producto.empresa_id == empresa_id).order_by(Producto.nombre)
    )
    buffer = inventario_a_xlsx(empresa, list(result.scalars()))
    nombre = f"inventario-{empresa.nit}.xlsx"
    return StreamingResponse(
        buffer,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{nombre}"'},
    )


@router.put("/productos/{producto_id}")
async def actualizar(
    producto_id: int,
    body: ProductoUpdate,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    producto = await _producto_o_404(producto_id, db)
    for campo, valor in body.model_dump(exclude_unset=True).items():
        setattr(producto, campo, valor)
    await db.commit()
    await db.refresh(producto)
    return ok(ProductoOut.model_validate(producto).model_dump())


@router.delete("/productos/{producto_id}")
async def eliminar(
    producto_id: int,
    _: Usuario = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    producto = await _producto_o_404(producto_id, db)
    await db.delete(producto)
    await db.commit()
    return ok(True)
