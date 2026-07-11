# 03 · Cuenta & Wallet

Este documento describe las pantallas del grupo **Cuenta & Wallet** de la app Flutter (GetX) "letdem": gestión del perfil del usuario, seguridad (cambio de contraseña), preferencias de notificación, tarjeta virtual de fidelización, retiro de fondos del monedero e historial de recompensas/compras del cliente. Todos los endpoints se resuelven contra el backend Django (`ApiConfig`, base `https://api.letdem.net/api/v1`).

---

### Mi perfil (`/profile`)
- **Archivo:** `lib/app/modules/profile/views/profile_view.dart`
- **Ruta:** `/profile` (constante `Routes.PROFILE`)
- **Controller / Binding:** `ProfileController` / `ProfileBinding` (`Get.lazyPut`)
- **Propósito:** Pantalla principal de la cuenta del cliente: muestra datos personales, nivel de membresía y puntos, permite editar el perfil, cambiar idioma/tema y acceder a acciones de cuenta (contraseña, cierre de sesión, baja).
- **Contenido / widgets clave:** Layout responsive (`_desktopLayout` ≥900px / `_mobileLayout`). Hero banner con avatar (editable vía `pickProfileImage`), nombre, badge de tier (Bronze/Silver/Gold según puntos), "Member since Oct 2023" y saldo de puntos con botón "Redeem Now" (sin acción). Tarjeta "Personal Information" con modo lectura/edición (`CustomFormField` para nombre, teléfono, dirección). Tarjeta "Membership Progress" (barra de progreso al siguiente tier). Fila de "stat cards" (Total Points, Rewards Redeemed, Active Missions). Tarjeta "Redemption History" (tabla). Tarjeta "Preferences" (selector de idioma Español/English, switch Dark Mode, enlace a Notification Preferences). Botones de acción: Change Password, Cerrar sesión, Darme de baja.
- **Endpoints backend consumidos:**
  - `GET /users/me` (`ApiConfig.me`) vía `AuthRepository.fetchMe()` — carga nombre, teléfono, dirección, email y puntos reales.
  - `PUT /users/me` (`ApiConfig.me`) vía `AuthRepository.updateMe()` — sincroniza el perfil al subir foto (`pickProfileImage`).
  - Tarjeta virtual "asignada": `AuthService.fetchAssignedVirtualCard()` — **datos dummy generados localmente** (no es una llamada HTTP; deriva el número del email del usuario).
- **Estados manejados:** Loading de tarjeta virtual (`isLoadingVirtualCard`); modo edición vs. lectura (`isEditingProfile`); validación de campos vacíos en `saveCustomerData`; fallback a datos locales/SharedPref si `fetchMe` falla. No hay estado de error visible dedicado (los fallos son silenciosos con `catch(_)`).
- **Navegación:** Se llega desde el menú/navegación principal de la app. Navega a: `Routes.PREFERENCES` (Notification Preferences), `Routes.CHANGE_PASSWORD` (botón Change Password). `logout()` → `Get.offAllNamed(Routes.LOGIN)`. `unsubscribeService()` (baja) → tras confirmar, `Get.offAllNamed(Routes.WELCOME)`.
- **Notas:** Rol destinatario: cliente (customer). Valores iniciales dummy en `ProfileController` ("Amelia Barlow", "+34 600 777 999", "Calle Mayor 88, Madrid") que se sobrescriben con datos de backend/SharedPref. Los puntos se leen de `BaseController.userPoints` y estadísticas de `HomeController.ordersStats` si están registrados. La "Redemption History" es **estática/hardcodeada** (3 filas fijas), igual que "Active Missions: 3" y el badge "+12%". El botón "Redeem Now" no tiene acción. Guardar perfil (`saveCustomerData`) solo persiste en `MySharedPref`, **no** hace PUT al backend (a diferencia de `pickProfileImage`). Idioma vía `LocalizationService`, tema vía `MyTheme.changeTheme()`.

---

