# 02 · Cliente / Marketplace

Este documento describe el grupo de pantallas del lado **cliente / marketplace** de la app Flutter (GetX) "letdem": el contenedor con navegación inferior, el home, la categoría, el listado de productos, el detalle de producto, el carrito y el listado de tiendas. Para cada pantalla se detalla su vista, controller, binding, los endpoints reales que consume (a través de `MarketplaceRepository` y `ApiConfig`, con prefijo `/api/v1`) y su flujo de navegación. Donde un dato no puede determinarse con certeza del código, se indica explícitamente.

> Nota general sobre endpoints: `ApiConfig.baseUrl` por defecto es `https://api.letdem.net` y `ApiConfig.apiPrefix` es `/api/v1`, por lo que todas las rutas de API mostradas cuelgan de `https://api.letdem.net/api/v1`.

---

### Base / Contenedor con navegación inferior (`/base`)
- **Archivo:** `lib/app/modules/base/views/base_view.dart`
- **Ruta:** `/base` (constante `Routes.BASE`)
- **Controller / Binding:** `BaseController` / `BaseBinding`
- **Propósito:** Contenedor principal de la experiencia de cliente. Aloja las cinco pestañas mediante un `IndexedStack` y ofrece navegación inferior (móvil) o cabecera con tabs (escritorio).
- **Contenido / widgets clave:**
  - Layout responsivo: si el ancho es ≥ 900 px muestra un `_desktopHeader` (logo, buscador, tabs "Marketplace/Earning/Rewards", campana de notificaciones, badge de puntos y avatar); si es menor muestra `BottomNavigationBar` + `FloatingActionButton` central.
  - `_pages` (índices del `IndexedStack`): `HomeView` (0), `CategoryView` (1), `Center()` placeholder (2, hueco del botón central), `CalendarView` (3), `ProfileView` (4).
  - Botón flotante central: `CircleAvatar` con icono de carrito y un `badges.Badge` (`GetBuilder` id `'CartBadge'`) que muestra `controller.cartItemsCount`.
  - Badge de puntos en escritorio con `controller.userPoints` (Obx).
- **Endpoints backend consumidos:** Ninguno directo. El conteo del carrito sale de `DummyHelper.products` (datos locales). `userPoints` lo rellena `HomeController.loadOrdersStats()` al inicializar el home.
- **Estados manejados:** Sin estados de carga/error propios. Estado reactivo del índice de pestaña (`currentIndex` vía `update()`), contador de carrito (`update(['CartBadge'])`) y puntos (`userPoints` Obx).
- **Navegación:**
  - Se llega a `/base` tras el flujo de autenticación/arranque (login o splash — origen exacto no determinado en este grupo).
  - Botón flotante de carrito → `Get.toNamed(Routes.CART)` (`/cart`).
  - Botón "Ver misiones" y tabs de escritorio cambian de pestaña vía `controller.changeScreen(index)`; el tab "Rewards" apunta al índice 3 (Calendar). Avatar (escritorio) → pestaña Perfil (índice 4).
- **Notas:**
  - Rol: cliente final.
  - `cartItemsCount` se calcula sobre `DummyHelper.products` (datos dummy en memoria), no sobre un carrito de backend. El botón central del `BottomNavigationBar` (índice 2) es un hueco decorativo bajo el FAB.
  - El buscador del header de escritorio no tiene lógica de búsqueda conectada (solo UI). Los botones de campana no tienen acción (`onPressed: () {}`).

---

### Home (`/home`)
- **Archivo:** `lib/app/modules/home/views/home_view.dart`
- **Ruta:** `/home` (constante `Routes.HOME`)
- **Controller / Binding:** `HomeController` / `HomeBinding` (también registrado en `BaseBinding`)
- **Propósito:** Pantalla de inicio del marketplace. Muestra el hero banner, categorías, productos destacados y las estadísticas de puntos del cliente.
- **Contenido / widgets clave:**
  - Layout responsivo (`_desktopLayout` ≥ 900 px con sidebar de categorías + `_objetivoCard`; `_mobileLayout` con saludo, buscador, hero, tarjeta de stats y grid de destacados).
  - `_heroBanner` con imagen (`controller.cards`) y CTA ("Explorar ahora", "Ver misiones" → `Routes.CALENDAR`).
  - Sidebar escritorio: lista de categorías con conteos y filtro por `selectedCategoryId`; `_objetivoCard` con barra de progreso hacia objetivo de 3000 pts (target hardcodeado).
  - Tarjetas de producto (`_featuredCard`, `_portraitProductCard`, `_mobileProductCard`) que muestran nombre, categoría, tienda, precio en pts.
  - `_mobileStatsCard` con `stats.currentPoints`, compras, gastado y ahorrado.
  - Toggle de tema (`onChangeThemePressed`) y navegación a ajustes de perfil.
