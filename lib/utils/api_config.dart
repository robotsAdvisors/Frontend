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
    defaultValue: 'https://api.letdem.net',
  );

  /// Prefijo de la API REST.
  static const String apiPrefix = '/v1';

  /// URL completa base para las peticiones.
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ---- Endpoints ----
  // Auth
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';
  static const String authSocialLogin = '/auth/social-login';
  static const String authResetPassword = '/auth/reset-password';
  static const String authSetPassword = '/auth/set-password';
  static const String authChangePassword = '/v1/users/me/change-password';
  static const String tokenRefresh = '/auth/token/refresh';

  // Profile
  static const String me = '/users/me';
  static const String mePreferences = '/v1/users/me/preferences';

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

  // Marketplace - analytics
  static const String analyticsVouchersDaily = '/marketplace/analytics/vouchers/daily/';
  static const String analyticsSummary = '/marketplace/analytics/summary/';

  // Marketplace - store detail, activity & management
  static String storeDetail(String id) => '/marketplace/stores/$id/';
  static String storeActivity(String id) => '/marketplace/stores/$id/activity/';
  // Product image upload
  static const String adminProductUploadImage =
      '/marketplace/admin/products/upload-image/';
  static const String adminProductExport =
      '/marketplace/admin/products/export/';

  // Users: GET list + POST invite share the same URL
  static String storeUsers(String id) => '/marketplace/stores/$id/users/';
  static String storeUserDetail(String storeId, String userId) =>
      '/marketplace/stores/$storeId/users/$userId/';
  static String storeChangePIN(String id) => '/marketplace/stores/$id/change-pin/';
  static String storeSecurity(String id) => '/marketplace/stores/$id/security/';

  // Parking
  static const String parkingSpots = '/parking/spots/';
  static String parkingSpotDetail(String id) => '/parking/spots/$id/';
  static String parkingSpotReport(String id) => '/parking/spots/$id/report/';

  // Withdrawals
  static const String withdrawals = '/wallet/withdrawals/';
  static const String withdrawalsConfig = '/wallet/withdrawals/config/';

  // Bookings
  static const String bookings = '/parking/bookings/';
  static String bookingDetail(String id) => '/parking/bookings/$id/';
  static String bookingCancel(String id) => '/parking/bookings/$id/cancel/';

  // Virtual Card
  static const String virtualCard = '/wallet/virtual-card/';
}
