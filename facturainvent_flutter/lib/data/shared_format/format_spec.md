# FacturaInvent — Formato JSON compartido (v1)

Este formato permite que la app Swift original y el port en Flutter
intercambien datos sin depender del archivo `.store` propietario de
SwiftData.

## Esquema

```json
{
  "version": 1,
  "exportedAt": "2026-05-19T18:00:00Z",
  "empresas": [
    {
      "nit": "string",
      "nombre": "string",
      "productos": [
        {
          "codigoFactura": "string",
          "codigoBarras": "string",
          "nombre": "string",
          "codigoDeBarrasAutomatico": false,
          "cantidadProductos": 0,
          "precio": 0,
          "precioDividido": 1,
          "vieneEnPaquetes": false,
          "cantidadPaquetes": 1,
          "codigoInterno": "string",
          "tieneDescuento": false
        }
      ]
    }
  ]
}
```

## Notas de compatibilidad

- `nit` actúa como llave única de empresa.
- En Firestore se persiste cada empresa/producto como documento independiente
  con `empresaId` apuntando al doc parent.
- En SwiftData la relación es `producto.empresa` (referencia).
- Al importar: la app debe **borrar la DB local** y **reinsertar todo**
  (mismo comportamiento que `ImportarBaseDeDatos.swift`).

## En la app Swift (port pendiente)

```swift
struct FacturaJSON: Codable {
    let version: Int
    let exportedAt: String
    let empresas: [EmpresaJSON]
}
struct EmpresaJSON: Codable {
    let nit: String
    let nombre: String
    let productos: [ProductoJSON]
}
struct ProductoJSON: Codable {
    let codigoFactura: String
    let codigoBarras: String
    let nombre: String
    let codigoDeBarrasAutomatico: Bool
    let cantidadProductos: Int
    let precio: Int
    let precioDividido: Int
    let vieneEnPaquetes: Bool
    let cantidadPaquetes: Int
    let codigoInterno: String
    let tieneDescuento: Bool
}
```