- **Endpoints backend consumidos:**
  - `GET /api/v1/marketplace/categories/` — `MarketplaceRepository.fetchCategories()` (`ApiConfig.categories`).
  - `GET /api/v1/marketplace/products/` — `MarketplaceRepository.fetchProducts()` (`ApiConfig.products`).
  - `GET /api/v1/marketplace/orders/?page=1&page_size=1` — `MarketplaceRepository.fetchOrders()` (`ApiConfig.orders`); de aquí se extrae `meta.stats` (`OrdersStats`) para puntos/estadísticas.
- **Estados manejados:**
  - Loading: `controller.isLoading` (CircularProgressIndicator en destacados).
  - Vacío: mensaje "No hay productos disponibles.".
  - Error/fallback: si el catálogo falla, `loadCatalog()` cae a `DummyHelper.categories`/`products` para no dejar la UI vacía; `errorMessage` almacena el error.
  - Éxito: listas `categories`/`products` pobladas; `ordersStats` opcional (card oculto si es null, p. ej. sin sesión).
- **Navegación:**
  - Se llega desde la pestaña Home del contenedor `/base`.
  - Tarjetas de producto → `Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product)` (`/product-details`).
  - "Ver más productos" → `Get.toNamed(Routes.PRODUCTS)` (`/products`).
  - "Ver misiones" → `Routes.CALENDAR`. Icono ajustes → `Routes.PROFILE`.
- **Notas:**
  - Rol: cliente. Fallback a datos dummy cuando no hay backend/sesión.
  - `loadOrdersStats()` falla en silencio si el usuario no está autenticado y además sincroniza `BaseController.userPoints`.
  - El objetivo de 3000 pts y el texto "Smartwatch" están hardcodeados en `_objetivoCard`. El buscador (`CustomFormField`) es solo UI en esta pantalla. `cards` son assets locales (`Constants.card1..3`).

---

### Category (`/category`)
- **Archivo:** `lib/app/modules/category/views/category_view.dart`
- **Ruta:** `/category` (constante `Routes.CATEGORY`)
- **Controller / Binding:** `CategoryController` / `CategoryBinding` (también registrado en `BaseBinding`)
- **Propósito:** Pantalla placeholder para la sección de categorías; actualmente sin funcionalidad implementada.
- **Contenido / widgets clave:** `Scaffold` con `AppBar` (título "Category") y cuerpo `NoData(text: 'This is Category Screen')`.
- **Endpoints backend consumidos:** Ninguno.
- **Estados manejados:** Ninguno (pantalla estática de "sin datos").
- **Navegación:** Se muestra como pestaña índice 1 del contenedor `/base`. No navega a ninguna otra ruta.
- **Notas:** `CategoryController` está vacío (`class CategoryController extends GetxController {}`). Es claramente un stub/pendiente de implementación (TODO implícito).

---

### Products / Marketplace (`/products`)
- **Archivo:** `lib/app/modules/products/views/products_view.dart`
- **Ruta:** `/products` (constante `Routes.PRODUCTS`)
- **Controller / Binding:** `ProductsController` / `ProductsBinding`
- **Propósito:** Listado completo de productos del marketplace con búsqueda, filtro por categoría, filtro por tienda y scroll infinito (paginación).
- **Contenido / widgets clave:**
  - `StatefulWidget` con `ScrollController` que dispara `loadMore()` cerca del final.
  - `AppBar` con botón atrás, título "Marketplace" y botón buscar (limpia búsqueda).
  - `CustomFormField` de búsqueda (con debounce de 400 ms), `InputChip` de tienda activa (si `storeName` no vacío, con `clearStoreFilter`), texto "Mostrando X de N productos".
  - `ChoiceChip` por categoría (a partir de `controller.categories`, derivadas de los productos).
  - Grid responsivo (`SliverGrid`, 2/3/4 columnas) de `ProductItem`, con `RefreshIndicator` (pull-to-refresh) e indicador de "cargar más" / "Desliza para cargar más".
- **Endpoints backend consumidos:**
  - `GET /api/v1/marketplace/products/` con query `store`, `search`, `category`, `page`, `page_size` — `MarketplaceRepository.fetchProductsPage()` (`ApiConfig.products`). Devuelve envelope paginado `{data, meta}`.
