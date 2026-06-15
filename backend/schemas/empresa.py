from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class EmpresaCreate(BaseModel):
    nombre: str = Field(min_length=1, max_length=255)
    nit: str = Field(min_length=1, max_length=50)


class EmpresaUpdate(BaseModel):
    nombre: Optional[str] = Field(default=None, min_length=1, max_length=255)
    nit: Optional[str] = Field(default=None, min_length=1, max_length=50)


class EmpresaOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nombre: str
    nit: str
    created_at: datetime
