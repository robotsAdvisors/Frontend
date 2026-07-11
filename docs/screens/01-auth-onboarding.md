# 01 · Auth & Onboarding

Este grupo cubre el arranque de la app y el flujo de autenticación de "letdem": la pantalla inicial de splash que decide el destino según la sesión, la bienvenida de onboarding, el inicio de sesión (con soporte para roles de administrador y login social con Google) y la recuperación de contraseña. Todas las rutas base del backend usan el prefijo `/api/v1` (definido en `lib/utils/api_config.dart`, con `baseUrl` por defecto `https://api.letdem.net`).

### Splash (`/splash`)
- **Archivo:** `lib/app/modules/splash/views/splash_view.dart`
- **Ruta:** `/splash` (constante `Routes.SPLASH`) — pantalla INICIAL de la app
- **Controller / Binding:** `SplashController` / `SplashBinding`
- **Propósito:** Pantalla de arranque con logo animado; mientras se muestra, decide a qué pantalla redirigir según si hay sesión activa y el rol del usuario.
- **Contenido / widgets clave:** `Scaffold` con fondo en `LinearGradient` (colores del tema), logo SVG (`assets/vectors/letdem_logo.svg`) dentro de una tarjeta blanca con sombra y animación fade/slide (`flutter_animate`), y el tagline "Tu marketplace de confianza". No hay inputs ni interacción.
- **Endpoints backend consumidos:** `GET /api/v1/users/me` (vía `AuthRepository.instance.fetchMe()`, solo si el usuario ya está logueado, para refrescar datos y rol).
- **Estados manejados:** Espera fija de 2 segundos (`Future.delayed`) antes de redirigir; no muestra loading/error explícito en la UI. La decisión de navegación depende de `AuthService.isLoggedIn`/`MySharedPref.getIsLoggedIn()` y del rol persistido.
- **Navegación:** Es el punto de entrada. Tras el delay, en `onInit`:
  - Si hay sesión y rol `store_admin` o `store_viewer` → `Routes.ADMIN`.
  - Si hay sesión y rol `general_admin` → `Routes.GENERAL_ADMIN`.
  - Si hay sesión con otro rol (customer) → `Routes.BASE`.
  - Si no hay sesión → `Routes.WELCOME`.
  - Todas las transiciones usan `Get.offNamed` (reemplazan la pantalla actual).
- **Notas:** La vista llama `Get.put(SplashController())` directamente en `build`, además del `Get.lazyPut` del binding. `fetchMe()` es autoritativo: guarda el rol devuelto por el backend y evita degradar un rol privilegiado a `customer`. Roles definidos como constantes en `AuthService` (`customer`, `store_admin`, `store_viewer`, `general_admin`).

### Bienvenida (`/welcome`)
- **Archivo:** `lib/app/modules/welcome/views/welcome_view.dart`
- **Ruta:** `/welcome` (constante `Routes.WELCOME`)
- **Controller / Binding:** `WelcomeController` / `WelcomeBinding`
- **Propósito:** Pantalla de onboarding/bienvenida que presenta la marca e invita al usuario a comenzar el flujo de login.
- **Contenido / widgets clave:** `Scaffold` blanco con `SafeArea` + `SingleChildScrollView` responsivo (`LayoutBuilder`, `ConstrainedBox` maxWidth 420). Logo SVG, título "Bienvenido a Letdem", descripción del marketplace y botón `CustomButton` "Comenzar". Todos los elementos tienen animaciones fade/slide.
- **Endpoints backend consumidos:** ninguno directo (el `WelcomeController` está vacío).
- **Estados manejados:** ninguno; es una vista estática sin loading/error/vacío.
- **Navegación:** Se llega desde `/splash` cuando no hay sesión. El botón "Comenzar" navega a `Routes.LOGIN` mediante `Get.offNamed` (reemplaza welcome por login).
- **Notas:** `WelcomeController` es una clase vacía (`class WelcomeController extends GetxController {}`); no hay lógica ni validaciones. Sin roles ni permisos.

