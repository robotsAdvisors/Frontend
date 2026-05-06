# Letdem Marketplace (Flutter)

Aplicacion Flutter multiplataforma (Android, iOS, Web) para Letdem Marketplace.

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
- Integracion inicial con Firebase Auth.

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
- Dashboard de vouchers.
- Vista de vouchers responsive:
	- Mobile: cards.
	- Desktop: DataTable.
- Historial de vouchers.

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

- Integracion backend Django para datos reales.
- Deep-linking y navegacion por URL completa en web.
- Hardening de capa de repositorios y servicios.
- Pruebas de integracion end-to-end.

## Creditos

Proyecto mantenido por el equipo de Letdem Marketplace.
