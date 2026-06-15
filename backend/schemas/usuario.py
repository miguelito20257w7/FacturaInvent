from pydantic import BaseModel, ConfigDict, Field


class LoginRequest(BaseModel):
    username: str
    password: str


class UsuarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nombre: str
    username: str
    rol: str


class LoginResponse(BaseModel):
    token: str
    usuario: UsuarioOut


class UsuarioCreate(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=4)
    rol: str = Field(default="cajero", pattern="^(cajero|admin)$")
