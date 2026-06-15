# PRD — Panel de Administración Letdem
**Versión:** 1.0  
**Fecha:** 2026-06-14  
**Plataforma:** Flutter Web  
**Audiencia:** QA, Desarrollo, Product

---

## 1. Contexto general

El Panel de Administración Letdem es una aplicación web construida en Flutter (GetX) que permite a los propietarios de tiendas adheridas gestionar su operación de fidelización de clientes. Incluye gestión de inventario, premios, empleados, canjes de vouchers, reseñas, analíticas y configuración de tienda.

### 1.1 Arquitectura relevante para pruebas

| Concepto | Descripción |
|---|---|
| `AdminController` | Controlador central. Carga datos dummy instantáneamente (`_bootstrapFromDummy`) y después los reemplaza con datos reales del backend (`_loadFromBackend`). |
| `storeId` | `RxString`. Inicia como ID dummy (`store_1`). Cambia al UUID real cuando `fetchStores` responde. Ninguna llamada al backend debe ejecutarse mientras `storeId` comience con `store_`. |
| `isLoading` | `RxBool`. `true` durante la carga del backend. Vistas reactivas muestran spinner mientras esté activo. |
| Rutas protegidas | Todas las rutas `/admin/*` requieren sesión activa. Sin sesión, redirigen a `/login`. |

---

## 2. Pantallas — Requisitos funcionales

---

### 2.1 Login (`/login`)

**Descripción:** Pantalla de inicio de sesión para administradores de tienda y administradores de plataforma.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| L-01 | El formulario debe tener campos "Correo electrónico" y "Contraseña". |
| L-02 | El botón "Iniciar sesión" debe estar deshabilitado si algún campo está vacío. |
| L-03 | Credenciales correctas de admin de tienda redirigen a `/admin`. |
| L-04 | Credenciales correctas de admin de plataforma redirigen a `/general-admin`. |
| L-05 | Credenciales incorrectas muestran mensaje de error visible sin limpiar el correo. |
| L-06 | Mientras la petición está en curso, el botón muestra indicador de carga y se deshabilita. |
| L-07 | Si hay sesión activa al abrir `/login`, redirige automáticamente al destino correcto. |

---

### 2.2 Dashboard Admin (`/admin`)

**Descripción:** Pantalla principal del administrador de tienda. Muestra métricas clave, actividad reciente y acceso a todas las secciones.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| D-01 | Muestra el nombre y logo de la tienda en el sidebar. |
| D-02 | Muestra tarjetas de estadísticas: Canjes hoy, Puntos emitidos, Usuarios activos, Stock crítico. |
| D-03 | Cada tarjeta refleja datos reales del backend cuando `storeId` es un UUID válido. |
| D-04 | Muestra banner de "Meta Mensual de Fidelización" con barra de progreso, porcentaje y días restantes. El banner no desborda horizontalmente. |
| D-05 | La sección "Tarjeta virtual de puntos" muestra el diseño de la tarjeta de la tienda. |
| D-06 | La sección "Actividad reciente" muestra las últimas operaciones de la tienda. |
| D-07 | Todos los ítems del sidebar tienen navegación funcional: Inicio, Canjes, Canjes y Beneficios, Historial, Estadísticas, PIN, Seguridad, Cerrar sesión. |
| D-08 | Al abrir la pantalla no se producen errores de consola tipo `setState() called during build`. |
| D-09 | Mientras `isLoading = true`, los datos muestran valores placeholder o spinner; cuando termina, los datos reales reemplazan los dummy. |

---

### 2.3 Inventario (`/admin/inventario`)

**Descripción:** Gestión del catálogo de productos de la tienda con búsqueda, filtros por categoría y paginación.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| INV-01 | Muestra lista paginada de productos con nombre, categoría, precio, stock y estado. |
| INV-02 | La búsqueda por nombre filtra resultados en tiempo real (debounce recomendado). |
| INV-03 | El filtro de categoría reduce la lista al subconjunto seleccionado. |
| INV-04 | La paginación permite avanzar y retroceder páginas; muestra `X de Y productos`. |
| INV-05 | El botón "Agregar producto" navega a `/admin/add-product`. |
| INV-06 | Los botones de navegación del sidebar (Equipo, Pedidos, etc.) dirigen a las pantallas correctas. |
| INV-07 | La pantalla carga datos del backend **solo cuando `storeId` es un UUID real**, nunca con `store_1`. |
| INV-08 | Al abrir la pantalla no se producen errores `setState() called during build`. Los datos se cargan después del primer frame. |
| INV-09 | Productos con stock igual a 0 se muestran con indicador visual de "Sin stock". |

