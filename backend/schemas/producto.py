from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ProductoCreate(BaseModel):
    codigo_factura: Optional[str] = None
    codigo_barras: Optional[str] = None
    nombre: str = Field(min_length=1, max_length=255)
    cantidad_productos: int = 0
    precio: int = 0
    precio_dividido: int = 1
    viene_en_paquetes: bool = False
    cantidad_paquetes: int = 1
    codigo_interno: Optional[str] = None
    tiene_descuento: bool = False
    codigo_barras_automatico: bool = False


class ProductoUpdate(BaseModel):
    codigo_factura: Optional[str] = None
    codigo_barras: Optional[str] = None
    nombre: Optional[str] = None
    cantidad_productos: Optional[int] = None
    precio: Optional[int] = None
    precio_dividido: Optional[int] = None
    viene_en_paquetes: Optional[bool] = None
    cantidad_paquetes: Optional[int] = None
    codigo_interno: Optional[str] = None
    tiene_descuento: Optional[bool] = None
    codigo_barras_automatico: Optional[bool] = None


class ProductoImportItem(BaseModel):
    """Un producto parseado del XML DIAN para importación masiva.

    Deduplicación (misma lógica que v1): si ya existe un producto de la
    empresa con el mismo codigo_factura o codigo_barras, se actualiza y se
    suma la cantidad; si no, se crea.
    """

    codigo_factura: Optional[str] = None
    codigo_barras: Optional[str] = None
    nombre: str
    cantidad: int = 0
    precio: int = 0
    tiene_descuento: bool = False


class ProductoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    empresa_id: int
    codigo_factura: Optional[str]
    codigo_barras: Optional[str]
    nombre: str
    cantidad_productos: int
    precio: int
    precio_dividido: int
    viene_en_paquetes: bool
    cantidad_paquetes: int
    codigo_interno: Optional[str]
    tiene_descuento: bool
    codigo_barras_automatico: bool
