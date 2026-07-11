# 05 · Admin de tienda

Este grupo cubre el panel de administración de una tienda (backoffice del comerciante). Todas las vistas viven en `lib/app/modules/admin/views/` y comparten el mismo `AdminController` (`lib/app/modules/admin/controllers/admin_controller.dart`), inyectado por `AdminBinding`; solo la pantalla de reseñas añade `ReviewsController`. El controller sigue un patrón **dummy → backend**: en `onInit()` primero llama a `_bootstrapFromDummy()` para pintar datos de ejemplo al instante (tomados de `DummyHelper`, con `storeId` que empieza por `store_`) y luego `_loadFromBackend()` resuelve la tienda real del admin logueado vía `MarketplaceRepository`; solo cuando el `storeId` deja de empezar por `store_` se disparan las llamadas reales. Los endpoints se resuelven desde `lib/utils/api_config.dart` sobre `https://api.letdem.net/api/v1`. Todas las rutas `/admin/*` (y el resto de este grupo) requieren sesión activa de un admin de tienda; el cierre de sesión redirige a `Routes.LOGIN`.

### Dashboard de tienda (`/admin`)
- **Archivo:** `lib/app/modules/admin/views/admin_view.dart`
- **Ruta:** `/admin` (constante `Routes.ADMIN`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Panel principal ("Resumen Operativo") del admin de tienda con KPIs de canjes, canjes recientes, tarjeta virtual de puntos, meta mensual y feed de actividad.
- **Contenido / widgets clave:** Sidebar de navegación; topbar con buscador y avatar de tienda; fila de 4 stat cards (`pendingCount`, `completedTodayCount`, `expiredCount`, `activePrizesCount`); tabla de "Canjes recientes" (`recentCanjes`) con badges de estado; tarjeta virtual de puntos (`storeCardId`, `accumulatedPoints`, `availablePoints`); banner de meta mensual (`monthlyGoal*`); panel de "Actividad de Tienda" (`activityFeed`); diálogo "Validar canje"; bottom sheet con datos fiscales de la tienda.
- **Endpoints backend consumidos:** Indirectos vía la carga inicial del controller: `GET /marketplace/stores/`, `GET /marketplace/products/`, `GET /marketplace/vouchers/`, `GET /marketplace/analytics/summary/`, `GET /marketplace/stores/<id>/activity/`, `GET /marketplace/stores/<id>/monthly-goal/`. La validación de canje llama `POST /marketplace/vouchers/validate/`.
- **Estados manejados:** loading (`isLoading` → `CircularProgressIndicator`), vacío ("No hay canjes recientes." / "Sin actividad reciente."), éxito (datos pintados), fallback silencioso a datos dummy si el backend falla.
- **Navegación:** Es el hub del grupo. Se llega tras login como admin de tienda. Navega a `Routes.REVIEWS`, `Routes.VOUCHER_HISTORY`, `Routes.PREMIOS`, `Routes.INVENTARIO`, `Routes.ANALYTICS`, `Routes.ADMIN_SETTINGS` (PIN/Seguridad); logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. Usa `AuthService.isStoreAdmin` para el rótulo del usuario. Muchos KPIs prefieren `analyticsSummary` del backend y caen a cálculo local sobre `vouchers` si no hay datos. El buscador del topbar solo redirige al historial.

### Analytics (`/analytics`)
- **Archivo:** `lib/app/modules/admin/views/analytics_view.dart`
- **Ruta:** `/analytics` (constante `Routes.ANALYTICS`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Vista de estadísticas de la tienda: canjes totales, puntos generados, valor de mercado, rating, gráfico de rendimiento y tabla de rendimiento por producto.
- **Contenido / widgets clave:** Sidebar; 4 `_StatCard` (canjes totales, puntos generados, valor de mercado, rating de tienda); tarjeta de gráfico de barras (`_BarChart`/`_BarChartPainter`) con toggle Semana/Mes alimentado por `dailyVouchers`; tarjeta "Top Categorías" (calculada localmente sobre `products`); tabla "Rendimiento por Producto" con conversión y tendencia calculadas sobre `vouchers`/`redeemedVouchers`.
- **Endpoints backend consumidos:** Datos precargados por el controller: `GET /marketplace/analytics/summary/`, `GET /marketplace/analytics/vouchers/daily/` (gráfico). También lee `storeRating`/`storeReviewCount` provenientes de `GET /marketplace/stores/`. El controller además consume `GET /marketplace/analytics/vouchers/by-status/` y `GET /marketplace/analytics/products/top-redeemed/`, aunque esta vista deriva sus tablas localmente.
- **Estados manejados:** loading (`isLoading`), vacío ("Sin datos" en categorías, "Sin productos" en tabla), éxito. El header indica si los datos son del backend (últimos 30 días) o derivados de los vouchers cargados.
- **Navegación:** Se llega desde el dashboard y sidebars del grupo. El sidebar navega a `Routes.ADMIN` (Dashboard/Inventory/Datos tienda con `Get.offNamed`) y `Routes.VOUCHER_HISTORY`; logout va a `Routes.WELCOME`.
- **Notas:** Requiere sesión. El gráfico y las categorías tienen fallback de cálculo local a partir de `vouchers`/`products` cuando faltan datos del backend. Muestra `AuthService.currentUserEmail` y rol (`isStoreAdmin`).

### Inventario / Productos (`/inventario`)
- **Archivo:** `lib/app/modules/admin/views/inventario_view.dart`
- **Ruta:** `/inventario` (constante `Routes.INVENTARIO`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Gestión paginada del catálogo de productos con búsqueda, filtros de estado, ordenación y acceso a edición/creación.
- **Contenido / widgets clave:** Sidebar responsive (Drawer en móvil); fila de stats (`inventoryStats`: total, en stock, pendientes, categorías); barra de búsqueda con debounce (400 ms); chips de filtro (Todos/Activos/Pausados/Sin stock, filtrado en cliente); dropdown de ordenación (name/-name/stock/price…); tabla de productos (`inventoryProducts`) con miniatura, tipo, stock, ventas (`salesCount`), estado y botón "Editar"; paginación (`inventoryMeta`).
- **Endpoints backend consumidos:** `GET /marketplace/products/` paginado (vía `loadInventoryPage` → `fetchProductsPage`, con `store`, `page`, `search`, `category`, `ordering`). Los stats provienen de `GET /marketplace/admin/inventory/stats/` (precargado en el controller).
- **Estados manejados:** loading (`isLoadingInventory` → spinner en tabla), vacío ("Sin productos"), éxito; fallback a filtrado en memoria sobre `products` si la llamada paginada falla.
- **Navegación:** Se llega desde sidebars del grupo. "Añadir producto" y "Editar" van a `Routes.ADD_PRODUCT` (Editar pasa el `ProductModel` como `arguments`). Sidebar navega a `Routes.ADMIN`, `Routes.EMPLEADOS`, `Routes.CONFIRMAR_ENTREGA`, `Routes.SEGURIDAD`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. `loadInventoryPage` no llama al backend mientras `storeId` empiece por `store_`. Los filtros de estado se aplican en cliente; la búsqueda/orden se delegan al backend.

### Premios y Beneficios (`/premios`)
- **Archivo:** `lib/app/modules/admin/views/premios_view.dart`
- **Ruta:** `/premios` (constante `Routes.PREMIOS`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Gestión del catálogo de recompensas (crear/editar/pausar/eliminar premios) con panel lateral de creación, más pestañas de Ventas y Usuarios de la tienda.
- **Contenido / widgets clave:** Header con pestañas Premios/Ventas/Usuarios; sidebar; tabla de premios (`inventoryProducts`) con imagen, categoría (color desde `CategoryModel.color`), stock, coste en puntos, estado y acciones (editar / pausar-activar / eliminar); panel lateral de creación/edición con subida de imagen, dropdown de categorías, stock, sección de puntos (`is_redeemable`) y sección de precio Stripe (`monetary_price`); pestaña **Ventas** (`storeOrders`, stats de ingresos/puntos, filtros PAID/PENDING/CANCELLED, paginación); pestaña **Usuarios** (`storeUsers`).
- **Endpoints backend consumidos:** Listado vía `GET /marketplace/products/` paginado. Crear: `POST /marketplace/admin/products/`; editar: `PATCH /marketplace/admin/products/<id>/`; eliminar: `DELETE /marketplace/admin/products/<id>/`; pausar/activar (`is_published`): `PATCH /marketplace/admin/products/<id>/`; subir imagen: `POST /marketplace/admin/products/upload-image/`. Pestaña Ventas: `GET /marketplace/store/orders/`. Pestaña Usuarios: `GET /marketplace/stores/<id>/users/`.
- **Estados manejados:** loading (inventario y órdenes), vacío ("No se encontraron premios.", "No hay ventas registradas.", "Sin usuarios registrados."), guardando (`_isSavingPanel`, spinner), subiendo imagen (`_isUploadingImage`), éxito con snackbar del controller.
- **Navegación:** Se llega desde sidebars del grupo. Sidebar navega a `Routes.ADMIN`, `Routes.VOUCHER_HISTORY`, `Routes.ANALYTICS`; la pestaña Usuarios enlaza a `Routes.ADMIN_SETTINGS` (Gestionar Staff); logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. Las pestañas Ventas/Usuarios cargan bajo demanda al seleccionarse. El color de categoría cae a colores semánticos por keyword si el backend no envía `color`.

### Añadir / Editar producto (`/add-product`)
- **Archivo:** `lib/app/modules/admin/views/add_product_view.dart`
- **Ruta:** `/add-product` (constante `Routes.ADD_PRODUCT`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Formulario completo de alta o edición de un producto/recompensa (recibe opcionalmente un `ProductModel` por `Get.arguments` para modo edición).
- **Contenido / widgets clave:** Layout responsive (2 columnas en escritorio); topbar con breadcrumb y botones Cancel/Save; tarjeta "Basic Information" (nombre, categoría desde `categories`, marca, descripción); "Reward Details" (valor en puntos, precio original, descuento con picker y barra de fuerza de mercado); "Inventory & Settings" (stepper de stock, fecha de expiración, chips de sucursal); columna derecha con "Media" (subida de imagen local o por URL), "Visibility" (activo/destacado, solo estado local de UI) y "Smart Suggestions".
- **Endpoints backend consumidos:** Subida de imagen: `POST /marketplace/admin/products/upload-image/`. Crear: `POST /marketplace/admin/products/` (vía `addProduct`); editar: `PATCH /marketplace/admin/products/<id>/` (vía `updateProduct`).
- **Estados manejados:** guardando (`_isSaving`, spinner en botón), validación de campos obligatorios (snackbar), éxito (snackbar del controller y `Get.offNamed(Routes.ADMIN)`).
- **Navegación:** Se llega desde `Routes.INVENTARIO` (botón Añadir / Editar). Cancelar hace `Get.back()`; al guardar navega a `Routes.ADMIN`.
- **Notas:** Requiere sesión. Los toggles "Active"/"Featured" y "Store Branches" son de UI y no se envían en el payload. La UI de este formulario está mayormente en inglés. En creación sin storeId real se usa `store_1` como fallback.

### Reseñas (`/reviews`)
- **Archivo:** `lib/app/modules/admin/views/reviews_view.dart`
- **Ruta:** `/reviews` (constante `Routes.REVIEWS`)
- **Controller / Binding:** `ReviewsController` (+ `AdminController`) / `AdminBinding`
- **Propósito:** Gestión de reseñas de la tienda: métricas de sentimiento, listado filtrable/ordenable, y acciones de responder / reportar.
- **Contenido / widgets clave:** Sidebar; topbar con buscador; sección de stats (`ReviewsController.stats`: calificación promedio, sentimiento positivo, nuevas reseñas, días sin acumulación); banner de "Protocolo de Gestión"; barra de filtros (all/pending_reply/positive/negative/hidden) y dropdown de orden (recent/rating_desc/rating_asc); lista de `_reviewCard` (avatar, estrellas, texto, badges, respuesta, badges en revisión/anónimo); paginación; diálogos de responder y reportar.
- **Endpoints backend consumidos:** `GET /marketplace/stores/<id>/reviews/stats/` (stats), `GET /marketplace/stores/<id>/reviews/` (listado con `filter`, `sort`, `page`), `POST /marketplace/reviews/<id>/reply/` (responder), `POST /marketplace/reviews/<id>/report/` (reportar), `POST /marketplace/reviews/<id>/hide/` (ocultar).
- **Estados manejados:** loading (`isLoading`/`isLoadingStats`), vacío ("No hay reseñas en esta categoría."), enviando (`isSubmitting`, spinner en diálogo), éxito (snackbar). `ReviewsController` espera a que el `storeId` real llegue (`once`) antes de cargar.
- **Navegación:** Se llega desde el dashboard (`Routes.ADMIN`). Sidebar navega a `Routes.ADMIN`, `Routes.VOUCHER_HISTORY`, `Routes.PREMIOS`, `Routes.ANALYTICS`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. `ReviewsController` se instancia con `Get.put` en la vista y toma el `storeId` del `AdminController`. El buscador del topbar es decorativo (no filtra).

### Historial de canjes (`/voucher-history`)
- **Archivo:** `lib/app/modules/admin/views/voucher_history_view.dart`
- **Ruta:** `/voucher-history` (constante `Routes.VOUCHER_HISTORY`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Doble función: pestaña **Validación** para previsualizar/validar/pagar un código de canje, y pestaña **Panel** con el historial de operaciones filtrable y exportable.
- **Contenido / widgets clave:** Sidebar; topbar con pestañas Validación/Panel. **Validación:** entrada de código con preview (`previewedVoucher`), botones Escanear/Pagar, bloque de identidad del cliente con checkbox, panel derecho con detalle del premio/estado, sección de pago Stripe, botón "Confirmar canje", y diálogos de incidencia y de pago. **Panel:** buscador, filtro por fecha (dd/MM/yyyy → ISO), export CSV, sub-pestañas Todos/Pendientes/Entregados/Expirados, tabla paginada en cliente (`_filtered`/`_paginated`), diálogo de detalle de voucher, y fila de analytics.
- **Endpoints backend consumidos:** Preview: `POST /marketplace/vouchers/preview/`; validar/confirmar: `POST /marketplace/vouchers/validate/`; iniciar pago: `POST /marketplace/vouchers/<code>/initiate-payment/`; reportar incidencia: `POST /marketplace/vouchers/<id>/incident/`; filtro por fecha y paginación: `GET /marketplace/vouchers/` (con `date`, `page`, `page_size`); export CSV: `GET /marketplace/admin/products/export/`.
- **Estados manejados:** loading (`isLoading`, `isPreviewingVoucher`, `isInitiatingPayment`, `isLoadingDateFilter`, `isExportingCsv`), error de preview (`previewError`), vacío ("No hay operaciones en este periodo" / "Sin resultados para los filtros aplicados"), éxito (snackbar).
- **Navegación:** Se llega desde el dashboard y varios sidebars. Sidebar navega a `Routes.ADMIN`, `Routes.PREMIOS`, `Routes.ANALYTICS`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`. Las pestañas Validación/Panel se alternan dentro de la propia vista.
- **Notas:** Requiere sesión. El filtrado, la búsqueda y la paginación del Panel se hacen en cliente sobre `vouchers`/`dateFilteredVouchers`. El escáner QR muestra un aviso ("Activa la cámara en un dispositivo móvil"). El export CSV reutiliza `exportInventoryCsv` (productos). El botón "Exportar CSV" nota interna: el nombre de referencia cae al prefijo del id si el backend no envía `code`.

### Configuración de la tienda (`/admin-settings`)
- **Archivo:** `lib/app/modules/admin/views/admin_settings_view.dart`
- **Ruta:** `/admin-settings` (constante `Routes.ADMIN_SETTINGS`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Ajustes de la tienda: información comercial, banner/logo, ubicación GPS, gestión de roles/usuarios, seguridad (PIN, 2FA) y datos fiscales.
- **Contenido / widgets clave:** Sidebar; sección "Información de la Tienda" (banner y logo con subida, nombre, categoría, dirección, selector GPS con geocodificación); "Gestión de Roles" (tabla `storeUsers`, invitar, cambiar rol, eliminar); "Seguridad" (cambiar PIN, toggle 2FA); "Datos Fiscales" (CIF/NIF, dirección de facturación); barra inferior Descartar/Guardar; diálogos de geocoding, cambiar PIN e invitar usuario.
- **Endpoints backend consumidos:** Guardar tienda: `PATCH /marketplace/stores/<id>/` (vía `saveStoreSettings`); subir banner: `POST /marketplace/stores/<id>/upload-banner/`; subir logo: `POST /marketplace/stores/<id>/upload-logo/`; usuarios: `GET /marketplace/stores/<id>/users/`, invitar `POST` mismo path, cambiar rol `PATCH /marketplace/stores/<id>/users/<userId>/`, eliminar `DELETE` mismo path; cambiar PIN: `POST /marketplace/stores/<id>/change-pin/`; 2FA: `POST /marketplace/stores/<id>/security/`; geocoding: `POST /location/geocode/` y `POST /location/reverse-geocode/`.
- **Estados manejados:** guardando (`isSavingSettings`/`_isSaving`), subiendo (`_isUploadingBanner`/`_isUploadingLogo`), geocodificando (`_isGeocoding`), vacío ("Sin usuarios registrados."), éxito (snackbar). "Descartar" repuebla el formulario desde `currentStore`.
- **Navegación:** Se llega desde varios sidebars y desde enlaces "PIN"/"Seguridad"/"Gestionar Staff". Sidebar navega a `Routes.ADMIN`, `Routes.VOUCHER_HISTORY`, `Routes.PREMIOS`, `Routes.ANALYTICS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. El mapa GPS es un placeholder pintado (`_MapGrid`), no un mapa real. El propietario (`isOwner`) no puede eliminarse ni cambiar de rol. El diálogo de invitación ofrece roles ADMIN/MEMBER/MANAGER/VALIDATOR.

### Empleados / Roles y permisos (`/admin/empleados`)
- **Archivo:** `lib/app/modules/admin/views/empleados_view.dart`
- **Ruta:** `/admin/empleados` (constante `Routes.EMPLEADOS`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Gestión del equipo de la tienda: lista de usuarios, visualización de permisos por rol, invitar, cambiar rol y eliminar usuarios.
- **Contenido / widgets clave:** Sidebar responsive (Drawer en móvil); header con botón "Invitar usuario"; layout de dos columnas: panel de "Usuarios de la tienda" (`storeUsers`, con presencia online y menú de acciones) y panel "Permisos por rol" que muestra los slugs de permiso concedidos al rol del usuario seleccionado (`roleDefinitions`, con fallback a slugs conocidos: products/vouchers/analytics/team/settings); barra informativa inferior; diálogos de invitar y cambiar rol.
- **Endpoints backend consumidos:** `GET /marketplace/stores/<id>/users/` (usuarios), `GET /marketplace/stores/<id>/roles/permissions/` (definiciones de rol), invitar `POST /marketplace/stores/<id>/users/`, cambiar rol `PATCH /marketplace/stores/<id>/users/<userId>/`, eliminar `DELETE /marketplace/stores/<id>/users/<userId>/`.
- **Estados manejados:** vacío ("Sin usuarios registrados", "Selecciona un usuario para ver sus permisos"), éxito (snackbar del controller). Carga `reloadStoreUsers` + `loadRoleDefinitions` en el primer frame.
- **Navegación:** Se llega desde los sidebars de Inventario/Seguridad (enlace "Equipo"/"Empleados"). Sidebar navega a `Routes.ADMIN`, `Routes.EMPLEADOS`, `Routes.CONFIRMAR_ENTREGA`, `Routes.INVENTARIO`, `Routes.SEGURIDAD`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. Si `roleDefinitions` no ha cargado, usa una lista de roles fallback (ADMIN/VIEWER/MEMBER) y slugs de permiso por defecto. El propietario/usuarios no removibles no muestran menú de acciones (`canBeRemoved`).

### Seguridad y PIN (`/admin/seguridad`)
- **Archivo:** `lib/app/modules/admin/views/seguridad_view.dart`
- **Ruta:** `/admin/seguridad` (constante `Routes.SEGURIDAD`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Gestión de la seguridad de la tienda: PIN (cambiar/regenerar), doble factor (2FA) e historial de eventos de seguridad.
- **Contenido / widgets clave:** Sidebar responsive; header; tarjeta de PIN (máscara de 6 dígitos, cambiar PIN, regenerar con revelado de PIN copiable); tarjeta de 2FA (toggle `twoFactorEnabled`, último uso 2FA derivado, conteo de sucursales); sección "Historial de seguridad" (`securityLog`, iconos por tipo de evento); barra inferior informativa; diálogos de cambiar PIN y de confirmar regeneración.
- **Endpoints backend consumidos:** Datos precargados por el controller: `GET /marketplace/stores/<id>/pin/` (datos del PIN) y `GET /marketplace/stores/<id>/security-log/` (historial). Acciones: cambiar PIN `POST /marketplace/stores/<id>/change-pin/`; regenerar PIN `POST /marketplace/stores/<id>/pin/regenerate/`; toggle 2FA `POST /marketplace/stores/<id>/security/`.
- **Estados manejados:** regenerando (`isRegeneratingPin`, spinner), PIN revelado (`regeneratedPin`), vacío ("Sin eventos registrados"), éxito (snackbar).
- **Navegación:** Se llega desde los sidebars del subgrupo de tienda. Sidebar navega a `Routes.ADMIN`, `Routes.EMPLEADOS`, `Routes.CONFIRMAR_ENTREGA`, `Routes.INVENTARIO`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. "Último canjeo 2FA" prefiere `last_2fa_used_at` del backend y cae a derivarlo del `securityLog`. El conteo de sucursales ("Ubicación automática") está marcado en el código como pendiente de campo backend (`branch_count`/`location_count`).

### Incidencias de canje (`/admin/incidencias`)
- **Archivo:** `lib/app/modules/admin/views/incidencias_view.dart`
- **Ruta:** `/admin/incidencias` (constante `Routes.INCIDENCIAS`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Abrir tickets de soporte sobre un voucher problemático: buscar el voucher, elegir motivo, describir y enviar a soporte.
- **Contenido / widgets clave:** Sidebar responsive; header; tarjeta de formulario (búsqueda de voucher con preview, dropdown de motivo, descripción, botón "Enviar a soporte"); tarjeta "Criterio funcional" con la guía de casos; lista de "Incidencias recientes" (solo tickets enviados en la sesión actual); barra inferior de aviso.
- **Endpoints backend consumidos:** Preview del voucher: `POST /marketplace/vouchers/preview/`; enviar incidencia: `POST /marketplace/vouchers/<id>/incident/` (vía `reportVoucherIncident`, devuelve `ticket_id`).
- **Estados manejados:** buscando (`isPreviewingVoucher`), error de preview (`previewError`), enviando (`_isSubmitting`), vacío ("No hay incidencias en esta sesión"), éxito (snackbar con nº de ticket).
- **Navegación:** Se llega desde los sidebars del subgrupo de tienda. Sidebar navega a `Routes.ADMIN`, `Routes.INVENTARIO`, `Routes.SEGURIDAD`, `Routes.ADMIN_SETTINGS` (los ítems "Canjes" e "Historial" no tienen destino activo aquí); logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. El código marca varios pendientes de backend: lista de motivos hardcodeada (falta `GET /marketplace/vouchers/incident-reasons/`) y ausencia de `GET /marketplace/stores/<id>/incidents/`, por lo que "Incidencias recientes" solo muestra los tickets creados durante la sesión (`_sessionIncidents`).

### Confirmar entrega (`/admin/confirmar-entrega`)
- **Archivo:** `lib/app/modules/admin/views/confirmar_entrega_view.dart`
- **Ruta:** `/admin/confirmar-entrega` (constante `Routes.CONFIRMAR_ENTREGA`)
- **Controller / Binding:** `AdminController` / `AdminBinding`
- **Propósito:** Buscar un voucher por código y confirmar su entrega/canje al cliente en tienda.
- **Contenido / widgets clave:** Sidebar responsive; header con chip de la tienda; barra de búsqueda de código; tarjeta "Código de canje" (badge de código encontrado/estado vacío/error, botón escanear, limpiar, puntos de verificación); tarjeta "Detalle del canje" (imagen, producto, puntos, pago Stripe, cliente, estado, fechas, badge de pago verificado, aviso si no confirmable, botón "Confirmar entrega"); banner de éxito tras confirmar; barra inferior de aviso.
- **Endpoints backend consumidos:** Preview/búsqueda del voucher: `POST /marketplace/vouchers/preview/`; confirmar entrega: `POST /marketplace/vouchers/validate/` (vía `validateVoucherCode`).
- **Estados manejados:** buscando (`isPreviewingVoucher`), error (`previewError`), sin voucher (estados vacíos), confirmando (`_isConfirming`), confirmado (`_justConfirmed` → banner de éxito). Solo permite confirmar vouchers en estado `paid` o `pending`.
- **Navegación:** Se llega desde los sidebars del subgrupo de tienda (enlace "Pedidos"). Sidebar navega a `Routes.ADMIN`, `Routes.INVENTARIO`, `Routes.VOUCHER_HISTORY`, `Routes.SEGURIDAD`, `Routes.ADMIN_SETTINGS`; logout va a `Routes.LOGIN`.
- **Notas:** Requiere sesión. El escáner QR está pendiente (muestra aviso "Próximamente"; requiere plugin `mobile_scanner` no incluido). Un voucher expirado o ya canjeado muestra aviso y deshabilita el botón de confirmar.
