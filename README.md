# FacturaInvent

Sistema de gestión de inventario y facturación que importa facturas electrónicas en formato XML (DIAN) y exporta reportes en XLSX. Disponible en iOS, Android y Desktop.

## Tecnologías

- **Flutter / Dart** — UI multiplataforma (iOS, Android, Windows, macOS, Linux)
- **Swift** — Implementación nativa iOS complementaria
- **Firebase** — Autenticación y Firestore como base de datos
- **Riverpod** — Gestión de estado
- **Go Router** — Navegación
- **xml** — Parseo de facturas XML (formato DIAN)
- **excel** — Exportación a XLSX

## Estructura del proyecto

```
facturainvent_flutter/         # App Flutter principal
├── lib/
│   ├── features/             # Módulos por funcionalidad
│   ├── models/               # Modelos con Freezed + JSON serializable
│   └── main.dart

FacturaInvent/                 # Implementación Swift (iOS)
├── AppState.swift             # Estado global (patrón Observable)
├── ImportarBaseDeDatos.swift  # Lógica de importación
├── modelos.swift              # Modelos de datos
└── FacturaJSONFormat.swift    # Formato JSON/factura
```

## Funcionalidades

- Importación de facturas electrónicas XML (estándar DIAN Colombia)
- Gestión de base de datos de productos
- Exportación de reportes a XLSX
- Sincronización en la nube con Firestore
- Soporte para Desktop (window_manager)
- Selector de archivos nativo por plataforma

## Requisitos

- Flutter SDK `>=3.0.0`
- Firebase configurado para el proyecto
- Xcode 15+ (para build iOS/macOS)

## Configuración

1. Clona el repositorio
2. Agrega los archivos de configuración de Firebase:
   - `google-services.json` → carpeta Android
   - `GoogleService-Info.plist` → carpeta iOS
3. Instala dependencias y genera código:
   ```bash
   cd facturainvent_flutter
   flutter pub get
   dart run build_runner build
   ```
4. Ejecuta:
   ```bash
   flutter run
   ```
