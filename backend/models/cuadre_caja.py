from datetime import date, datetime, time
from typing import Optional

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    Computed,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Time,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from database import Base

# Fórmula verificada contra las 1010 filas del Excel CUADRE CAJA-1.xlsm:
# sobrante/faltante = base_del_dia + entregas + tarjetas + bonos + nequi_qr
#                     + fact_electronica_credito - ventas_netas - base_anterior
# (en el Excel BONOS y NEQUI O QR son la misma columna; aquí van separadas
# y ambas cuentan como pago no-efectivo)

DENOMINACIONES = {
    "billetes_20000": 20000,
    "billetes_10000": 10000,
    "billetes_5000": 5000,
    "billetes_2000": 2000,
    "billetes_1000": 1000,
    "monedas_500": 500,
    "monedas_200": 200,
    "monedas_100": 100,
    "monedas_50": 50,
}

_TOTAL_DENOMINACIONES_SQL = " + ".join(
    f"{campo}*{valor}" for campo, valor in DENOMINACIONES.items()
)


class CuadreCaja(Base):
    __tablename__ = "cuadres_caja"
    __table_args__ = (
        CheckConstraint("jornada IN ('MAÑANA', 'TARDE', 'TODO EL DIA')", name="ck_jornada"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    numero_turno: Mapped[int] = mapped_column(Integer)
    fecha: Mapped[date] = mapped_column(Date)
    hora: Mapped[time] = mapped_column(Time)
    usuario_id: Mapped[Optional[int]] = mapped_column(ForeignKey("usuarios.id"))
    usuario_nombre: Mapped[Optional[str]] = mapped_column(String(100))  # desnormalizado para historial
    jornada: Mapped[str] = mapped_column(String(20))

    ventas_netas: Mapped[int] = mapped_column(BigInteger, default=0)
    entregas: Mapped[int] = mapped_column(BigInteger, default=0)
    tarjetas: Mapped[int] = mapped_column(BigInteger, default=0)
    bonos: Mapped[int] = mapped_column(BigInteger, default=0)
    nequi_qr: Mapped[int] = mapped_column(BigInteger, default=0)
    fact_electronica_credito: Mapped[int] = mapped_column(BigInteger, default=0)
    base_del_dia: Mapped[int] = mapped_column(BigInteger, default=0)
    base_anterior: Mapped[int] = mapped_column(BigInteger, default=0)

    billetes_20000: Mapped[int] = mapped_column(Integer, default=0)
    billetes_10000: Mapped[int] = mapped_column(Integer, default=0)
    billetes_5000: Mapped[int] = mapped_column(Integer, default=0)
    billetes_2000: Mapped[int] = mapped_column(Integer, default=0)
    billetes_1000: Mapped[int] = mapped_column(Integer, default=0)
    monedas_500: Mapped[int] = mapped_column(Integer, default=0)
    monedas_200: Mapped[int] = mapped_column(Integer, default=0)
    monedas_100: Mapped[int] = mapped_column(Integer, default=0)
    monedas_50: Mapped[int] = mapped_column(Integer, default=0)

    total_denominaciones: Mapped[int] = mapped_column(
        BigInteger, Computed(_TOTAL_DENOMINACIONES_SQL, persisted=True)
    )
    sobrante_faltante: Mapped[int] = mapped_column(BigInteger, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    def calcular_sobrante_faltante(self) -> int:
        return (
            self.base_del_dia
            + self.entregas
            + self.tarjetas
            + self.bonos
            + self.nequi_qr
            + self.fact_electronica_credito
            - self.ventas_netas
            - self.base_anterior
        )
