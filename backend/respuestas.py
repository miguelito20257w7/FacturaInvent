from typing import Any


def ok(data: Any):
    """Envelope estándar de la API: { "data": ..., "error": null }"""
    return {"data": data, "error": None}
