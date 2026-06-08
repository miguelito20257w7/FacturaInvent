# FacturaInvent — Flutter port

Port multiplataforma (iOS / macOS / Android / Windows / Linux) de la app
original FacturaInvent escrita en SwiftUI + SwiftData.

Importa facturas XML DIAN (Colombia), gestiona productos y empresas, y
exporta a XLSX listo para subir a un POS.

## Stack

- **State management**: Riverpod 2
- **Persistencia**: Cloud Firestore (sync entre dispositivos) + Firebase Auth anónimo
- **XML parsing**: `package:xml`
- **XLSX**: `package:excel`
- **i18n**: ARB files (EN / ES)
- **Desktop**: `window_manager` para min/ideal size

## Estructura

```
lib/
├── main.dart                       Entry point
├── app/
│   ├── app_state.dart              Providers globales (Riverpod)
│   ├── router.dart                 Root: WelcomeScreen vs MainShell
│   └── theme.dart                  Material 3 light/dark
├── models/                         Empresa, Producto, ProductoImport (freezed)
├── data/
│   ├── firestore/                  EmpresaRepository, ProductoRepository
│   └── shared_format/              JSON v1 compartido con la app Swift
├── services/
│   ├── auth_service.dart           Anonymous sign-in
│   ├── xml_factura_parser.dart     Port de XMLFacturaParser.swift
│   └── xlsx_exporter.dart          Port de exportarExcel.swift
├── features/
│   ├── welcome/                    Pantalla de bienvenida (isFirstLaunch)
│   ├── main_shell/                 NavBar/Rail adaptativo
│   ├── empresas/                   Lista + detalle
│   ├── crear/                      Importar XML + revisar
│   ├── exportar/                   Generar XLSX
│   ├── buscar/                     Búsqueda global
│   ├── producto/                   Preview/edit producto
│   └── shared/                     ImportDatabaseScreen (JSON)
└── l10n/
    ├── app_en.arb
    └── app_es.arb
```

## Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### Configurar Firebase (pendiente)

Antes de correr necesitas un proyecto Firebase. Instala
[FlutterFire CLI](https://firebase.flutter.dev/docs/cli) y corre:

```bash
flutterfire configure --project=<tu-project-id>
```

Eso genera `lib/firebase_options.dart`. Actualiza `main.dart` para usarlo:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Reglas de Firestore recomendadas:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Correr

```bash
flutter run -d macos       # macOS
flutter run -d chrome      # Web (con limitaciones de file_picker/share)
flutter run                # móvil con device/sim conectado
```

## Tests

```bash
flutter test
```

Hay tests unitarios del parser XML. Para regresión completa, añadir XMLs
DIAN reales a `test/fixtures/` y comparar con resultados del parser Swift.

## Diferencias respecto a la app Swift

| Swift                    | Flutter equivalente                                      |
|--------------------------|----------------------------------------------------------|
| SwiftData (`@Model`)     | Firestore docs + `freezed` models                        |
| CloudKit sync            | Firestore + Firebase Auth anonymous                      |
| `XMLParser` SAX          | `package:xml` `XmlEventReader`                           |
| `ZIPFoundation` + OOXML  | `package:excel` (genera XLSX válido pero diferente)      |
| `ShareLink`              | `share_plus`                                             |
| `fileImporter`           | `file_picker`                                            |
| `Localizable.xcstrings`  | ARB files                                                |
| `NavigationSplitView`    | `NavigationRail` (responsive según ancho)                |
| `.store` import/export   | JSON v1 compartido (ver `lib/data/shared_format/`)       |

## Pendientes / mejoras

- **Apple Sign-In** para iOS/macOS (obligatorio si se publica con login social).
- **Add Codable de FacturaJSON en la app Swift** para que ambas apps usen el
  mismo formato (ver `lib/data/shared_format/format_spec.md`).
- **Tests del parser** con XMLs reales contra resultados del parser Swift.
- **Menús macOS** con `MenuBar` para Cmd+1/2/3/4 entre tabs.
- **Drift offline cache** si se quiere experiencia offline-first más robusta
  que el cache built-in de Firestore.
