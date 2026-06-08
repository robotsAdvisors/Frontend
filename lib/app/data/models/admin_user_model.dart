class AdminUserModel {
  final String id;            // e.g. "L_UA-000034-A"
  final String firstName;
  final String lastName;
  final String name;          // firstName + lastName combinados
  final String emailMasked;   // "p*****@market.com"
  final String emailFull;
  final String documentType;  // "DNI" | "PASAPORTE"
  final String documentMasked; // "****492-G"
  final bool isActive;
  final bool isSuspended;
  final bool isStaff;
  final String country;
  final String language;
  final DateTime registeredAt;
  final DateTime? lastAccessAt;
  final DateTime? lastPurchaseAt;
  // Compliance
  final int consentPercent;
  final bool kycEnabled;
  final bool authEnabled;
  final bool hasBillingInfo;
  // Marketplace activity
  final int totalPoints;
  final int totalRedemptions;
  final int openDisputes;

  AdminUserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    required this.name,
    required this.emailMasked,
    required this.emailFull,
    this.documentType = 'DNI',
    this.documentMasked = '',
    this.isActive = true,
    this.isSuspended = false,
    this.isStaff = false,
    this.country = '',
    this.language = '',
    required this.registeredAt,
    this.lastAccessAt,
    this.lastPurchaseAt,
    this.consentPercent = 0,
    this.kycEnabled = false,
    this.authEnabled = false,
    this.hasBillingInfo = false,
    this.totalPoints = 0,
    this.totalRedemptions = 0,
    this.openDisputes = 0,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final compliance = json['compliance'] ?? json['cumplimiento'] ?? const {};
    final activity   = json['marketplace_activity'] ?? json['activity'] ?? const {};
    final fn = (json['first_name'] ?? '').toString().trim();
    final ln = (json['last_name']  ?? '').toString().trim();
    final fullName = (json['full_name'] ?? json['name'] ?? '').toString().trim();
    final name = fullName.isNotEmpty ? fullName : [fn, ln].where((s) => s.isNotEmpty).join(' ');

    return AdminUserModel(
      id:             (json['user_id'] ?? json['id'] ?? '').toString(),
      firstName:      fn,
      lastName:       ln,
      name:           name,
      emailMasked:    (json['email_masked'] ?? json['email'] ?? '').toString(),
      emailFull:      (json['email_full'] ?? json['email'] ?? '').toString(),
      documentType:   (json['document_type'] ?? 'DNI').toString(),
      documentMasked: (json['document_masked'] ?? '').toString(),
      isActive:       json['is_active'] as bool? ?? true,
      isSuspended:    json['is_suspended'] as bool? ?? false,
      isStaff:        json['is_staff'] as bool? ?? false,
      country:        (json['country'] ?? '').toString(),
      language:       (json['language'] ?? '').toString(),
      registeredAt:   DateTime.tryParse((json['registered_at'] ?? json['date_joined'] ?? '').toString()) ?? DateTime.now(),
      lastAccessAt:   DateTime.tryParse((json['last_access'] ?? json['last_login'] ?? '').toString()),
      lastPurchaseAt: DateTime.tryParse((json['last_purchase'] ?? '').toString()),
      consentPercent: _toInt(compliance is Map ? (compliance['consent_percent'] ?? json['consent_percent']) : 0),
      kycEnabled:     _toBool(compliance is Map ? (compliance['kyc_enabled'] ?? json['kyc_enabled']) : false),
      authEnabled:    _toBool(compliance is Map ? (compliance['auth_enabled'] ?? json['auth_enabled']) : false),
      hasBillingInfo: _toBool(compliance is Map ? (compliance['has_billing'] ?? json['has_billing']) : false),
      totalPoints:    _toInt(activity is Map ? (activity['total_points'] ?? json['total_points']) : 0),
      totalRedemptions: _toInt(activity is Map ? (activity['total_redemptions'] ?? json['total_redemptions']) : 0),
      openDisputes:   _toInt(activity is Map ? (activity['open_disputes'] ?? json['open_disputes']) : 0),
    );
  }

  static int  _toInt(dynamic v)  => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static bool _toBool(dynamic v) => v is bool ? v : (v?.toString().toLowerCase() == 'true');

  String get statusLabel => isSuspended ? 'Cuenta Suspendida' : (isActive ? 'Cuenta Activa' : 'Inactiva');
}
