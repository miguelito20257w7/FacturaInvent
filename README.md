# FacturaInvent

Aplicación nativa de iOS / iPadOS / macOS (Mac Catalyst) para gestión de
inventario y facturación. Importa facturas electrónicas en formato XML
(estándar DIAN de Colombia) y exporta reportes a Excel (XLSX).

## Tecnologías

- **Swift / SwiftUI** — UI nativa para iOS, iPadOS y macOS (Mac Catalyst)
- **SwiftData + CloudKit** — persistencia local con sincronización en iCloud
- **Swift Package Manager (SPM)** — gestión de dependencias (`GoogleSignIn`, `ZIPFoundation`)
- **Gmail API + Google Sign-In** — importación de facturas desde el correo
- **Xcode Cloud** — integración y compilación continua

## Estructura del proyecto

```
FacturaInvent/                 # Código fuente de la app
├── FacturaInventApp.swift     # Punto de entrada (SwiftData + CloudKit)
├── AppState.swift             # Estado global (patrón @Observable)
├── modelos.swift              # Modelos SwiftData (Empresa, Producto)
├── ImportarBaseDeDatos.swift  # Importación de base de datos
├── XMLFacturaParser.swift     # Parseo de facturas XML (formato DIAN)
├── agregarXML.swift           # Flujo de importación de XML
├── exportarExcel.swift /      # Exportación de reportes a XLSX
│   convertirAExcel.swift
├── Gmail*.swift / mailView.swift  # Integración con Gmail
└── ...                        # Pantallas y vistas (SwiftUI)

FacturaInvent.xcodeproj        # Proyecto Xcode (dependencias SPM)
FacturaInvent.xcworkspace      # Workspace
FacturaInventTests/            # Tests unitarios
FacturaInventUITests/          # Tests de interfaz
```

Las dependencias SPM (`GoogleSignIn` 9.1.0 y `ZIPFoundation` 0.9.20) están
declaradas en el proyecto; Xcode las resuelve automáticamente al abrirlo. Las
versiones quedan fijadas en
`FacturaInvent.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

## Funcionalidades

- Importación de facturas electrónicas XML (estándar DIAN Colombia)
- Gestión de base de datos de productos por empresa
- Importación de facturas desde Gmail
- Exportación de reportes a XLSX
- Sincronización en la nube con CloudKit
- Soporte para macOS vía Mac Catalyst

## Requisitos

- Xcode 16+
- iOS / iPadOS 26+ (`IPHONEOS_DEPLOYMENT_TARGET = 26.0`)
- Cuenta de Apple Developer con CloudKit habilitado

## Configuración

1. Clona el repositorio.
2. Abre **`FacturaInvent.xcodeproj`** (o `FacturaInvent.xcworkspace`) en Xcode;
   las dependencias SPM se resuelven automáticamente.
3. Elige un simulador o "My Mac (Mac Catalyst)" y ⌘R.
