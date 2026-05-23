/// Configuracion centralizada de la API del backend Django (Letdem).
///
/// Cambiar [baseUrl] segun el entorno:
/// - Desarrollo local (web):     http://127.0.0.1:8000
/// - Emulador Android:           http://10.0.2.2:8000
/// - Dispositivo fisico LAN:     http://<IP-de-tu-PC>:8000
/// - Produccion:                 https://api.letdem.com
class ApiConfig {
  ApiConfig._();

  /// Base host del backend (sin /api/v1).
  static const String baseUrl = String.fromEnvironment(
    'LETDEM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Prefijo de la API REST.
  static const String apiPrefix = '/api/v1';

  /// URL completa base para las peticiones.
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ---- Endpoints ----
  // Auth
  static const String authLogin = '/accounts/auth/login/';
  static const String authSignup = '/accounts/auth/signup/';
  static const String authSocialLogin = '/accounts/auth/social-login/';
  static const String authResetPassword = '/accounts/auth/reset-password/';
  static const String authSetPassword = '/accounts/auth/set-password/';
  static const String tokenRefresh = '/accounts/token/refresh/';

  // Profile
  static const String me = '/users/me';

  // Marketplace - catalogo publico
  static const String categories = '/marketplace/categories/';
  static const String stores = '/marketplace/stores/';
  static const String products = '/marketplace/products/';

  // Marketplace - autenticado
  static const String vouchers = '/marketplace/vouchers/';
  static const String vouchersPending = '/marketplace/vouchers/pending/';
  static const String vouchersCreateOnline = '/marketplace/vouchers/create-online/';
  static const String vouchersValidate = '/marketplace/vouchers/validate/';
  static const String orders = '/marketplace/orders/';
  static const String purchaseWithRedeem = '/marketplace/purchase/with-redeem/';
  static const String purchaseWithoutRedeem = '/marketplace/purchase/without-redeem/';

  // Marketplace - admin
  static const String adminCategories = '/marketplace/admin/categories/';
  static const String adminStores = '/marketplace/admin/stores/';
  static const String adminProducts = '/marketplace/admin/products/';
  static const String adminStats = '/marketplace/admin/stats/';
}
