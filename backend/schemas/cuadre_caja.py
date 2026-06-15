from datetime import date, datetime, time
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

JORNADAS = ("MAÑANA", "TARDE", "TODO EL DIA")


class CuadreCajaCreate(BaseModel):
    # numero_turno y base_anterior son opcionales: si no vienen, el servidor
    # los calcula a partir del último turno registrado. El cliente los manda
    # cuando creó el cuadre offline y ya se los había mostrado al cajero.
    numero_turno: Optional[int] = None
    fecha: date
    hora: time
    jornada: str = Field(pattern="^(MAÑANA|TARDE|TODO EL DIA)$")

    ventas_netas: int = Field(default=0, ge=0)
    entregas: int = Field(default=0, ge=0)
    tarjetas: int = Field(default=0, ge=0)
    bonos: int = Field(default=0, ge=0)
    nequi_qr: int = Field(default=0, ge=0)
    fact_electronica_credito: int = Field(default=0, ge=0)
    base_del_dia: int = Field(default=0, ge=0)
    base_anterior: Optional[int] = Field(default=None, ge=0)

    billetes_20000: int = Field(default=0, ge=0)
    billetes_10000: int = Field(default=0, ge=0)
    billetes_5000: int = Field(default=0, ge=0)
    billetes_2000: int = Field(default=0, ge=0)
    billetes_1000: int = Field(default=0, ge=0)
    monedas_500: int = Field(default=0, ge=0)
    monedas_200: int = Field(default=0, ge=0)
    monedas_100: int = Field(default=0, ge=0)
    monedas_50: int = Field(default=0, ge=0)


class CuadreCajaOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    numero_turno: int
    fecha: date
    hora: time
    usuario_id: Optional[int]
    usuario_nombre: Optional[str]
    jornada: str

    ventas_netas: int
    entregas: int
    tarjetas: int
    bonos: int
    nequi_qr: int
    fact_electronica_credito: int
    base_del_dia: int
    base_anterior: int

    billetes_20000: int
    billetes_10000: int
    billetes_5000: int
    billetes_2000: int
    billetes_1000: int
    monedas_500: int
    monedas_200: int
    monedas_100: int
    monedas_50: int

    total_denominaciones: int
    sobrante_faltante: int
    created_at: datetime


class NuevoTurnoOut(BaseModel):
    """Datos para iniciar un cuadre nuevo: turno siguiente y base anterior
    (la base del día del último turno registrado)."""

    numero_turno: int
    base_anterior: int