### Inicio de sesión (`/login`)
- **Archivo:** `lib/app/modules/login/views/login_view.dart`
- **Ruta:** `/login` (constante `Routes.LOGIN`)
- **Controller / Binding:** `LoginController` / `LoginBinding`
- **Propósito:** Autenticar al usuario por email/contraseña o con Google, con selección de rol de administrador (Tienda, Viewer, Super Admin) para el panel de administración.
- **Contenido / widgets clave:** `Scaffold` con fondo en gradiente y "blobs" decorativos (`Stack` + `Positioned`), tarjeta blanca con `Form` (`controller.formKey`). Incluye: banner "Modo administrador — <label>" reactivo (`Obx`), logo SVG, campos `CustomFormField` de correo y contraseña (con toggle de visibilidad vía `hidePassword`), enlace "¿Olvidaste tu contraseña?", botón principal (`ElevatedButton`) cuyo texto/color/íconos cambian según el rol y `isLoading`, botón `OutlinedButton` "Google", una fila de chips de rol (`_adminRoleChip`: Tienda/Viewer/Super Admin) y un footer con enlaces Términos/Privacidad/Ayuda.
- **Endpoints backend consumidos (vía `AuthService` → `AuthRepository`):**
  - `POST /api/v1/auth/login/` (`ApiConfig.authLogin`) en `login()`.
  - `GET /api/v1/users/me` (`ApiConfig.me`) tras el login para obtener rol autoritativo.
  - `POST /api/v1/auth/social-login/` (`ApiConfig.authSocialLogin`) en `loginWithGoogle()`, precedido por el flujo Google Sign-In + Firebase (intercambio del Firebase ID token por JWT propio).
  - (`register()` existe en el controller y usaría `POST /api/v1/auth/signup/` — `ApiConfig.authSignup` — pero no está cableado a ningún botón de esta vista.)
- **Estados manejados:**
  - Loading: `RxBool isLoading`; deshabilita botones y cambia el texto del botón a "Cargando...".
  - Error: se capturan `ApiException` y errores genéricos; se muestran con `Get.snackbar` (posición inferior). Para 401/400 el mensaje se traduce a "Correo o contraseña incorrectos."; los errores de Google se acortan/traducen en `_shortenError`.
  - Éxito: navegación directa (sin mensaje de éxito).
  - Validación de formulario inline vía `validateEmail`/`validatePassword`.
- **Navegación:** Se llega desde `/welcome` (botón "Comenzar"). Tras login/registro/Google exitoso navega con `Get.offAllNamed` a: `Routes.ADMIN` (store_admin o store_viewer), `Routes.GENERAL_ADMIN` (general_admin) o `Routes.BASE` (resto). El enlace "¿Olvidaste tu contraseña?" navega a `Routes.FORGOT_PASSWORD` con `Get.toNamed`.
- **Notas:** El rol inicial seleccionado es `AuthService.storeAdminRole`. Los chips de rol cambian `controller.selectedRole` y con ello el estilo del botón (color `0xFF5B21B6`/`0xFF7C3AED`) y el label ("Entrar como Administrador" vs "Iniciar Sesión"). Validaciones: email con `GetUtils.isEmail`, contraseña mínima de 6 caracteres. Los enlaces del footer (Términos/Privacidad/Ayuda) tienen `onPressed: () {}` vacíos (sin acción implementada). Google usa `google_sign_in` + `firebase_auth`; en web usa `signInWithPopup`.

### Recuperar contraseña (`/forgot-password`)
- **Archivo:** `lib/app/modules/login/views/forgot_password_view.dart`
- **Ruta:** `/forgot-password` (constante `Routes.FORGOT_PASSWORD`)
- **Controller / Binding:** no usa controller ni binding de GetX — es un `StatefulWidget` (`_ForgotPasswordViewState`) que gestiona su propio estado y llama directamente a `AuthRepository.instance`.
- **Propósito:** Permitir al usuario solicitar un enlace/OTP de restablecimiento de contraseña ingresando su email.
- **Contenido / widgets clave:** `Scaffold` blanco con `AppBar` ("Reset Password" + botón atrás), ícono de candado en círculo morado, títulos "Forgot Password?" y descripción, `TextField` de email, botón `ElevatedButton` "Send Reset Link" (con `CircularProgressIndicator` mientras envía y estado "Link Sent!" al completar), y enlace "Back to Login".
- **Endpoints backend consumidos:** `POST /api/v1/auth/password-reset/` (`ApiConfig.authResetPassword`, vía `AuthRepository.instance.resetPassword(email:)`).
- **Estados manejados:**
  - Loading: `bool _sending` → muestra spinner y deshabilita el botón.
  - Éxito: `bool _sent` → botón queda deshabilitado, en gris, con texto "Link Sent!"; se muestra `Get.snackbar` verde "Enlace enviado / Revisa tu bandeja de entrada.".
  - Error: valida email localmente (no vacío y contiene `@`) mostrando snackbar rojo "Email inválido"; los fallos de red muestran snackbar rojo con el mensaje de `ApiException` o "No se pudo enviar el enlace.".
- **Navegación:** Se llega desde `/login` (enlace "¿Olvidaste tu contraseña?", `Get.toNamed`). El botón atrás del AppBar y el enlace "Back to Login" regresan con `Get.back()`.
- **Notas:** Textos de la UI en inglés (a diferencia del resto de pantallas en español). No hay reingreso ni verificación de OTP en esta pantalla: `resetPassword` acepta parámetros opcionales `otp`/`newPassword`/`confirmPassword` pero aquí solo se envía `email`. Validación de email mínima (solo comprueba presencia de `@`). Color de marca `0xFF7C3AED`. Sin roles ni permisos.
