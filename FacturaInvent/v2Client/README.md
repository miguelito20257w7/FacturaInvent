# v2Client — FacturaInvent v2 networking foundation

Additive Swift networking layer for the v2 backend (`api.swiftydevs.dev`).

> **Not wired into the v1 Xcode target on purpose.** These files are not added to
> any build, so they cannot affect the production v1 app. They have **not** been
> compiled/verified — review and add them to a dedicated v2 target before use.

## Files
- `APIClient.swift` — async JSON client: bearer auth, snake_case ⇄ camelCase,
  ISO8601 dates, one-shot 401→`/auth/refresh` retry, raw-XML POST for invoice parse.
- `TokenStore.swift` — Keychain storage for access + refresh tokens (actor).
- `DTOs.swift` — Codable models mirroring the FastAPI schemas (auth, supplier,
  product, invoice parse).
- `AuthService.swift` — `login` / `logout` / `requestPasswordReset`, plus a
  `CatalogService` example showing authorized GETs and the raw-XML parse call.

## Integrate
1. Create a v2 app target (keep v1 untouched until cutover).
2. Add these files to that target.
3. Use it:
   ```swift
   let auth = AuthService()
   try await auth.login(email: "owner@…", password: "…")
   let suppliers = try await CatalogService().suppliers(query: "Posto")
   ```

## Not yet covered (next slices)
- Cashier device-binding flow (`/auth/admin-device-login`, `/device-bindings`,
  `/auth/cashier-login`) and shift screens.
- Gmail ingestion, XLSX export download, products/suppliers write DTOs.
- Reusing v1's SwiftUI views with these services as the data source.
