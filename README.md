# Letdem Marketplace (Flutter)

Backoffice de Letdem construido con Flutter. **Se despliega como aplicacion web**;
los targets Android/iOS existen por la plantilla base pero no se publican.

El proyecto evoluciono desde una base UI de grocery a un marketplace con identidad Letdem, soporte de perfiles, autenticacion, panel de tienda y panel general de administracion.

## Estado actual

- Branding visual Letdem aplicado en tema claro/oscuro y componentes compartidos.
- Arquitectura GetX por modulos (bindings, controllers, views).
- Navegacion responsive:
	- Mobile: BottomNavigationBar + FAB.
	- Desktop/Web: NavigationRail lateral + header superior.
- Layout adaptativo en pantallas principales (home, productos, admin, perfil, historial).
- Selector de idioma en ajustes (espanol e ingles) y persistencia local.
- Modo oscuro con persistencia local.
- Avatar de perfil web-safe en base64 (sin dependencia de rutas de archivo locales).
- Autenticacion con Firebase Auth contra el proyecto `letdem-953ed`.
- Consume la API del backend Django en `https://api.letdem.net`.

## Funcionalidades

### Cliente

- Splash y bienvenida.
- Inicio con categorias, buscador y productos destacados.
- Listado de productos con filtros/chips.
- Detalle de producto (responsive: una columna en mobile, dos columnas en desktop).
- Carrito de compras con contador y accion de compra.
- Perfil con edicion de datos, idioma y modo oscuro.
- Historial de cliente.

### Tienda / Admin

- Panel de tienda con metricas.
- Gestion visual de productos.
- Dashboard de codigos de canje.
- Vista de codigos de canje responsive:
	- Mobile: cards.
	- Desktop: DataTable.
- Historial de codigos de canje.

### Administracion general

- Modulo de administracion general para gestion transversal.

## Stack tecnico

- Flutter
- GetX (rutas, inyeccion y estado)
- Firebase Core + Firebase Auth
- Shared Preferences
- flutter_screenutil
- flutter_animate
- flutter_svg
- badges
- carousel_slider
- image_picker

## Estructura principal

```text
lib/
	app/
		components/
		data/
			local/
			models/
			services/
		modules/
			admin/
			base/
			cart/
			category/
			customer_history/
			general_admin/
			home/
			login/
			product_details/
			products/
			profile/
			splash/
			welcome/
		routes/
	config/
		theme/
		translations/
```

## Requisitos

- Flutter SDK instalado
- Dart SDK compatible con el proyecto
- Android Studio o VS Code
- (Opcional) Xcode para iOS
- Cuenta Firebase configurada para autenticacion

### Firebase

El backoffice usa el proyecto `letdem-953ed` (numero `591264474291`). La
configuracion vive en dos sitios:

| Fichero | Contiene |
|---|---|
| `lib/firebase_options.dart` | Credenciales que lee `Firebase.initializeApp` |
| `web/index.html` | `google-signin-client_id`, el client OAuth web |

**Ojo:** `lib/firebase_options.dart` esta en el `.gitignore`, asi que no viaja en
el repositorio. Al clonar hay que regenerarlo:

```bash
flutterfire configure --project=letdem-953ed --platforms=web
```

El client OAuth web necesita ademas `https://admin.letdem.net` dado de alta en
*Authorized JavaScript origins* de Google Cloud Console, o el login fallara en
produccion aunque compile sin errores.

### Backend

Por defecto apunta al servidor real, sin necesidad de tocar codigo:

```
https://api.letdem.net/api/v1
```

Para otro entorno se pasa en tiempo de compilacion:

```bash
flutter run -d chrome --dart-define=LETDEM_API_BASE_URL=http://127.0.0.1:8000
flutter build web --dart-define=LETDEM_API_BASE_URL=https://otro.host
```

La constante vive en `lib/utils/api_config.dart`.

## Puesta en marcha

1. Clonar el repositorio.
2. Instalar dependencias:

```bash
flutter pub get
```

3. Ejecutar en entorno local:

```bash
flutter run
```

4. Ejecutar en web:

```bash
flutter run -d chrome
```

## Build

```bash
flutter build apk
flutter build ios
flutter build web
```

## Internacionalizacion

- Idiomas activos:
	- es_ES
	- en_US
	- ar_AR
- Idioma por defecto actual: espanol.

## Roadmap

- Deep-linking y navegacion por URL completa en web.
- Hardening de capa de repositorios y servicios.
- Pruebas de integracion end-to-end.

## Creditos

Proyecto mantenido por el equipo de Letdem Marketplace.
