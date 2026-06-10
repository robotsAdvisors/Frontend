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
  // Subscription & Benefits
  final String subscriptionPlan;
  final String subscriptionStatus;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionRenewalDate;
  final List<String> benefits;
  // Transactions
  final List<Map<String, dynamic>> transactions;
  // KYC & Deactivation
  final String kycStatus;
  final DateTime? kycSubmittedAt;
  final DateTime? kycApprovedAt;
  final String? kycRejectionReason;
  final String? deactivationStatus;
  final DateTime? deactivationDate;

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
    this.subscriptionPlan = 'Free',
    this.subscriptionStatus = 'active',
    this.subscriptionStartDate,
    this.subscriptionRenewalDate,
    this.benefits = const [],
    this.transactions = const [],
    this.kycStatus = 'pending',
    this.kycSubmittedAt,
    this.kycApprovedAt,
    this.kycRejectionReason,
    this.deactivationStatus,
    this.deactivationDate,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final compliance = json['compliance'] ?? json['cumplimiento'] ?? const {};
    final activity   = json['marketplace_activity'] ?? json['activity'] ?? const {};
    final subscription = json['subscription'] ?? const {};
    final benefits = json['benefits'] ?? const {};
    final kyc = json['kyc'] ?? const {};

    final fn = (json['first_name'] ?? '').toString().trim();
    final ln = (json['last_name']  ?? '').toString().trim();
    final fullName = (json['full_name'] ?? json['name'] ?? '').toString().trim();
    final name = fullName.isNotEmpty ? fullName : [fn, ln].where((s) => s.isNotEmpty).join(' ');

    // Parse benefits
    final benefitsRaw = benefits is Map ? benefits['benefits'] ?? [] : [];
    final benefitsList = (benefitsRaw is List)
        ? benefitsRaw.whereType<String>().toList()
        : <String>[];

    // Parse transactions
    final transactionsRaw = json['transactions'] ?? [];
    final transactionsList = (transactionsRaw is List)
        ? transactionsRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

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
      subscriptionPlan: (subscription is Map ? (subscription['plan'] ?? 'Free') : 'Free').toString(),
      subscriptionStatus: (subscription is Map ? (subscription['status'] ?? 'active') : 'active').toString(),
      subscriptionStartDate: subscription is Map
          ? DateTime.tryParse((subscription['subscribed_at'] ?? '').toString())
          : null,
      subscriptionRenewalDate: subscription is Map
          ? DateTime.tryParse((subscription['renewal_date'] ?? '').toString())
          : null,
      benefits: benefitsList,
      transactions: transactionsList,
      kycStatus: (kyc is Map ? (kyc['status'] ?? 'pending') : 'pending').toString(),
      kycSubmittedAt: kyc is Map ? DateTime.tryParse((kyc['submitted_at'] ?? '').toString()) : null,
      kycApprovedAt: kyc is Map ? DateTime.tryParse((kyc['approved_at'] ?? '').toString()) : null,
      kycRejectionReason: kyc is Map ? (kyc['rejection_reason'] ?? '').toString() : null,
      deactivationStatus: (json['deactivation_status'] ?? '').toString().isEmpty
          ? null
          : (json['deactivation_status'] ?? '').toString(),
      deactivationDate: DateTime.tryParse((json['deactivation_date'] ?? '').toString()),
    );
  }

  static int  _toInt(dynamic v)  => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static bool _toBool(dynamic v) => v is bool ? v : (v?.toString().toLowerCase() == 'true');

  String get statusLabel => isSuspended ? 'Cuenta Suspendida' : (isActive ? 'Cuenta Activa' : 'Inactiva');
}
