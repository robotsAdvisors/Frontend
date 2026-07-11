# Documentación de Pantallas — letdem (Frontend Flutter)

Referencia técnica de **todas las pantallas** de la app `letdem` (Flutter + GetX). Cada pantalla documenta: archivo, ruta, controller/binding, propósito, contenido/widgets, endpoints del backend que consume, estados (loading/error/vacío/éxito), navegación y notas.

- **Arquitectura:** GetX (rutas en [`lib/app/routes/app_pages.dart`](../../lib/app/routes/app_pages.dart) y [`app_routes.dart`](../../lib/app/routes/app_routes.dart)).
- **Backend:** Django REST. Config centralizada en [`lib/utils/api_config.dart`](../../lib/utils/api_config.dart). `baseUrl` por defecto `https://api.letdem.net`, prefijo `/api/v1` (configurable con `--dart-define=LETDEM_API_BASE_URL`).
- **Cliente HTTP:** [`ApiClient`](../../lib/app/data/services/http/api_client.dart) (Dio singleton con auto-`Bearer`, refresh de token en 401 y `toApiException`).
- **Pantalla inicial:** `/splash` (`AppPages.INITIAL`).
- **Documento relacionado:** [`../PRD_panel_admin.md`](../PRD_panel_admin.md) — requisitos funcionales (QA) del panel admin de tienda.

## Grupos

| # | Grupo | Pantallas | Documento |
|---|-------|:---------:|-----------|
| 01 | Auth & Onboarding | 4 | [01-auth-onboarding.md](01-auth-onboarding.md) |
| 02 | Cliente / Marketplace | 7 | [02-cliente-marketplace.md](02-cliente-marketplace.md) |
| 03 | Cuenta & Wallet | 6 | [03-cuenta-wallet.md](03-cuenta-wallet.md) |
| 04 | Calendar (misc) | 1 | [04-parking.md](04-parking.md) |
| 05 | Admin de tienda | 12 | [05-admin-tienda.md](05-admin-tienda.md) |
| 06 | General Admin / Backoffice | 10 | [06-general-admin-backoffice.md](06-general-admin-backoffice.md) |
| | **Total** | **40** | |

> **Parking eliminado por completo** de este frontend backoffice el 2026-07-11 (pantallas, modelos, repositorio, endpoints y features incidentales). Esa funcionalidad vive solo en el frontend de la app móvil. Ver [04-parking.md](04-parking.md).

## Mapa de rutas → pantallas

| Ruta | Pantalla | Módulo | Controller | Grupo |
|------|----------|--------|------------|:-----:|
| `/splash` | Splash (inicial) | `splash` | `SplashController` | 01 |
| `/welcome` | Bienvenida | `welcome` | `WelcomeController` (vacío) | 01 |
| `/login` | Inicio de sesión | `login` | `LoginController` | 01 |
| `/forgot-password` | Recuperar contraseña | `login` | — (StatefulWidget) | 01 |
| `/base` | Contenedor con tabs | `base` | `BaseController` | 02 |
| `/home` | Home / Descubrir | `home` | `HomeController` | 02 |
| `/category` | Categoría | `category` | `CategoryController` (vacío) | 02 |
| `/products` | Catálogo de productos | `products` | `ProductsController` | 02 |
| `/product-details` | Detalle de producto | `product_details` | `ProductDetailsController` | 02 |
| `/cart` | Carrito | `cart` | `CartController` | 02 |
| `/stores` | Tiendas | `stores` | `StoresController` | 02 |
| `/profile` | Mi perfil | `profile` | `ProfileController` | 03 |
| `/change-password` | Cambiar contraseña | `profile` | — (StatefulWidget) | 03 |
| `/preferences` | Preferencias | `profile` | — (StatefulWidget) | 03 |
| `/virtual-card` | Mi tarjeta virtual | `virtual_card` | `VirtualCardController` | 03 |
| `/withdrawals` | Retirar fondos | `withdrawals` | `WithdrawalsController` | 03 |
| `/customer-history` | Mis recompensas | `customer_history` | `CustomerHistoryController` | 03 |
| `/calendar` | Calendario | `calendar` | `CalendarController` (vacío) | 04 |
| `/admin` | Dashboard de tienda | `admin` | `AdminController` | 05 |
| `/analytics` | Analytics | `admin` | `AdminController` | 05 |
| `/inventario` | Inventario | `admin` | `AdminController` | 05 |
| `/premios` | Premios | `admin` | `AdminController` | 05 |
| `/add-product` | Añadir/Editar producto | `admin` | `AdminController` | 05 |
| `/reviews` | Reseñas | `admin` | `ReviewsController` | 05 |
| `/voucher-history` | Historial de canjes | `admin` | `AdminController` | 05 |
| `/admin-settings` | Configuración | `admin` | `AdminController` | 05 |
| `/admin/empleados` | Empleados | `admin` | `AdminController` | 05 |
| `/admin/seguridad` | Seguridad | `admin` | `AdminController` | 05 |
| `/admin/incidencias` | Incidencias | `admin` | `AdminController` | 05 |
| `/admin/confirmar-entrega` | Confirmar entrega | `admin` | `AdminController` | 05 |
| `/general-admin` | Dashboard Backoffice | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/comercios` | Comercios | `general_admin` | `GeneralAdminController` | 06 |
| `/admin/users/detail` | Ficha de usuario | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/gdpr` | Solicitudes GDPR | `general_admin` | `GdprController` | 06 |
| `/backoffice/kybc` | KYBC (KYC/AML) | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/legal` | Legal & Consentimientos | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/politicas` | Políticas Sensibles | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/store-config` | Configuración de Tienda | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/pagos` | Disputas Stripe | `general_admin` | `GeneralAdminController` | 06 |
| `/backoffice/support` | Tickets de Soporte | `general_admin` | `SupportController` | 06 |