- **Estados manejados:**
  - Loading inicial: `isLoading`.
  - Loading incremental: `isLoadingMore`.
  - Vacío: "No hay productos para el filtro seleccionado.".
  - Error/fallback: si falla y la lista está vacía, cae a `DummyHelper.products` (`_usingFallback = true`, que además desactiva `loadMore`); `errorMessage` guarda el error.
  - Éxito: `products` + `meta` (con `hasMore` para paginación).
- **Navegación:**
  - Se llega desde Home ("Ver más productos") y desde Stores (hoja de tienda → "Ver catálogo", con `arguments: {storeId, storeName}`).
  - Botón atrás → `Get.back()`. `ProductItem` navega al detalle (ver componente `product_item.dart`; ruta destino `Routes.PRODUCT_DETAILS` — comportamiento del componente, no determinado en esta vista).
- **Notas:**
  - Rol: cliente. Los argumentos `storeId`/`storeName` (opcionales) se leen en `onInit` para filtrar por tienda.
  - `filteredProducts` aplica además un filtrado defensivo en cliente (nombre, descripción, SKU, categoría) sobre lo ya recibido.
  - Comentario en el repositorio marca `ordering` como "MISSING ENDPOINT" (el backend aún no soporta `?ordering=` en `GET /marketplace/admin/products/`).

---

### Product Details (`/product-details`)
- **Archivo:** `lib/app/modules/product_details/views/product_details_view.dart`
- **Ruta:** `/product-details` (constante `Routes.PRODUCT_DETAILS`)
- **Controller / Binding:** `ProductDetailsController` / `ProductDetailsBinding`
- **Propósito:** Detalle de un producto para su canje por puntos, con imagen, descripción, precio en puntos y acción de "canjear" (que en realidad añade al carrito dummy).
- **Contenido / widgets clave:**
  - Layout responsivo (`_desktopLayout` ≥ 800 px con panel izquierdo de imagen + tags y panel derecho de detalles; `_mobileLayout` en `ListView`).
  - Imagen del producto con animaciones (`flutter_animate`), tags de features estáticos ("Empaque Sostenible", "Entrega Inmediata", "Garantía Oficial").
  - Nombre de tienda, título, precio en pts (formateado con `_formatPoints`), tarjeta "Product Overview" (descripción o texto por defecto), tarjeta "Redeem to unlock QR Code" y botón "Redeem Points Now".
  - Nota "By clicking redeem, N points will be deducted...".
- **Endpoints backend consumidos:** Ninguno directo. El producto llega por `Get.arguments` (modelo `ProductModel` ya cargado). El canje NO llama a `purchase/*`; solo incrementa la cantidad en el carrito local.
- **Estados manejados:** Sin loading/error propios (el modelo se recibe por argumentos). Estado implícito: descripción vacía → texto por defecto.
- **Navegación:**
  - Se llega desde Home (tarjetas de producto) y desde `ProductItem` en el listado `/products`, siempre con `arguments: product`.
  - Botón atrás / "Back to Marketplace" → `Get.back()`.
  - "Redeem Points Now" → `controller.onAddToCartPressed()`: si `product.quantity == 0` llama a `BaseController.onIncreasePressed(product.id)` (suma 1 al carrito dummy) y luego `Get.back()`.
- **Notas:**
  - Rol: cliente. El botón de "canjear" es engañoso respecto al backend: no ejecuta compra ni genera voucher; solo añade el producto al carrito local (`DummyHelper`).
  - Los tags de features y la tarjeta QR son estáticos/decorativos. `_formatPoints` formatea miles con coma.

---

### Cart / Carrito (`/cart`)
- **Archivo:** `lib/app/modules/cart/views/cart_view.dart`
- **Ruta:** `/cart` (constante `Routes.CART`)
- **Controller / Binding:** `CartController` / `CartBinding`
- **Propósito:** Muestra los productos añadidos al carrito y permite ejecutar la compra contra el backend.
- **Contenido / widgets clave:**
  - `AppBar` con botón atrás y título "Mi carrito 🛒".
  - `GetBuilder<CartController>`: si `products` está vacío → `NoData('¡Tu carrito está vacío!')`; si no, `ListView.separated` de `CartItem` con animaciones de entrada.
  - Botón "Comprar ahora" (`CustomButton`) visible solo si hay productos → `controller.onPurchaseNowPressed()`.
