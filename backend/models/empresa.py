from datetime import datetime
from typing import List

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


class Empresa(Base):
    __tablename__ = "empresas"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(255))
    nit: Mapped[str] = mapped_column(String(50), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    productos: Mapped[List["Producto"]] = relationship(  # noqa: F821
        back_populates="empresa", cascade="all, delete-orphan"
    )
