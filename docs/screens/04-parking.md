# 04 · Calendar (misceláneo)

Todo lo relativo a **parking** fue **eliminado de este frontend (backoffice)** el 2026-07-11; esa funcionalidad vive únicamente en el frontend de la app móvil. Este grupo conserva solo una pantalla suelta, un placeholder de calendario que no está relacionado con parking.

---

### Calendar (`/calendar`)
- **Archivo:** `lib/app/modules/calendar/views/calendar_view.dart`
- **Ruta:** `/calendar` (constante `Routes.CALENDAR`)
- **Controller / Binding:** `CalendarController` / `CalendarBinding` (`Get.lazyPut`)
- **Propósito:** Pantalla placeholder de calendario. Actualmente no implementa funcionalidad real.
- **Contenido / widgets clave:** `Scaffold` con `AppBar` titulado "Calendar" (centrado) y cuerpo con el componente `NoData(text: 'This is Calendar Screen')`. Sin listas, formularios ni lógica.
- **Endpoints backend consumidos:** ninguno (`CalendarController` está vacío, sin llamadas al repositorio).
- **Estados manejados:** ninguno (no hay estados reactivos; el controller es una clase vacía).
- **Navegación:** Se llega desde `lib/app/modules/home/views/home_view.dart` (línea ~570) mediante `Get.toNamed(Routes.CALENDAR)`. No navega a ninguna otra pantalla.
- **Notas:** Pantalla stub / en construcción. `CalendarController extends GetxController {}` sin propiedades ni métodos. Texto de UI en inglés. Candidata a implementación futura.

---

## Parking — eliminado por completo (registro histórico)

El **2026-07-11** se eliminó de este frontend backoffice todo lo relativo a parking. Este panel no debe contener ninguna pantalla ni lógica de parking (reservado al frontend de la app).

**Pantallas eliminadas:**
- **Mis reservas (`/bookings`)** — listado de reservas de plaza con filtro por estado y cancelación.
- **Actualizar aparcamiento (`/update-parking`)** — reporte colaborativo del tiempo de espera de una plaza.

**Código de soporte eliminado:**
- Módulos completos `lib/app/modules/bookings/` y `lib/app/modules/update_parking/` (vistas, controllers, bindings).
- Rutas `Routes.BOOKINGS` / `Routes.UPDATE_PARKING` y sus `GetPage` en `app_pages.dart`.
- Repositorio `lib/app/data/repositories/booking_repository.dart`.
- Modelos `lib/app/data/models/booking_model.dart` y `lib/app/data/models/parking_spot_model.dart`.
- Sección PARKING de `MarketplaceRepository` (`fetchParkingSpot`, `updateParkingReport`, `deleteParkingReport`).
- Endpoints de `ApiConfig`: `parkingSpots`, `parkingSpotDetail`, `parkingSpotReport`, `bookings`, `bookingDetail`, `bookingCancel`.
- Tests `test/models/booking_model_test.dart` y la aserción de `bookingCancel` en `test/utils/api_config_test.dart`.

**Features incidentales de parking también eliminadas:**
- Preferencia de notificación "Alerta de aparcamiento" (`parking_alert`) en la pantalla de Preferencias, y su categoría `'parking'` en `MySharedPref.getNotificationPrefs()`.
- Beneficio `priority_parking` de la tarjeta virtual (icono en `virtual_card_view.dart` y ejemplo en el comentario de `virtual_card_model.dart`).

Sin referencias a parking/booking/spot restantes en `lib/` ni `test/`.
