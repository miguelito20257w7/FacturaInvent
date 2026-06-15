from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from database import init_models
from respuestas import ok
from routers import auth, cuadre_caja, empresas, productos


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_models()
    yield


app = FastAPI(title="FacturaInvent 2 API", version="2.0.0", lifespan=lifespan)

# Las apps cliente viven en la red local del supermercado; CORS abierto
# solo importa para Flutter web durante desarrollo.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(status_code=exc.status_code, content={"data": None, "error": exc.detail})


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    primer_error = exc.errors()[0] if exc.errors() else {}
    campo = ".".join(str(p) for p in primer_error.get("loc", []) if p != "body")
    mensaje = f"Dato inválido en '{campo}': {primer_error.get('msg', 'error de validación')}"
    return JSONResponse(status_code=422, content={"data": None, "error": mensaje})


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500, content={"data": None, "error": f"Error interno: {type(exc).__name__}"}
    )


@app.get("/health")
async def health():
    """Endpoint sin auth para el botón 'Probar conexión' de las apps."""
    return ok({"status": "ok", "app": "FacturaInvent 2"})


app.include_router(auth.router)
app.include_router(empresas.router)
app.include_router(productos.router)
app.include_router(cuadre_caja.router)
