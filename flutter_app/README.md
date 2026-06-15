# FacturaInvent 2 — Cliente Flutter (Windows / Linux / Android)

Mismo backend FastAPI que la app iOS/macOS (`backend/`). Este scaffold cubre:

- Onboarding de servidor con "Probar conexión" (GET /health)
- Login JWT contra `/auth/login`
- **Cuadre de caja**: formulario con denominaciones en tiempo real y
  sobrante/faltante (verde/rojo), usando la fórmula verificada del Excel
- Historial con filtro por usuario y detalle
- Empresas y productos (lectura)
- Ajustes con URL del servidor en caliente

## Cómo correrlo

Flutter no está instalado en esta máquina, así que el proyecto aún no se ha
compilado. Para usarlo:

```bash
# 1. Instalar Flutter (https://docs.flutter.dev/get-started/install)
# 2. Generar las carpetas de plataforma dentro de flutter_app/:
cd flutter_app
flutter create . --project-name facturainvent2
# 3. Dependencias y arranque
flutter pub get
flutter run
```

`flutter create .` genera `android/`, `windows/`, `linux/`, etc. sin tocar
`lib/` ni `pubspec.yaml`.

## Pendiente (paridad completa con iOS)

- Cola offline de cuadres (en iOS: `ColaCuadresOffline.swift`)
- Importar XML DIAN (el parser vive en el cliente en iOS; en Flutter se puede
  usar `package:xml` o mover el parseo al backend)
- Integración Gmail (`google_sign_in` en Android; en Windows/Linux requiere
  flujo OAuth de escritorio)
- Exportar Excel (descargar `/cuadres/export.xlsx` y abrirlo con el sistema)
- CRUD completo de empresas/productos (hoy solo lectura)