- **Endpoints backend consumidos:**
  - `POST /api/v1/marketplace/purchase/without-redeem/` — `MarketplaceRepository.purchaseWithoutRedeem()` (`ApiConfig.purchaseWithoutRedeem`), por defecto (`useRedeem = false`).
  - `POST /api/v1/marketplace/purchase/with-redeem/` — `MarketplaceRepository.purchaseWithRedeem()` (`ApiConfig.purchaseWithRedeem`), solo si se llama con `useRedeem = true`. Body: `product_id`, `quantity`, `payment_intent_id?`.
  - Se realiza una llamada por cada producto del carrito (bucle secuencial).
- **Estados manejados:**
  - Vacío: `NoData`.
  - Procesando: `isProcessing` (bandera interna durante la compra; no bloquea visualmente el botón en la vista).
  - Éxito: `clearCart()` + `Get.back()` + snackbar "Compra realizada".
  - Error: `ApiException`/error genérico → snackbar de error con el mensaje.
- **Navegación:**
  - Se llega desde el FAB de carrito en `/base`.
  - Botón atrás → `Get.back()`. Tras compra exitosa → `Get.back()`.
- **Notas:**
  - Rol: cliente. El contenido del carrito proviene de `DummyHelper.products` (los que tienen `quantity > 0`), es decir, estado local en memoria, no un carrito persistido en backend.
  - `clearCart()` pone `quantity = 0` a todos los productos dummy y refresca el contador en `BaseController`.
  - **Sub-widget — `CartItem`** (`lib/app/modules/cart/views/widgets/cart_item.dart`):
    - `GetView<CartController>` que representa una fila del carrito: imagen del producto (`Image.asset`), nombre, texto de precio "1kg, {price}$" y `ProductCountItem` para ajustar cantidad.
    - No consume endpoints; opera sobre el `ProductModel` recibido. El "1kg" está hardcodeado y la imagen se carga como asset local (`Image.asset`), no soporta URLs remotas.

---

### Stores / Tiendas (`/stores`)
- **Archivo:** `lib/app/modules/stores/views/stores_view.dart`
- **Ruta:** `/stores` (constante `Routes.STORES`)
- **Controller / Binding:** `StoresController` / `StoresBinding`
- **Propósito:** Listado de tiendas del marketplace con búsqueda, paginación por scroll y una hoja inferior (bottom sheet) con el detalle de cada tienda y acceso a su catálogo.
- **Contenido / widgets clave:**
  - `StatefulWidget` con `ScrollController` que dispara `loadMore()`.
  - `AppBar` con botón atrás, título "Tiendas" y botón refrescar (`fetchStores`).
  - `CustomFormField` de búsqueda (debounce 400 ms), texto "Mostrando X de N tiendas".
  - Grid responsivo (`SliverGrid`, 1/2/3 columnas) de `_StoreCard` (logo, nombre, dirección, nº de categorías) con `RefreshIndicator` e indicador de "cargar más".
  - `_openStoreSheet`: `DraggableScrollableSheet` con banner, logo, nombre, dirección, badge "Activa" (si `isPublished`), descripción, contacto (teléfono/email/web), categorías (chips), horarios y botón "Ver catálogo".
  - `_resolveImage` normaliza URLs relativas anteponiendo `ApiConfig.baseUrl`.
- **Endpoints backend consumidos:**
  - `GET /api/v1/marketplace/stores/` con query `search`, `category`, `page`, `page_size` — `MarketplaceRepository.fetchStoresPage()` (`ApiConfig.stores`). Envelope paginado `{data, meta}`.
- **Estados manejados:**
  - Loading inicial: `isLoading` (spinner cuando la lista está vacía).
  - Loading incremental: `isLoadingMore`.
  - Vacío/error: mensaje "No se pudieron cargar las tiendas." (si hay `errorMessage`) o "No hay tiendas para mostrar.".
  - Éxito: `stores` + `meta` (`hasMore` para paginación).
- **Navegación:**
  - Se llega desde `/stores` (origen concreto de entrada no determinado en este grupo; no aparece enlazada desde las otras vistas leídas).
  - Botón atrás → `Get.back()`.
  - En la hoja de detalle, "Ver catálogo" → elimina el `ProductsController` existente si está registrado (`Get.delete`) y navega `Get.toNamed(Routes.PRODUCTS, arguments: {storeId, storeName})` para forzar el filtro por tienda.
- **Notas:**
  - Rol: cliente. A diferencia de Products/Home, esta pantalla NO tiene fallback a datos dummy: si falla, deja `meta` vacío y muestra el mensaje de error.
  - `_StoreCard`, `_StoreLogo` e `_InfoRow` son widgets privados de la vista. Los logos/banners se cargan con `Image.network` (con placeholder de icono al fallar).