### Cambiar contraseña (`/change-password`)
- **Archivo:** `lib/app/modules/profile/views/change_password_view.dart`
- **Ruta:** `/change-password` (constante `Routes.CHANGE_PASSWORD`)
- **Controller / Binding:** Ninguno (es un `StatefulWidget`; `GetPage` sin binding). Usa `AuthRepository.instance` directamente.
- **Propósito:** Permite al usuario autenticado cambiar su contraseña ingresando la actual y una nueva.
- **Contenido / widgets clave:** AppBar "Change Password". Ícono de candado en círculo, título "Update Password" y subtítulo. Tres campos de contraseña con toggle de visibilidad (`_passwordField`): Current Password, New Password, Confirm New Password. Botón "Update Password" (con spinner al guardar) y enlace "Forgot password".
- **Endpoints backend consumidos:** `PUT /users/me/change-password` (`ApiConfig.authChangePassword`) vía `AuthRepository.changePassword({currentPassword, newPassword})`.
- **Estados manejados:** Guardando (`_saving`, deshabilita botón y muestra `CircularProgressIndicator`); validación local (campos vacíos, mínimo 8 caracteres, coincidencia de contraseñas) con snackbar de error; éxito (snackbar verde "Password updated successfully!" y limpia campos); error (mensaje de `ApiException` o genérico vía `_showError`).
- **Navegación:** Se llega desde `ProfileView` (botón "Change Password"). Vuelve con `Get.back()`. Enlace "Forgot password" → `Routes.FORGOT_PASSWORD`. El ícono `more_vert` del AppBar no tiene acción.
- **Notas:** Colores hardcodeados (paleta morada `0xFF7C3AED`). Validación de longitud mínima solo en cliente (8 caracteres). Rol: cualquier usuario autenticado.

---

### Preferencias de notificación (`/preferences`)
- **Archivo:** `lib/app/modules/profile/views/preferences_view.dart`
- **Ruta:** `/preferences` (constante `Routes.PREFERENCES`)
- **Controller / Binding:** Ninguno (es un `StatefulWidget`; `GetPage` sin binding). Usa `AuthRepository.instance` directamente.
- **Propósito:** Gestiona las preferencias de notificaciones y tipos de alertas del usuario (email, push, y alertas de aparcamiento, policía, tráfico, marketplace, recompensas, clima, eventos, amigos).
- **Contenido / widgets clave:** Header con botón cerrar (`close`) y título "Preferences". Sección "Notifications" (Email Notifications, Push Notifications). Sección "Alert Types" con 9 filas de switches con íconos de color (`_alertRow`). Botón inferior "Save Preferences" (deshabilitado si no hay cambios o mientras guarda).
- **Endpoints backend consumidos:**
  - `GET /users/me` (`ApiConfig.me`) vía `AuthRepository.fetchMe()` + `AuthRepository.extractPreferences()` — carga estado inicial de cada preferencia.
  - `PUT /v1/users/me/preferences` (`ApiConfig.mePreferences`) vía `AuthRepository.changePreferenceAlert(type, value)` — se llama una vez por cada campo modificado (envía solo los cambios respecto al snapshot, en paralelo con `Future.wait`). Body: `{ "type": <clave>, "value": <bool> }`.
- **Estados manejados:** Loading inicial (`_loading`, muestra `CircularProgressIndicator`); guardando (`_saving`); detección de cambios (`_hasChanges` compara `_prefs` vs `_original`); éxito (snackbar morado y `Get.back()`); error (snackbar rojo). Si `fetchMe` falla, se muestran valores por defecto (con `catch`).
- **Navegación:** Se llega desde `ProfileView` (enlace "Notification Preferences"). Cierra con `Get.back()` (ícono `close` o tras guardar con éxito).
- **Notas:** Las claves del mapa `_prefs` coinciden exactamente con lo que espera `setattr()` en el backend (`email_notifications`, `push_notifications`, `parking_alert`, `police_alert`, `road_alert`, `traffic_alert`, `marketplace_alert`, `rewards_alert`, `weather_alert`, `events_alert`, `friends_alert`). Valores por defecto hardcodeados en el mapa inicial. Solo envía deltas para minimizar peticiones. El botón de ayuda (`question_mark`) del header no tiene acción.

---

