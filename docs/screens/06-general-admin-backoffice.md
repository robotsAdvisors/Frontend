# 06 · General Admin / Backoffice

Este grupo constituye el panel de plataforma (backoffice de "Franquicias Plus" / Enterprise Portal) desde el que un Super Admin gestiona el cumplimiento legal (RGPD, consentimientos, políticas sensibles), el soporte a usuarios, los pagos y disputas de Stripe, y la administración de comercios/tiendas y usuarios de la red. Todas las pantallas comparten un patrón de layout de escritorio con barra lateral de navegación morada (`#7C3AED`) y consumen endpoints `admin/*` y `marketplace/admin/*` del backend Django (Letdem) definidos en `lib/utils/api_config.dart` a través de `MarketplaceRepository`.

> Nota transversal: la base de la API es `https://api.letdem.net` + prefijo `/api/v1` (configurable con `LETDEM_API_BASE_URL`). Los tres controllers del grupo (`GeneralAdminController`, `GdprController`, `SupportController`) viven en `lib/app/modules/general_admin/controllers/`. Varias entradas de la barra lateral (p. ej. "Moderación", "Auditoría", "Cumplimiento") son estáticas y no navegan a ninguna ruta.

---

### Dashboard Backoffice de Plataforma (`/general-admin`)
- **Archivo:** `lib/app/modules/general_admin/views/general_admin_view.dart`
- **Ruta:** `/general-admin` (constante `Routes.GENERAL_ADMIN`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Punto de entrada del backoffice; muestra métricas globales de la red y la tabla de tiendas registradas con su estado KYBC, sirviendo de hub de navegación al resto de módulos.
- **Contenido / widgets clave:** Layout responsive (sidebar + cuerpo + panel de alertas a la derecha en escritorio ≥900px; `Drawer` en móvil). Tarjetas de estadísticas (Tiendas, KYBC pendientes, En revisión), tabla "Tiendas registradas" (logo, KYBC badge, estado publicado, botón "Configurar" → `STORE_CONFIG`), y panel lateral "Alertas comercio" (KYBC pendiente, datos fiscales incompletos, tickets de soporte pendientes).
- **Endpoints backend consumidos:** En `onInit` el controller llama `_loadFromBackend()` que dispara en paralelo (vía `MarketplaceRepository`): `GET /marketplace/admin/stores/`, `GET /marketplace/categories/`, `GET /marketplace/admin/dashboard/stats/`, `GET /marketplace/admin/alerts/`, `GET /marketplace/admin/audit-log/`, `GET /marketplace/admin/system/health/`, `GET /marketplace/admin/domain-stats/`, `GET /marketplace/orders/` (pageSize 1), `GET /users/me`, `GET /admin/kyc/stats/`.
- **Estados manejados:** `isLoading` (spinner en cabecera de la tabla); estado vacío "Sin tiendas registradas"; datos dummy iniciales desde `DummyHelper.stores` / `DummyHelper.storeUsers` que se reemplazan si el backend responde. Errores se silencian con `catchError`.
- **Navegación:** Es la pantalla raíz del backoffice (se llega tras login como admin). Desde el sidebar/botones navega a `STORE_CONFIG` (`/backoffice/store-config`), `COMERCIOS` (`/backoffice/comercios`), `LEGAL_CONSENTS`, `KYBC`, `SENSITIVE_POLICIES`, `STRIPE_DISPUTES`, `SUPPORT_TICKETS`. "Cerrar Sesión" hace `AuthService.signOut()` → `Routes.LOGIN`.
- **Notas:** Rol implícito "Super Admin" (etiqueta fija en topbar). Muchas métricas ejecutivas y de salud del sistema se cargan en el controller pero no todas se renderizan en esta vista. Tolerante a fallos: funciona con datos dummy si el backend no responde.

---

### Comercios (`/backoffice/comercios`)
- **Archivo:** `lib/app/modules/general_admin/views/comercios_view.dart`
- **Ruta:** `/backoffice/comercios` (constante `Routes.COMERCIOS`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Vista maestro-detalle tipo CRM para explorar los comercios/tiendas de la red y ver/gestionar los usuarios asignados a cada uno.
- **Contenido / widgets clave:** Tres paneles: sidebar de navegación, lista de comercios con buscador (`searchStores`) y badge KYC por tienda, y panel de detalle con cabecera de tienda, tarjetas de info (Propietario, Email, nº Usuarios) y tabla de usuarios del comercio (rol, estado activo, último acceso). Botón "Invitar" abre diálogo (email + rol Owner/Admin/Viewer/Member) y botón "Configurar" → `STORE_CONFIG`.
- **Endpoints backend consumidos:** Al seleccionar tienda `loadStoreDetail` llama `GET /marketplace/admin/stores/{id}/` (`adminGetStoreDetail`), `GET /marketplace/stores/{id}/users/` (`fetchStoreUsers`) y `GET /marketplace/stores/{id}/pin/` (`fetchStorePIN`). Invitar usuario: `POST /marketplace/stores/{id}/users/` (`inviteStoreUser`). Las tiendas listadas provienen del estado ya cargado en el dashboard.
- **Estados manejados:** `isLoadingStore` (spinner en el detalle); estado inicial "Selecciona un comercio…"; lista vacía "Sin comercios registrados"; tabla de usuarios vacía "Sin usuarios registrados en este comercio". Filtrado local por nombre/email.
- **Navegación:** Se llega desde el sidebar del backoffice (item "Comercios"/"Usuarios"). Navega a `GENERAL_ADMIN` (Dashboard), `STORE_CONFIG`, `LEGAL_CONSENTS`, `GDPR_REQUESTS`, `KYBC`, `SENSITIVE_POLICIES`, `STRIPE_DISPUTES`, `SUPPORT_TICKETS`.
- **Notas:** Solo escritorio (siempre `Row` de 3 paneles, sin variante móvil). Rol Super Admin. Si la API de usuarios de tienda devuelve vacío, hace fallback a la lista global `storeUsers` filtrada por `storeId`.

---

### Ficha Administrativa de Usuario (`/admin/users/detail`)
- **Archivo:** `lib/app/modules/general_admin/views/user_detail_view.dart`
- **Ruta:** `/admin/users/detail` (constante `Routes.ADMIN_USER_DETAIL`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Ficha administrativa completa de un usuario individual: perfil, suscripción, beneficios, transacciones, cumplimiento (KYC), desactivación y registro de auditoría de acciones.
- **Contenido / widgets clave:** Sidebar + área principal con cabecera (botones "Suspender/Reactivar cuenta" y "Editar perfil"), tarjeta de perfil (email enmascarado, documento con botón "Revelar"), tarjetas de fechas clave y compliance (consentimiento %, KYC/Auth/Facturación), plan de suscripción, beneficios Pro, historial de transacciones, control KYC (Reiniciar/Aprobar/Rechazar), control de desactivación (Desactivar/Restaurar) y tabla de auditoría con acción "Auditar". Múltiples diálogos con motivo obligatorio.
- **Endpoints backend consumidos:** `selectUser(userId)` carga en paralelo `GET /admin/users/{id}/` (`fetchAdminUserDetail`), `GET /admin/users/{id}/audit-log/`, `GET /admin/users/{id}/subscription/`, `GET /admin/users/{id}/benefits/`, `GET /admin/users/{id}/transactions/`, `GET /admin/users/{id}/kyc/`. Acciones: `POST /admin/users/{id}/suspend/`, `POST /admin/users/{id}/reveal-document/`, `PATCH/PUT /admin/users/{id}/` (editar), `POST /admin/users/{id}/audit/` (marcar auditado), `POST /admin/users/{id}/kyc/` con action `restart|approve|reject` (`updateUserKyc`), `POST /admin/users/{id}/deactivation/` con action `soft_delete|restore`.
- **Estados manejados:** `isLoadingUser` (spinner); `isSuspending` (deshabilita botón); estado sin selección "Selecciona un usuario para ver su ficha."; tablas vacías "Sin transacciones." / "Sin registros de auditoría."; `revealedDocument` para mostrar el documento revelado.
- **Navegación:** Se llega recibiendo `userId` por `Get.arguments` (típicamente desde flujos que enlazan a la ficha; no hay item directo en la barra lateral del grupo). Navega a `GENERAL_ADMIN`, `LEGAL_CONSENTS` (item GDPR) y `STRIPE_DISPUTES`.
- **Notas:** Cumplimiento crítico: la revelación de documento y las acciones KYC/suspensión/desactivación exigen motivo y quedan en el log de auditoría. Botones "Cambiar Plan"/"Cancelar" suscripción y "Exportar CSV/Log" son placeholders sin acción (`onTap: () {}`). Usa `withOpacity` (deprecado) en algunos badges.

---

### Solicitudes GDPR / RGPD (`/backoffice/gdpr`)
- **Archivo:** `lib/app/modules/general_admin/views/gdpr_requests_view.dart`
- **Ruta:** `/backoffice/gdpr` (constante `Routes.GDPR_REQUESTS`)
- **Controller / Binding:** `GdprController` (+ `GeneralAdminController` para el perfil del sidebar) / `GdprBinding`
- **Propósito:** Gestión de solicitudes de derechos RGPD (acceso, borrado, portabilidad, etc.), con control de plazos legales, asignación a staff y exportación de reportes.
- **Contenido / widgets clave:** Sidebar + área con tarjetas de estadísticas (Pendientes hoy, Fuera de plazo, Próximos vencimientos, Resueltas), barra de filtros por estado (Todas/Vencidas/Pró.1día/Pró.3días/Resueltas) y dropdown por tipo de derecho, tabla paginada de solicitudes (usuario, tipo, estado, fecha alta, badge de plazo/vencimiento) y bottom-sheet de detalle con acciones "Marcar en proceso"/"Marcar resuelto" y asignación por email. Botones "Ver Formatos Directiva" (diálogo con artículos RGPD) y "Exportar Reporte" (CSV).
- **Endpoints backend consumidos:** `GET /admin/gdpr/requests/stats/` (`fetchGdprStats`), `GET /admin/gdpr/requests/` con filtros/paginación (`fetchGdprRequests`), `GET /admin/gdpr/formats/` (`fetchGdprFormats`), `GET /admin/gdpr/requests/export/` (`exportGdprReport`, CSV a disco), `PATCH /admin/gdpr/requests/{id}/` (`updateGdprRequest`, para estado y asignación `assigned_to`).
- **Estados manejados:** `isLoading` (spinner en tabla), `isLoadingStats`, `isExporting` (spinner en botón). Estado vacío "Sin solicitudes registradas."; formatos con spinner mientras cargan. Errores silenciados en cargas; snackbars en acciones.
- **Navegación:** Se llega desde el sidebar (item "GDPR"). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `STRIPE_DISPUTES`. Los items "Legal", "Moderación", "Auditoría" del sidebar no navegan.
- **Notas:** Cumplimiento RGPD central: plazos calculados (`daysLeft`) con badges "VENCE HOY"/"N días vencido". El reporte CSV se guarda en Descargas (Android) o temp. La barra de búsqueda superior solo re-dispara `loadRequests` sin filtro de texto real.

---

### Control KYBC de Informadores (`/backoffice/kybc`)
- **Archivo:** `lib/app/modules/general_admin/views/kybc_view.dart`
- **Ruta:** `/backoffice/kybc` (constante `Routes.KYBC`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Cola de verificación de cumplimiento normativo (KYBC / Know Your Business Customer) de informadores/usuarios, con detalle de certificación, historial de sanciones y ejecución de acciones de cumplimiento.
- **Contenido / widgets clave:** Sidebar + cuerpo de dos columnas. Izquierda: "Cola de Verificación" con pestañas Pendiente/En Revisión (contadores), tabla de informadores con badge KYBC, y tarjeta de detalle del usuario seleccionado (avatar, auto-certificación, versión, IP, expiración, historial de certificados). Derecha: tarjeta de "Tasa de Aprobación" (con delta), "Panel de Transparencia" (datos visibles vs ocultos, estático), "Acciones de Cumplimiento" (dropdown suspender pagos/certificación, reactivar, marcar revisión + notas) y "Registro de Sanciones e Historial".
- **Endpoints backend consumidos:** `loadKybcData`/`loadKycQueueTab`: `GET /admin/kyc/stats/` (`fetchKycStats`) y `GET /admin/kyc/queue/?status=pending|in_review` (`fetchKycQueue`). Al seleccionar usuario: `GET /admin/users/{id}/kyc/` y `GET /admin/users/{id}/compliance/history/` (`fetchComplianceHistory`). Ejecutar acción: `POST /admin/users/{id}/kyc/action/` (`executeComplianceAction` con action `suspend_payments|suspend_certification|reactivate_account|flag_review` + notes).
- **Estados manejados:** `isLoadingKybc` (spinner en cola), `isExecutingAction` (spinner en botón "EJECUTAR SUSPENSIÓN INMEDIATA"); cola vacía "No hay usuarios en cola"; sin selección oculta las tarjetas de detalle/acciones; historial vacío "Sin sanciones registradas".
- **Navegación:** Se llega desde el sidebar (item "KYBC"). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `STRIPE_DISPUTES`.
- **Notas:** Cumplimiento KYC/AML. El "Panel de Transparencia" (datos visibles/ocultos) es configuración estática de la plataforma, no viene del backend. Botones "Filtros Avanzados" y "Exportar Reporte" de la cabecera son placeholders sin acción.

---

### Legal & Consentimientos (`/backoffice/legal`)
- **Archivo:** `lib/app/modules/general_admin/views/legal_consents_view.dart`
- **Ruta:** `/backoffice/legal` (constante `Routes.LEGAL_CONSENTS`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Trazabilidad legal: gestión de consentimientos de usuarios, solicitudes RGPD (data subject requests) y versiones de documentos legales (términos, privacidad, cookies).
- **Contenido / widgets clave:** Layout responsive (sidebar/Drawer). Tarjetas de estadísticas (Consentimientos activos, Pendientes revisión, RGPD pendientes), tabla de "Consentimientos" (usuario, documento+versión, estado, acción Resolver/Historial), tabla "Solicitudes RGPD" (derecho, estado, vencimiento, Resolver) y sección "Documentos legales" en tarjetas (Activo/Borrador, botón Activar). Botón "Nuevo documento" abre diálogo de creación. Diálogos de detalle de consentimiento (retirar/restaurar) y de solicitud RGPD (rechazar/completar).
- **Endpoints backend consumidos:** `loadLegalConsents` carga en paralelo `GET /admin/legal/consents/` (`fetchLegalConsents`), `GET /admin/legal/stats/` (`fetchLegalStats`), versiones legales (`fetchLegalVersions`) y `GET /admin/gdpr/...`-equivalente de data subject requests (`fetchDataSubjectRequests`, status pending). Acciones: `POST /admin/legal/consents/{id}/action/` (`updateLegalConsent`, withdraw/restore), actualización de data subject request (`updateDataSubjectRequest`, reject/complete), `PATCH /admin/legal/documents/...` (`updateLegalDocument`, activar) y `POST /admin/legal/documents/` (`createLegalDocument`).
- **Estados manejados:** `isLoadingLegal`; tablas vacías "Sin consentimientos registrados" / "Sin solicitudes RGPD activas" / "Sin documentos legales". Snackbars de éxito/error en todas las acciones.
- **Navegación:** Se llega desde el sidebar (item "Legal"; también accesible desde items "GDPR" de otras vistas). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `KYBC`, `SENSITIVE_POLICIES`, `STRIPE_DISPUTES`, `SUPPORT_TICKETS`.
- **Notas:** Cumplimiento RGPD. `loadLegalConsents()` se invoca en cada `build`. El endpoint concreto de data subject requests dentro del repositorio no está explícito en el mapeo mostrado ("no determinado" si difiere de `/admin/legal/` o `/admin/gdpr/`). Marca versiones no activas como "Borrador".

---

### Políticas Sensibles (`/backoffice/politicas`)
- **Archivo:** `lib/app/modules/general_admin/views/sensitive_policies_view.dart`
- **Ruta:** `/backoffice/politicas` (constante `Routes.SENSITIVE_POLICIES`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Administración centralizada de políticas sensibles de la plataforma (retención de datos, RGPD, geolocalización, auditoría), con plazos y ámbito de aplicación.
- **Contenido / widgets clave:** Layout responsive (sidebar/Drawer). Tarjetas de estadísticas (Documentos activos, Pendientes, Cobertura %), tabla "Políticas registradas" (nombre+descripción, categoría badge, plazo, ruta/ámbito badge, acción Editar/Ver). Botón "Nueva Política" y diálogo de creación/edición (nombre, descripción, plazo en días, ruta Usuario/Backoffice/Informe/Global, categoría, estado active/pending/inactive). Diálogo de solo lectura "Ver" para políticas no editables.
- **Endpoints backend consumidos:** `loadSensitivePolicies`: `GET /admin/policies/` (`fetchSensitivePolicies`) y `GET /admin/policies/stats/` (`fetchSensitivePoliciesStats`). Crear: `POST /admin/policies/` (`createSensitivePolicy`); editar: `PATCH/PUT /admin/policies/{id}/` (`updateSensitivePolicy`).
- **Estados manejados:** `isLoadingPolicies` (spinner en cabecera de tabla); estado vacío "Sin políticas registradas". Snackbars de éxito/error en crear/editar. Coberturas/contadores con fallback calculado localmente si el stats viene incompleto.
- **Navegación:** Se llega desde el sidebar (item "Políticas"). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `LEGAL_CONSENTS`, `KYBC`, `SUPPORT_TICKETS`.
- **Notas:** Cumplimiento/gobernanza de datos. `loadSensitivePolicies()` se invoca en cada `build`. Solo las políticas con `isEditable` muestran "Editar"; el resto solo "Ver". La barra de búsqueda superior es decorativa (sin lógica).

---

### Configuración de Tienda (`/backoffice/store-config`)
- **Archivo:** `lib/app/modules/general_admin/views/store_config_view.dart`
- **Ruta:** `/backoffice/store-config` (constante `Routes.STORE_CONFIG`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Formulario de configuración completa de una tienda: información comercial, categorías, geolocalización, gestión del equipo/roles, seguridad (PIN, 2FA) y datos fiscales.
- **Contenido / widgets clave:** Sidebar + formulario. Sección "Información de la Tienda" (banner y logo subibles vía `image_picker`, nombre, categorías multi-select, dirección, GPS lat/lng con previsualización de mapa OpenStreetMap), "Gestión de Roles" (tabla de equipo con Invitar/Cambiar Rol/Eliminar), "Seguridad" (PIN enmascarado + Regenerar, switch 2FA) y "Datos Fiscales" (CIF/NIF, dirección de facturación con checkbox misma dirección). Botones "Descartar" y "Guardar Cambios".
- **Endpoints backend consumidos:** Carga `loadStoreDetail`: `GET /marketplace/admin/stores/{id}/`, `GET /marketplace/stores/{id}/users/`, `GET /marketplace/stores/{id}/pin/`. Guardar: `PATCH /marketplace/admin/stores/{id}/` (`adminUpdateStore`). Equipo: `POST /marketplace/stores/{id}/users/` (invitar), eliminar/actualizar rol de usuario (`removeStoreUser`/`updateStoreUserRole`). Seguridad: `POST /marketplace/stores/{id}/pin/regenerate/` (`regenerateStorePIN`), `PATCH .../security/` (`updateStoreSecurity` 2FA). Imágenes: `POST /marketplace/stores/{id}/upload-banner/` y `.../upload-logo/`.
- **Estados manejados:** `isLoadingStore` (spinner de pantalla completa), `isSavingStore` (spinner en botón Guardar). Equipo vacío "Sin usuarios asignados". El formulario se sincroniza con `selectedStore` vía `ever`.
- **Navegación:** Se llega con `storeId` por `Get.arguments` (desde Dashboard, Comercios). Botón atrás y "Descartar" hacen `Get.back()`. Sidebar navega a `GENERAL_ADMIN`, `COMERCIOS`, `LEGAL_CONSENTS`, `STRIPE_DISPUTES`, `SUPPORT_TICKETS`.
- **Notas:** Al regenerar PIN, el nuevo PIN se muestra una sola vez en snackbar. El mapa usa `staticmap.openstreetmap.de` (sin API key). Roles de invitación limitados a Administrador/Miembro en el diálogo. Si no hay `storeId`, las acciones de red se inhiben.

---

### Disputas y Reembolsos Stripe (`/backoffice/pagos`)
- **Archivo:** `lib/app/modules/general_admin/views/stripe_disputes_view.dart`
- **Ruta:** `/backoffice/pagos` (constante `Routes.STRIPE_DISPUTES`)
- **Controller / Binding:** `GeneralAdminController` / `GeneralAdminBinding`
- **Propósito:** Gestión de disputas, devoluciones y reembolsos de pagos integrados con Stripe, con seguimiento por fase (backoffice/Stripe/ganada/perdida) y ejecución de acciones.
- **Contenido / widgets clave:** Layout responsive (sidebar/Drawer). Tarjetas de estadísticas (Disputas abiertas, Completadas, % Éxito), tabla "Disputas" (id + usuario, importe + motivo, fase badge, botón de acción contextual Revisar/Continuar/Auditar/Apelar). Diálogo de detalle con datos de la disputa (Stripe ID, importe, motivo, fechas) y campo de notas para ejecutar la acción.
- **Endpoints backend consumidos:** `loadStripeDisputes`: `GET /admin/stripe/disputes/` (`fetchStripeDisputes`) y `GET /admin/stripe/disputes/stats/` (`fetchStripeDisputeStats`). Ejecutar acción: `POST /admin/stripe/disputes/{id}/action/` (`performStripeDisputeAction` con action `review|continue|audit|appeal` + notes). (Definidos además `adminStripeDisputeDetail` y `adminStripeRefunds`.)
- **Estados manejados:** `isLoadingDisputes` (spinner en tabla); estado vacío "Sin disputas activas". La acción solo se ofrece si `_canAct` (estado no en won/lost/completed/charge_refunded). Snackbars de éxito/error.
- **Navegación:** Se llega desde el sidebar (item "Pagos"). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `LEGAL_CONSENTS`, `KYBC`, `SENSITIVE_POLICIES`, `SUPPORT_TICKETS`.
- **Notas:** `loadStripeDisputes()` se invoca en cada `build`. La etiqueta y el verbo de la acción se derivan de la fase/estado de la disputa. Importes formateados en EUR (`€`) por defecto.

---

### Gestión de Tickets de Soporte (`/backoffice/support`)
- **Archivo:** `lib/app/modules/general_admin/views/support_tickets_view.dart`
- **Ruta:** `/backoffice/support` (constante `Routes.SUPPORT_TICKETS`)
- **Controller / Binding:** `SupportController` (+ `GeneralAdminController` para perfil del sidebar) / `SupportBinding`
- **Propósito:** Bandeja de soporte tipo helpdesk: listar/filtrar tickets, ver la conversación, responder (público o nota interna), crear, escalar, cerrar y reasignar tickets a agentes.
- **Contenido / widgets clave:** `StatefulWidget` con sidebar + lista de tickets (izquierda) + detalle (derecha). Lista con búsqueda con debounce, filtros por estado/categoría/prioridad/fecha, y filas con código/título/usuario/categoría. Detalle con cabecera (estado, menú Escalar/Cerrar/Reasignar), conversación en burbujas (usuario/agente/nota interna) y área de composición con toggle "Respuesta Visible / Nota Interna" y "Enviar y Cerrar". Diálogos "Nuevo Ticket" y "Reasignar Ticket" (dropdown de agentes).
- **Endpoints backend consumidos:** Usa `ApiClient.dio` directamente. Meta: `GET /admin/ticket-categories/` y `GET /admin/agents/`. Lista: `GET /admin/tickets/` (con `page`, `page_size`, `status`, `category`, `priority`, `date`, `search`). Detalle: `GET /admin/tickets/{id}/`. Crear: `POST /admin/tickets/create/`. Mensajes: `POST /admin/tickets/{id}/messages/`. Acciones: `POST /admin/tickets/{id}/escalate/`, `POST /admin/tickets/{id}/close/`, `POST /admin/tickets/{id}/reassign/` (con `agent_id`).
- **Estados manejados:** `isLoading` (lista), `isLoadingDetail`, `isLoadingMeta`, `isSending`, `isActing`, `isCreating`. Lista vacía "No hay tickets que coincidan."; sin selección muestra empty state "Selecciona un ticket…". Paginación server-side (`page`/`totalCount`). Manejo de `DioException` con mensajes del backend en snackbars.
- **Navegación:** Se llega desde el sidebar (item "Soporte"). Navega a `GENERAL_ADMIN`, `COMERCIOS`, `LEGAL_CONSENTS` (GDPR), `STRIPE_DISPUTES`. Items "Legal", "KYBC", "Moderación", "Cumplimiento", "Auditoría" del sidebar no navegan.
- **Notas:** Filtros y búsqueda se aplican server-side. Si el ticket no tiene mensajes cargados, se fabrica un mensaje inicial a partir de la descripción. Categorías con color dinámico desde el backend (`flutterColor`) con paleta estática de fallback. Crear ticket requiere ID numérico del usuario afectado.
