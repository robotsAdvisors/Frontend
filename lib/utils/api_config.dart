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
  static const String apiPrefix = '/api/v1';

  /// URL completa base para las peticiones.
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ---- Endpoints ----
  // Auth
  // NOTE: the backend (DRF) defines all `/auth/...` routes WITH a trailing
  // slash, and returns 405/404 without it. The `/users/me...` routes are
  // defined WITHOUT a trailing slash, so those stay as-is.
  static const String authLogin = '/auth/login/';
  static const String authSignup = '/auth/signup/';
  static const String authSocialLogin = '/auth/social-login/';
  static const String authSocialSignup = '/auth/social-signup/';
  static const String authVerifyEmail = '/auth/account-verification/validate/';
  static const String authResetPassword = '/auth/password-reset/';
  static const String authSetPassword = '/auth/set-password/';
  static const String authChangePassword = '/users/me/change-password';
  static const String tokenRefresh = '/auth/token/refresh/';

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
  static const String vouchersValidate  = '/marketplace/vouchers/validate/';
  static const String vouchersPreview   = '/marketplace/vouchers/preview/';
  static String voucherIncident(String id)        => '/marketplace/vouchers/$id/incident/';
  static String voucherInitiatePayment(String code) => '/marketplace/vouchers/$code/initiate-payment/';
  static const String orders      = '/marketplace/orders/';
  static const String storeOrders = '/marketplace/store/orders/';
  static const String purchaseWithRedeem = '/marketplace/purchase/with-redeem/';
  static const String purchaseWithoutRedeem = '/marketplace/purchase/without-redeem/';

  // Marketplace - admin
  static const String adminCategories    = '/marketplace/admin/categories/';
  static const String adminStores        = '/marketplace/admin/stores/';
  static const String adminProducts      = '/marketplace/admin/products/';
  static const String adminStats         = '/marketplace/admin/stats/';
  static const String adminInventoryStats = '/marketplace/admin/inventory/stats/';

  // Marketplace - backoffice dashboard (nuevos endpoints)
  static const String adminDashboardStats = '/marketplace/admin/dashboard/stats/';
  static const String adminAlerts         = '/marketplace/admin/alerts/';
  static const String adminAuditLog       = '/marketplace/admin/audit-log/';
  static const String adminSystemHealth   = '/marketplace/admin/system/health/';
  static const String adminDomainStats    = '/marketplace/admin/domain-stats/';

  // Marketplace - analytics
  static const String analyticsVouchersDaily    = '/marketplace/analytics/vouchers/daily/';
  static const String analyticsSummary          = '/marketplace/analytics/summary/';
  static const String analyticsVouchersByStatus = '/marketplace/analytics/vouchers/by-status/';
  static const String analyticsTopRedeemed      = '/marketplace/analytics/products/top-redeemed/';

  // Marketplace - store detail, activity & management
  static String storeDetail(String id) => '/marketplace/stores/$id/';
  static String storeSettings(String id) => '/marketplace/stores/$id/settings/';
  static String storeActivity(String id) => '/marketplace/stores/$id/activity/';
  static String storeMonthlyGoal(String id)  => '/marketplace/stores/$id/monthly-goal/';
  static String storeBannerUpload(String id) => '/marketplace/stores/$id/upload-banner/';
  static String storeLogoUpload(String id)   => '/marketplace/stores/$id/upload-logo/';

  // Location / Geocoding
  static const String locationReverseGeocode = '/location/reverse-geocode/';
  static const String locationGeocode        = '/location/geocode/';
  static String storeReviews(String id)     => '/marketplace/stores/$id/reviews/';
  static String storeReviewStats(String id) => '/marketplace/stores/$id/reviews/stats/';
  static String reviewDetail(String id)     => '/marketplace/reviews/$id/';
  static String reviewReply(String id)      => '/marketplace/reviews/$id/reply/';
  static String reviewReport(String id)     => '/marketplace/reviews/$id/report/';
  static String reviewHide(String id)       => '/marketplace/reviews/$id/hide/';
  static String storePIN(String id) => '/marketplace/stores/$id/pin/';
  static String storePINRegenerate(String id) => '/marketplace/stores/$id/pin/regenerate/';
  static String storeSecurityLog(String id) => '/marketplace/stores/$id/security-log/';

  // Auth — 2FA & Roles
  static const String twoFactorSetup = '/auth/2fa/setup/';
  static const String twoFactorVerify = '/auth/2fa/verify/';
  static const String twoFactorBackupMethod = '/auth/2fa/backup-method/';
  static const String authRoles = '/auth/roles/';

  // Backoffice — GDPR / RGPD  (/v1/admin/gdpr/...)
  static const String gdprRequests = '/admin/gdpr/requests/';
  static const String gdprStats    = '/admin/gdpr/requests/stats/';
  static const String gdprExport   = '/admin/gdpr/requests/export/';
  static const String gdprFormats  = '/admin/gdpr/formats/';
  static String gdprRequestDetail(String id) => '/admin/gdpr/requests/$id/';

  // Backoffice — Support Tickets
  static const String adminTickets          = '/admin/tickets/';
  static const String adminTicketsCreate    = '/admin/tickets/create/';
  static const String adminTicketCategories = '/admin/ticket-categories/';
  static const String adminAgents           = '/admin/agents/';
  static String adminTicketDetail(String id)   => '/admin/tickets/$id/';
  static String adminTicketMessages(String id) => '/admin/tickets/$id/messages/';
  static String adminTicketEscalate(String id) => '/admin/tickets/$id/escalate/';
  static String adminTicketClose(String id)    => '/admin/tickets/$id/close/';
  static String adminTicketReassign(String id) => '/admin/tickets/$id/reassign/';

  // Backoffice — Admin User Management
  static const String adminUsers = '/admin/users/';
  static String adminUserDetail(String id) => '/admin/users/$id/';
  static String adminUserAuditLog(String id) => '/admin/users/$id/audit-log/';
  static String adminUserSuspend(String id) => '/admin/users/$id/suspend/';
  static String adminUserRevealDoc(String id) => '/admin/users/$id/reveal-document/';
  static String adminUserAudit(String id) => '/admin/users/$id/audit/';
  static String adminUserSubscription(String id) => '/admin/users/$id/subscription/';
  static String adminUserBenefits(String id) => '/admin/users/$id/benefits/';
  static String adminUserTransactions(String id) => '/admin/users/$id/transactions/';
  static String adminUserKyc(String id) => '/admin/users/$id/kyc/';
  static String adminUserDeactivation(String id) => '/admin/users/$id/deactivation/';

  // Backoffice — Admin Store Management
  static String adminStoreDetail(String id) => '/marketplace/admin/stores/$id/';

  // Backoffice — KYBC Compliance
  static const String adminKycStats   = '/admin/kyc/stats/';
  static const String adminKycQueue   = '/admin/kyc/queue/';
  static String adminUserComplianceAction(String id) => '/admin/users/$id/kyc/action/';
  static String adminUserComplianceHistory(String id) => '/admin/users/$id/compliance/history/';

  // Backoffice — Políticas Sensibles
  static const String adminPolicies      = '/admin/policies/';
  static const String adminPoliciesStats = '/admin/policies/stats/';
  static String adminPolicyDetail(String id) => '/admin/policies/$id/';

  // Backoffice — Legal & Consents
  static const String adminLegalConsents = '/admin/legal/consents/';
  static String adminLegalConsentDetail(String id) => '/admin/legal/consents/$id/';
  static const String adminLegalDocuments = '/admin/legal/documents/';
  static const String adminLegalStats = '/admin/legal/stats/';
  static String adminLegalConsentAction(String id) => '/admin/legal/consents/$id/action/';
  // Product image upload
  static const String adminProductUploadImage =
      '/marketplace/admin/products/upload-image/';
  static const String adminProductExport =
      '/marketplace/admin/products/export/';

  // Users: GET list + POST invite share the same URL
  static String storeUsers(String id) => '/marketplace/stores/$id/users/';
  static String storeUserDetail(String storeId, String userId) =>
      '/marketplace/stores/$storeId/users/$userId/';
  static String storeRolesPermissions(String id) => '/marketplace/stores/$id/roles/permissions/';
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

  // Backoffice — Stripe Disputes & Refunds
  static const String adminStripeDisputes      = '/admin/stripe/disputes/';
  static const String adminStripeDisputeStats  = '/admin/stripe/disputes/stats/';
  static String adminStripeDisputeDetail(String id) => '/admin/stripe/disputes/$id/';
  static String adminStripeDisputeAction(String id) => '/admin/stripe/disputes/$id/action/';
  static const String adminStripeRefunds       = '/admin/stripe/refunds/';
}