---

### 2.4 Premios y Beneficios (`/admin/premios`)

**Descripción:** Gestión de los premios que los clientes pueden canjear con puntos. Incluye creación, edición y control de stock.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| P-01 | Muestra lista de premios con nombre, puntos requeridos, stock y categoría. |
| P-02 | El botón "Nuevo premio" abre formulario de creación. |
| P-03 | Cada premio tiene opciones de editar y eliminar. |
| P-04 | El filtro por categoría funciona correctamente. |
| P-05 | La búsqueda por nombre filtra la lista. |
| P-06 | El sidebar muestra nombre y subtítulo de la tienda correctamente (sin bucles infinitos de Obx). |
| P-07 | La pantalla carga datos después del primer frame (sin `setState during build`). |
| P-08 | Los botones de navegación del sidebar (Equipo, Pedidos) dirigen a las pantallas correspondientes. |
| P-09 | Los cambios de stock se reflejan inmediatamente tras guardar. |

---

### 2.5 Empleados / Equipo (`/admin/empleados`)

**Descripción:** Gestión del equipo de la tienda. Permite ver, asignar roles y cambiar permisos de los miembros.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| E-01 | Muestra lista de empleados con nombre, rol asignado y estado. |
| E-02 | Al seleccionar un empleado, el panel derecho muestra sus permisos por rol. |
| E-03 | Es posible cambiar el rol de un empleado (ADMIN, VIEWER, MEMBER). |
| E-04 | Los roles disponibles se cargan del backend (`/stores/{id}/roles/permissions/`) solo cuando `storeId` es real. |
| E-05 | La lista de usuarios de la tienda se carga solo cuando `storeId` es un UUID válido (no `store_1`). |
| E-06 | La pantalla carga datos después del primer frame (sin `setState during build`). |
| E-07 | El botón "Invitar empleado" abre el flujo de invitación. |
| E-08 | Los empleados sin rol asignado se muestran como "Sin rol". |

---

### 2.6 Canjes — Validación e Historial (`/voucher-history`)

**Descripción:** Pantalla central de gestión de vouchers. Tiene dos tabs: **Validación** (canjear vouchers manualmente) y **Panel** (historial de operaciones).

#### Tab: Validación

| ID | Requisito |
|---|---|
| CV-01 | El campo de código acepta texto libre y el botón de búsqueda activa la vista previa del voucher. |
| CV-02 | Al encontrar un voucher válido, muestra: imagen del producto, nombre, coste en puntos, estado y datos del cliente. |
| CV-03 | El botón "Confirmar canje" está habilitado solo si el voucher está disponible (no canjeado, no expirado) y `isLoading = false`. |
| CV-04 | Al confirmar el canje, se ejecuta POST al backend, se limpia la vista previa y se recarga el historial. |
| CV-05 | Voucher no encontrado muestra mensaje de error bajo el campo. |
| CV-06 | Voucher ya canjeado o expirado muestra badge de estado en rojo. |
| CV-07 | El checkbox de "Confirmo identidad del cliente" es requerido visualmente (no bloquea el botón en v1). |
| CV-08 | El botón "Escanear código" muestra aviso informativo (funcional solo en móvil). |
| CV-09 | El botón "Pagar Código" abre diálogo de confirmación antes de iniciar el pago via Stripe. |

#### Tab: Panel (Historial)