## Roles y acceso

El rol se obtiene de `AuthService` (`GET /users/me` es autoritativo) y decide el destino tras login:

| Rol | Destino tras login | Área |
|-----|--------------------|------|
| `customer` | `/base` | Cliente / Marketplace / Wallet |
| `store_admin`, `store_viewer` | `/admin` | Admin de tienda |
| `general_admin` | `/general-admin` | Backoffice de plataforma |

## Hallazgos transversales (detectados al documentar)

Puntos que conviene revisar; ninguno bloquea la compilación, pero afectan a comportamiento o completitud:

- **Controllers vacíos / pantallas placeholder:** `CategoryController`, `CalendarController` y `WelcomeController` están vacíos. `Category` y `Calendar` son stubs (`NoData`) sin datos reales.
- **Parking eliminado (resuelto):** las pantallas `/bookings` y `/update-parking` estaban huérfanas. El 2026-07-11 se eliminó de este frontend **todo** lo relativo a parking (pantallas, `booking_repository.dart`, modelos `booking_model`/`parking_spot_model`, métodos de repositorio, endpoints de `ApiConfig` y features incidentales de notificaciones/tarjeta virtual). Reservado al frontend de la app móvil.
- **Carrito y contadores locales:** el carrito y su badge se basan en `DummyHelper` en memoria, no en el backend. El botón "Redeem Points Now" del detalle de producto solo incrementa la cantidad en el carrito local; no genera voucher ni ejecuta compra.
- **Pantallas sin controller/binding GetX:** `forgot_password`, `change_password` y `preferences` son `StatefulWidget` que llaman a `AuthRepository.instance` directamente.
- **Patrón dummy → backend (admin):** las vistas de `/admin/*` arrancan con datos dummy y los reemplazan por datos reales cuando `storeId` deja de empezar por `store_`. Ninguna llamada al backend debe ejecutarse mientras `storeId` sea dummy.
- **Errores HTTP "silenciosos":** `ApiClient` usa `validateStatus: (s) => s != null`, así que Dio **no lanza en 4xx/5xx**; los métodos de repositorio degradan a lista vacía/`null` en vez de propagar el error a la UI (solo los fallos de red genuinos lanzan `ApiException`).
- **Botones/acciones pendientes:** varios placeholders sin acción — enlaces de footer en login (Términos/Privacidad/Ayuda), "Add to Wallet"/"PDF"/rating en recompensas, exportar/filtros y cambiar/cancelar plan en backoffice, escáner QR en confirmar-entrega, subida de fotos en actualizar-aparcamiento, verificación de cuenta en retiros.
- **Endpoints marcados "no determinado":** algún flujo (p. ej. data subject requests dentro de Legal, y ciertos listados de incidencias/KYC) tiene el endpoint exacto pendiente en el código; se anotó como tal sin inventar rutas.
- **Inconsistencia de idioma:** `forgot_password` tiene la UI en inglés; el resto de la app está en español.

---

_Generado el 2026-07-11. Fuente de verdad: código en `lib/`. Ante discrepancias, prevalece el código._
