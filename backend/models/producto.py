from typing import Optional

from sqlalchemy import Boolean, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


class Producto(Base):
    __tablename__ = "productos"
    __table_args__ = (UniqueConstraint("empresa_id", "codigo_factura"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    empresa_id: Mapped[int] = mapped_column(ForeignKey("empresas.id", ondelete="CASCADE"))
    codigo_factura: Mapped[Optional[str]] = mapped_column(String(100))
    codigo_barras: Mapped[Optional[str]] = mapped_column(String(100))
    nombre: Mapped[str] = mapped_column(String(255))
    cantidad_productos: Mapped[int] = mapped_column(Integer, default=0)
    precio: Mapped[int] = mapped_column(Integer, default=0)
    precio_dividido: Mapped[int] = mapped_column(Integer, default=1)
    viene_en_paquetes: Mapped[bool] = mapped_column(Boolean, default=False)
    cantidad_paquetes: Mapped[int] = mapped_column(Integer, default=1)
    codigo_interno: Mapped[Optional[str]] = mapped_column(String(100))
    tiene_descuento: Mapped[bool] = mapped_column(Boolean, default=False)
    codigo_barras_automatico: Mapped[bool] = mapped_column(Boolean, default=False)

    empresa: Mapped["Empresa"] = relationship(back_populates="productos")  # noqa: F821