| ID | Requisito |
|---|---|
| CH-01 | Muestra tabla con columnas: Fecha, Usuario/Alias, Premio/Pts, Estado, Referencia. |
| CH-02 | Los tabs Todos / Pendientes / Entregados / Expirados filtran la tabla correctamente. |
| CH-03 | El buscador filtra por alias, premio o referencia. |
| CH-04 | El filtro de fecha acepta formato `dd/MM/yyyy` y llama al backend con el formato `YYYY-MM-DD`. |
| CH-05 | La paginación funciona y muestra `X–Y de Z` registros. |
| CH-06 | Al clicar una fila se abre diálogo con detalle del voucher. |
| CH-07 | El botón "Exportar CSV" descarga el historial en formato CSV. |
| CH-08 | Las tarjetas de analítica inferiores muestran "Canjes por estado" y "Premios más canjeados". |
| CH-09 | Si no hay vouchers, muestra estado vacío "No hay operaciones en este periodo". |

#### Sidebar

| ID | Requisito |
|---|---|
| CS-01 | "Canjes" (tab Validación) y "Historial" (tab Panel) en el sidebar cambian el tab activo. |
| CS-02 | El ítem seleccionado en el sidebar refleja el tab actual. |

---

### 2.7 Confirmar Entrega (`/admin/confirmar-entrega`)

**Descripción:** Flujo simplificado para confirmar la entrega de un pedido o canje mediante código.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| CE-01 | Muestra campo para introducir código de canje o pedido. |
| CE-02 | Al buscar, muestra detalles del voucher/pedido: producto, cliente, puntos. |
| CE-03 | El botón "Confirmar entrega" ejecuta la validación en el backend. |
| CE-04 | Muestra el nombre de la tienda sin errores de Obx (acceso directo a `currentStore`, no envuelto en Obx innecesario). |
| CE-05 | El resultado exitoso muestra confirmación y limpia el formulario. |

---

### 2.8 Incidencias (`/admin/incidencias`)

**Descripción:** Gestión de incidencias relacionadas con vouchers o pedidos.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| INC-01 | Permite buscar un voucher por código para asociarle una incidencia. |
| INC-02 | El formulario de incidencia requiere descripción del problema. |
| INC-03 | El envío registra la incidencia en el backend. |
| INC-04 | Muestra historial de incidencias previas de la tienda. |

---

### 2.9 Reseñas (`/admin/reviews`)

**Descripción:** Visualización y gestión de reseñas de clientes. Permite filtrar, ordenar y responder.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| R-01 | Muestra lista paginada de reseñas con: autor, puntuación, texto, fecha. |
| R-02 | Los filtros (Positivas, Negativas, Sin responder, Ocultas) reducen la lista. |
| R-03 | El orden por "Recientes" / "Puntuación ↑" / "Puntuación ↓" reorganiza la lista. |
| R-04 | Los datos se cargan **solo cuando `storeId` es un UUID real**. Con ID dummy, la pantalla espera silenciosamente. |
| R-05 | Las tarjetas de estadísticas (puntuación media, total reseñas, % positivas) se muestran correctamente. |
| R-06 | El botón "Responder" abre campo de texto; al enviar, registra la respuesta en el backend. |
| R-07 | Reseñas con respuesta existente muestran la respuesta en la tarjeta. |
| R-08 | La paginación permite cargar más reseñas. |
| R-09 | Al navegar a la pantalla, no se producen llamadas 404 a `stores/store_1/reviews/`. |

---

### 2.10 Analíticas (`/admin/analytics`)

**Descripción:** Dashboard de métricas avanzadas de la tienda con gráficas de canjes, tendencias y productos.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| AN-01 | Muestra gráfica de canjes diarios (últimos 30 días). |
| AN-02 | Muestra métricas agregadas: total canjes, puntos emitidos, usuarios únicos. |
| AN-03 | Muestra tabla/lista de "Premios más canjeados". |
| AN-04 | Muestra distribución de canjes por estado (entregados, pendientes, expirados). |
| AN-05 | Los datos no se cargan con `storeId = store_1`. |
| AN-06 | El botón "Historial" en el sidebar navega a `/voucher-history`. |

---

### 2.11 Seguridad y PIN (`/admin/seguridad`)

**Descripción:** Gestión de la seguridad de la tienda: PIN de autorización, log de actividad y configuración 2FA.

#### Requisitos funcionales — PIN