### Mi tarjeta virtual (`/virtual-card`)
- **Archivo:** `lib/app/modules/virtual_card/views/virtual_card_view.dart`
- **Ruta:** `/virtual-card` (constante `Routes.VIRTUAL_CARD`)
- **Controller / Binding:** `VirtualCardController` / `VirtualCardBinding` (`Get.lazyPut`)
- **Propósito:** Muestra la tarjeta virtual de fidelización del usuario (puntos disponibles, código de barras, tier, beneficios) y permite activarla/desactivarla y presentar el código en un escáner.
- **Contenido / widgets clave:** `SliverAppBar` "Mi Tarjeta Virtual" con botón refrescar. Tarjeta visual con gradiente morado: logo "LetDem", tier, puntos disponibles (`_formatPoints`, formato "k"), código de barras dibujado con `CustomPaint` (`_BarcodePainter`, determinista a partir del código), nombre del titular y toggle Activa/Inactiva. Tarjeta "Cómo usar". Sección "Beneficios de miembro" (lista dinámica desde `card.benefits`, íconos según `benefit.key`). Botón inferior "Abrir escáner completo" que abre un `Get.bottomSheet` con el código de barras grande y chips de titular/tier. Estado de error dedicado (`_errorState`).
- **Endpoints backend consumidos:**
  - `GET /wallet/virtual-card/` (`ApiConfig.virtualCard`) vía `VirtualCardRepository.fetchCard()`.
  - `PATCH /wallet/virtual-card/` con body `{ "is_active": bool }` (`ApiConfig.virtualCard`) vía `VirtualCardRepository.toggleActive()`.
- **Estados manejados:** Loading (`isLoading`: spinner central si no hay tarjeta aún, o spinner en AppBar al refrescar); error/sin datos (`card == null` → `_errorState` con botón "Reintentar"); toggle en curso (`isToggling`, con **actualización optimista** y reversión si falla, mostrando `CustomSnackBar` de error); distinción entre `ApiException` (mensaje del backend) y fallo de conexión ("Sin conexión").
- **Navegación:** Se llega mediante `Get.toNamed(Routes.VIRTUAL_CARD)` (transición rightToLeft). Vuelve con `Get.back()`. El bottom sheet del escáner es un overlay modal (no cambia de ruta).
- **Notas:** Rol: cliente. El código de barras es una representación visual generada localmente (no un QR/barcode real de librería). Datos de la tarjeta (nombre, tier, puntos, beneficios) provienen del modelo `VirtualCardModel` del backend. Colores hardcodeados.

---

### Retirar fondos (`/withdrawals`)
- **Archivo:** `lib/app/modules/withdrawals/views/withdrawals_view.dart`
- **Ruta:** `/withdrawals` (constante `Routes.WITHDRAWALS`)
- **Controller / Binding:** `WithdrawalsController` / `WithdrawalsBinding` (`Get.lazyPut`)
- **Propósito:** Monedero del usuario: muestra saldo disponible, estado de verificación, métodos de cobro vinculados e historial de retiros; permite solicitar un retiro de fondos.
- **Contenido / widgets clave:** AppBar "Retirar fondos" con refrescar. Hero card con saldo (`€ x.xx`), badge Verificado/Sin verificar y pills de límites (instantáneo/1-3 días). Fila de stats (Total retirado, Pendientes, Completados). Sección "Método de retiro" (lista de `PayoutMethod` seleccionables, o `_noMethodsBanner` si vacía) + tarjeta informativa (`_quickInfoCard`). Sección "Historial de retiros" (lista de `_withdrawalTile` con estado coloreado, o `_emptyState`). Barra inferior "Retirar fondos" (habilitada según `canWithdraw`). Bottom sheet `_WithdrawAmountSheet`: input de importe con formateo, botón "Todo", checkbox "Retirar todo", chips de importe rápido (25/50/100/200) y botón de confirmación con validación.
- **Endpoints backend consumidos:**
  - `GET /wallet/withdrawals/` (`ApiConfig.withdrawals`) vía `WithdrawalRepository.fetchWithdrawals()` — historial.
  - `GET /wallet/withdrawals/config/` (`ApiConfig.withdrawalsConfig`) vía `WithdrawalRepository.fetchConfig()` — saldo, límites, verificación y métodos.
  - `POST /wallet/withdrawals/` con body `{ "method": <uuid>, "amount"?: <double> }` (`ApiConfig.withdrawals`) vía `WithdrawalRepository.requestWithdrawal()` (`amount` omitido = retirar todo).
