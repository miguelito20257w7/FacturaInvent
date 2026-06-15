# FacturaInvent 2 — App iOS / macOS (Mac Catalyst)

Cliente SwiftUI del backend FastAPI (`backend/`). Sin SwiftData ni CloudKit:
todo el dato vive en PostgreSQL en el servidor del supermercado.

## Compilar

El proyecto ya está generado en la raíz del repo: abre
**`FacturaInvent2.xcodeproj`** en Xcode, elige un simulador (o "My Mac
(Mac Catalyst)") y ⌘R. Verificado: compila para iOS Simulator y Mac Catalyst.

Por línea de comandos:

```bash
xcodebuild -project FacturaInvent2.xcodeproj -scheme FacturaInvent2 \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

El proyecto se define en `project.yml` (XcodeGen). Si agregas/renombras
archivos Swift fuera de Xcode, regenéralo con `xcodegen generate`
(binario en `/tmp/xcodegen/bin/xcodegen`, o `brew install xcodegen`).
Ya incluye:

- Paquetes SPM: GoogleSignIn 9.1.0 y ZIPFoundation 0.9.20 (mismas versiones que v1)
- ATS con `NSAllowsLocalNetworking` (el servidor es `http://` en la red local)
- El URL scheme invertido del client ID de Google (el mismo de v1)
- Team `WFLZKCYTXB` y bundle ID `Miguel.FacturaInvent2`
- Entitlements de sandbox/red solo para el build de Mac Catalyst
- Deployment target iOS 18 (se usan `Tab(value:role:)` y `@Observable`)

## Estructura

```
FacturaInvent2/
├── App/                 FacturaInvent2App (raíz: onboarding → login → main), AppState
├── Network/
│   ├── APIClient.swift          URLSession + JWT + envelope {data, error}
│   ├── ServerConfig.swift       URL configurable en caliente + probar conexión
│   ├── ColaCuadresOffline.swift cola offline-first de cuadres (JSON en Documents)
│   └── Endpoints/               Auth, Empresas, Productos, CuadreCaja
├── Models/              Codable puros: Empresa, Producto, CuadreCaja, Usuario
├── Parsers/             XMLFacturaParser (copiado de v1 sin cambios)
└── Views/
    ├── Main/            TabView (iOS) / NavigationSplitView (Catalyst) + menú
    ├── CuadreCaja/      Formulario (tiempo real) + Historial (filtros + export)
    ├── Empresas/ Productos/  CRUD vía API
    ├── Importar/        XML DIAN → preview → import masivo con dedup
    ├── Gmail/           OAuth2 + fetch de facturas (portado de v1)
    ├── Buscar/          búsqueda global servida por la API
    └── Ajustes/         Onboarding, Login y Ajustes (URL, probar conexión, estado)
```

## Detalles de comportamiento

- **Sobrante/faltante** (fórmula verificada contra el Excel original):
  `base_del_día + entregas + tarjetas + bonos + nequi_qr + fact_crédito − ventas_netas − base_anterior`
- **Turno y base anterior** los propone el servidor (`GET /cuadres/nuevo-turno`);
  la base anterior = base del día del último turno registrado.
- **Offline-first**: si al registrar un cuadre no hay conexión, queda en
  `Documents/cuadres-pendientes.json` y se sincroniza al abrir la app, al
  refrescar el historial o desde Ajustes.
- **Cambio de servidor en caliente**: `APIClient` lee `ServerConfig` en cada
  petición; cambiar la URL en Ajustes aplica de inmediato.
- **Ajustes**: ícono de engranaje en la toolbar (iOS) y menú de la app ⌘, (macOS).
- **Export a Excel**: lo genera el backend (`/cuadres/export.xlsx`,
  `/empresas/{id}/productos/export.xlsx`); la app lo descarga y abre el share sheet.

## Verificación

Todo el código pasa typecheck contra el SDK de iOS:

```bash
SDK=$(xcrun --show-sdk-path --sdk iphonesimulator)
find FacturaInvent2 -name "*.swift" -print0 | xargs -0 xcrun swiftc -typecheck \
  -sdk "$SDK" -target arm64-apple-ios18.0-simulator -I /tmp/fi2-stubs
```

(`/tmp/fi2-stubs` contiene stubs de GoogleSignIn/ZIPFoundation solo para el
typecheck; en Xcode se usan los paquetes reales.)