| ID | Requisito |
|---|---|
| SP-01 | Muestra el estado actual del PIN (activo/inactivo, última actualización). |
| SP-02 | El botón "Cambiar PIN" abre diálogo con campos: PIN actual, PIN nuevo, Confirmar PIN nuevo. |
| SP-03 | El PIN nuevo debe tener mínimo 4 dígitos; si no, muestra error. |
| SP-04 | Si "PIN nuevo" ≠ "Confirmar PIN nuevo", muestra error "Los PINs no coinciden". |
| SP-05 | El botón "Regenerar" (Ocultar si ya se generó) genera un PIN aleatorio y lo muestra una sola vez. |
| SP-06 | El PIN generado puede copiarse al portapapeles con un tap. |
| SP-07 | El botón "PIN" en el sidebar de Configuración (`admin_settings_view`) abre el diálogo de cambio de PIN. |

#### Requisitos funcionales — Seguridad general

| ID | Requisito |
|---|---|
| SS-01 | Muestra log de actividad de seguridad (inicios de sesión, cambios de PIN, etc.). |
| SS-02 | Los eventos del log muestran: tipo, descripción, fecha/hora. |
| SS-03 | El indicador 2FA refleja el estado actual (activo/inactivo). |

---

### 2.12 Configuración de Tienda (`/admin-settings`)

**Descripción:** Edición de la información de la tienda: nombre, dirección, logo, banner, datos fiscales y configuración de acceso.

#### Requisitos funcionales

| ID | Requisito |
|---|---|
| CFG-01 | Muestra formulario editable con: Nombre, Dirección, Dirección de facturación, ID fiscal, Categoría. |
| CFG-02 | El checkbox "Misma dirección para facturación" copia el campo de dirección. |
| CFG-03 | El botón "Guardar cambios" hace PATCH al backend y muestra confirmación. |
| CFG-04 | Los cambios se reflejan en el sidebar (nombre, subtítulo, logo) tras guardar. |
| CFG-05 | El banner y logo de la tienda se cargan desde URL cuando están disponibles; si no, muestran placeholder. |
| CFG-06 | Los botones de subida de banner/logo permiten seleccionar imagen y hacer upload. |
| CFG-07 | La sección de equipo muestra lista de usuarios de la tienda (cargada desde backend). |
| CFG-08 | El botón "PIN" en el sidebar abre el diálogo de cambio de PIN directamente. |
| CFG-09 | No se producen errores `setState during build` al abrir la pantalla. |
| CFG-10 | El banner y logo están envueltos en `Obx` con trigger reactivo `_ctrl.storeId.value` para actualizarse cuando cambia la tienda. |

---

### 2.13 General Admin — Panel de Plataforma (`/general-admin`)

**Descripción:** Panel reservado para administradores de la plataforma Letdem. Gestiona todos los comercios, usuarios, configuraciones legales y soporte.

#### Sub-pantallas

| Ruta | Pantalla | Función principal |
|---|---|---|
| `/general-admin` | Dashboard | Vista general de comercios y métricas de plataforma |
| `/general-admin/comercios` | Comercios | Lista y gestión de tiendas adheridas |
| `/general-admin/gdpr` | GDPR Requests | Gestión de solicitudes de derechos RGPD |
| `/general-admin/sensitive-policies` | Políticas sensibles | Gestión de consentimientos y políticas legales |
| `/general-admin/legal-consents` | Consentimientos legales | Historial de consentimientos aceptados |
| `/general-admin/kybc` | KYB/KYC | Verificación de identidad de comercios |
| `/general-admin/support` | Soporte | Tickets de soporte |
| `/general-admin/stripe-disputes` | Disputas Stripe | Gestión de chargebacks y disputas de pago |

#### Requisitos comunes a todas las sub-pantallas

| ID | Requisito |
|---|---|
| GA-01 | Solo accesible para usuarios con rol `PLATFORM_ADMIN`. |
| GA-02 | El sidebar muestra las secciones disponibles con navegación funcional. |
| GA-03 | Ninguna pantalla carga datos con IDs dummy o sin autenticación. |
| GA-04 | Los fondos blancos se definen únicamente dentro de `BoxDecoration(color: Colors.white)`, nunca con `color:` y `decoration:` simultáneamente en un mismo `Container`. |