- **Estados manejados:** Loading (`isLoading`, spinner central; carga config e historial en paralelo con `Future.wait` y `catchError` que resetea a valores vacíos); solicitud en curso (`isRequesting`, spinner en botón de confirmación); vacío (`_emptyState` sin retiros, `_noMethodsBanner` sin métodos); validaciones (importe < mínimo, importe > saldo, sin método → `CustomSnackBar` de error); éxito (inserta el retiro, descuenta saldo localmente, snackbar y `Get.back(result:true)`); `RefreshIndicator` para pull-to-refresh.
- **Navegación:** Se llega mediante `Get.toNamed(Routes.WITHDRAWALS)` (transición rightToLeft). Vuelve con `Get.back()`. El bottom sheet de importe es overlay modal.
- **Notas:** Rol: cliente. `canWithdraw` requiere cuenta verificada, saldo ≥ mínimo y método seleccionado. El texto del botón refleja el motivo de bloqueo ("Saldo insuficiente" / "Cuenta no verificada"). La verificación de cuenta muestra un snackbar "estará disponible próximamente" (funcionalidad pendiente / TODO). El saldo se actualiza de forma optimista tras el retiro. Moneda en euros. Modelos: `WithdrawalModel`, `WithdrawalConfig`, `PayoutMethod`, enum `WithdrawalStatus`.

---

### Mis recompensas / Historial del cliente (`/customer-history`)
- **Archivo:** `lib/app/modules/customer_history/views/customer_history_view.dart`
- **Ruta:** `/customer-history` (constante `Routes.CUSTOMER_HISTORY`)
- **Controller / Binding:** `CustomerHistoryController` / `CustomerHistoryBinding` (`Get.lazyPut`)
- **Propósito:** Muestra las recompensas (vouchers) del cliente: vouchers activos con QR para canjear en tienda, historial de vouchers canjeados/expirados (con valoración por estrellas) y las compras (órdenes) del usuario.
- **Contenido / widgets clave:** AppBar con logo "Letdem" y tabs (Marketplace / Earning / My Rewards). Cuerpo con gradiente. Sección de vouchers pendientes: tarjeta(s) tipo ticket (`_voucherCard`) con imagen de producto, badge de estado (Ready to Redeem / Redeemed / Expired), QR (`Image.network` del `qrCode` o placeholder `_qrPlaceholder`), puntos gastados, expiración y botones "Add to Apple Wallet" / "Download PDF Receipt"; `PageView` si hay varios. `_emptyState` si no hay pendientes. Sección "Historial" (`_historyTile` de vouchers pasados con estrellas de rating). Sección "Mis compras" (`_orderTile` con estado de orden y botón "Cargar más" paginado).
- **Endpoints backend consumidos:**
  - `GET /marketplace/vouchers/` (`ApiConfig.vouchers`) vía `MarketplaceRepository.fetchVouchers()` — vouchers del usuario; **con fallback a datos locales `DummyHelper`** si falla.
  - `GET /marketplace/orders/` (`ApiConfig.orders`, con `page`/`page_size`) vía `MarketplaceRepository.fetchOrders()` — compras paginadas (`OrdersPage`).
  - Wallet/tarjeta: `AuthService.fetchAssignedVirtualCard()` — **datos dummy locales** (no HTTP); solo alimenta `walletCode`.
- **Estados manejados:** Loading (`loadingWallet` / `loadingHistory` → spinner central; `loadingOrders`); carga de más órdenes (`loadingMoreOrders`, spinner o botón "Cargar más" si `meta.hasMore`); vacío (`_emptyState` "No tienes recompensas activas"); fallback silencioso a `DummyHelper` para vouchers y a lista vacía para órdenes si el backend falla; el rating se mantiene en memoria (`voucherRatings`).
- **Navegación:** Se llega mediante `Get.toNamed(Routes.CUSTOMER_HISTORY)`. No navega a otras rutas: los tabs del AppBar, íconos share/more y footer links ("Need help", "Find the Store") no tienen acción. Botones "Add to Apple Wallet" y "Download PDF Receipt" solo muestran snackbar "Próximamente".
- **Notas:** Rol: cliente. Categorización de vouchers en pendientes (`!isRedeemed && !isExpired`) vs. pasados (`isRedeemed || isExpired`), ordenados por `createdAt`. El rating por estrellas (`rateVoucher`) es **solo local** (no persiste al backend). "Add to Wallet" y "Download PDF" son TODOs. El nombre de producto usa `voucher.productName` o cae en `DummyHelper.productNameById`. Modelos: `VoucherModel`, `OrderModel`, `OrdersPage`.
