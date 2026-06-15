"""Crea el usuario administrador inicial.

Uso:
    python seed.py                          # crea MIGUELITO/miguelito con contraseña pedida por consola
    python seed.py --username ana --nombre ANGELA --password 1234 --rol cajero
"""
import argparse
import asyncio
import getpass

from sqlalchemy import select

from database import SessionLocal, init_models
from models import Usuario
from security import hash_password


async def crear_usuario(nombre: str, username: str, password: str, rol: str):
    await init_models()
    async with SessionLocal() as db:
        existente = await db.execute(select(Usuario).where(Usuario.username == username))
        if existente.scalar_one_or_none() is not None:
            print(f"El usuario '{username}' ya existe, no se hace nada.")
            return
        db.add(
            Usuario(
                nombre=nombre.upper(),
                username=username.lower(),
                password_hash=hash_password(password),
                rol=rol,
            )
        )
        await db.commit()
        print(f"Usuario '{username}' ({rol}) creado.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--nombre", default="MIGUELITO")
    parser.add_argument("--username", default="miguelito")
    parser.add_argument("--password", default=None)
    parser.add_argument("--rol", default="admin", choices=["admin", "cajero"])
    args = parser.parse_args()

    password = args.password or getpass.getpass(f"Contraseña para {args.username}: ")
    asyncio.run(crear_usuario(args.nombre, args.username, password, args.rol))