---

## 3. Comportamientos transversales (cross-cutting)

### 3.1 Carga de datos y storeId

| ID | Requisito |
|---|---|
| T-01 | Ninguna llamada al backend usa `storeId = store_1` o variantes dummy. |
| T-02 | Si el backend tarda en responder, la pantalla muestra datos placeholder o spinner, no error visible. |
| T-03 | Cuando `_loadFromBackend` completa con éxito, todos los datos reactivos se actualizan automáticamente en la UI. |
| T-04 | Si `fetchStores` devuelve lista vacía, la aplicación no crashea; mantiene datos dummy sin llamar otros endpoints. |

### 3.2 Reactividad GetX

| ID | Requisito |
|---|---|
| T-05 | Ninguna pantalla produce el error `setState() or markNeedsBuild() called during build`. |
| T-06 | Las llamadas a métodos del controller desde `initState` se realizan dentro de `WidgetsBinding.instance.addPostFrameCallback`. |
| T-07 | Los widgets `Obx()` solo acceden a propiedades reactivas (`.value`, `RxList`, `RxString`, etc.); accesos a `late StoreModel currentStore` van fuera de Obx o incluyen un trigger reactivo (`_ctrl.storeId.value`). |

### 3.3 Layout y responsividad

| ID | Requisito |
|---|---|
| T-08 | Ninguna pantalla produce errores `RenderFlex overflowed by N pixels`. |
| T-09 | Los textos largos en badges o tarjetas tienen `overflow: TextOverflow.ellipsis` y están envueltos en `Flexible` o `Expanded`. |
| T-10 | El layout funciona correctamente en resoluciones de escritorio ≥ 1280 px de ancho. |

### 3.4 Navegación

| ID | Requisito |
|---|---|
| T-11 | Todos los ítems del sidebar con `onTap` navegan a la ruta correcta. |
| T-12 | Los botones "Volver" / back del navegador no dejan al usuario en un estado inconsistente. |
| T-13 | El ítem activo del sidebar (selected) corresponde a la pantalla actual. |

### 3.5 Autenticación y sesión

| ID | Requisito |
|---|---|
| T-14 | "Cerrar Sesión" en cualquier pantalla invalida la sesión y redirige a `/login`. |
| T-15 | Recargar la página con sesión activa redirige a la pantalla correcta (no a login). |
| T-16 | Recargar sin sesión redirige a `/login`. |

---

## 4. Criterios de aceptación generales

Una pantalla se considera **aceptada** cuando:

1. Abre sin errores de consola (no `setState during build`, no errores de `Obx`, no 404 con `store_1`).
2. Muestra datos reales del backend dentro de los primeros 3 segundos con conexión normal.
3. Todos los botones/ítems de navegación tienen acción definida y funcionan.
4. No hay desbordamientos visuales (overflow) en resolución 1280×800 o superior.
5. Las acciones del usuario (guardar, canjear, filtrar, paginar) producen la respuesta esperada o un mensaje de error claro.

---

## 5. Escenarios de prueba prioritarios

| Prioridad | Escenario | Pantallas |
|---|---|---|
| 🔴 Alta | Abrir cada pantalla sin errores de consola | Todas |
| 🔴 Alta | Los datos del backend reemplazan los datos dummy tras la carga | Dashboard, Inventario, Reseñas, Historial |
| 🔴 Alta | Canjear un voucher con código válido | Historial (tab Validación) |
| 🔴 Alta | Cambiar PIN desde el sidebar de Configuración | Admin Settings |
| 🟡 Media | Filtrar y paginar vouchers en el historial | Historial (tab Panel) |
| 🟡 Media | Buscar producto en inventario | Inventario |
| 🟡 Media | Cambiar rol de un empleado | Empleados |
| 🟡 Media | Guardar cambios de configuración de tienda | Configuración |
| 🟢 Baja | Exportar CSV del historial | Historial (tab Panel) |
| 🟢 Baja | Responder una reseña | Reseñas |
| 🟢 Baja | Reportar incidencia en un voucher | Incidencias / Validación |
