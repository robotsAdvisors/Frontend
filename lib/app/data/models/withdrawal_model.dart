enum WithdrawalStatus { pending, completed, failed, cancelled }

/// Método de cobro vinculado a la cuenta del usuario.
/// Devuelto dentro de GET /wallet/withdrawals/config/.available_methods
class PayoutMethod {
  final String id;
  final String country;
  final String currency;
  final String accountHolderName;
  final String accountNumber; // enmascarado: "****1234"
  final bool isDefault;

  const PayoutMethod({
    required this.id,
    required this.country,
    required this.currency,
    required this.accountHolderName,
    required this.accountNumber,
    this.isDefault = false,
  });

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(
      id: (json['id'] ?? '').toString(),
      country: (json['country'] ?? '').toString().toUpperCase(),
      currency: (json['currency'] ?? '').toString().toUpperCase(),
      accountHolderName: (json['account_holder_name'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  /// Etiqueta corta para mostrar en la UI: "····1234 · EUR"
  String get shortLabel {
    final last = accountNumber.length > 4
        ? accountNumber.substring(accountNumber.length - 4)
        : accountNumber;
    return '····$last · $currency';
  }
}

/// Un retiro individual, devuelto por GET /wallet/withdrawals/
class WithdrawalModel {
  final String id;
  final double amount;
  final WithdrawalStatus status;
  final String? payoutMethodId;
  final String? destinationLabel; // enmascarado del method, ej. "****1234"
  final DateTime createdAt;
  final DateTime? processedAt;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    this.payoutMethodId,
    this.destinationLabel,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    // El método puede venir embebido como objeto o como UUID plano
    final methodRaw = json['payout_method'] ?? json['method'];
    String? methodId;
    String? destLabel;
    if (methodRaw is Map) {
      methodId = (methodRaw['id'] ?? '').toString();
      destLabel = methodRaw['account_number']?.toString();
    } else if (methodRaw is String) {
      methodId = methodRaw;
    }

    return WithdrawalModel(
      id: (json['id'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      status: _parseStatus(json['status']),
      payoutMethodId: methodId,
      destinationLabel: destLabel ?? json['destination_label']?.toString(),
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
    );
  }

  static WithdrawalStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'completed':
        return WithdrawalStatus.completed;
      case 'failed':
        return WithdrawalStatus.failed;
      case 'cancelled':
        return WithdrawalStatus.cancelled;
      default:
        return WithdrawalStatus.pending;
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

/// Configuración devuelta por GET /wallet/withdrawals/config/
class WithdrawalConfig {
  final double minAmount;
  final double maxAmount;
  /// 0 = sin retiro instantáneo disponible
  final double instantLimit;
  final double availableBalance;
  final bool isVerified;
  final List<PayoutMethod> availableMethods;

  const WithdrawalConfig({
    this.minAmount = 10.0,
    this.maxAmount = 1000.0,
    this.instantLimit = 0.0,
    this.availableBalance = 0.0,
    this.isVerified = false,
    this.availableMethods = const [],
  });

  factory WithdrawalConfig.fromJson(Map<String, dynamic> json) {
    final rawMethods = json['available_methods'];
    final methods = (rawMethods is List)
        ? rawMethods
            .whereType<Map>()
            .map((m) => PayoutMethod.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <PayoutMethod>[];

    return WithdrawalConfig(
      minAmount: _toDouble(json['min_amount']),
      maxAmount: _toDouble(json['max_amount']),
      // instant_limit: 0 es válido (significa sin retiro instantáneo)
      instantLimit: _toDouble(json['instant_limit']),
      availableBalance: _toDouble(json['available_balance']),
      isVerified: json['is_verified'] as bool? ?? false,
      availableMethods: methods,
    );
  }

  bool get hasInstant => instantLimit > 0;

  PayoutMethod? get defaultMethod {
    if (availableMethods.isEmpty) return null;
    return availableMethods.firstWhere(
      (m) => m.isDefault,
      orElse: () => availableMethods.first,
    );
  }

  WithdrawalConfig copyWithBalance(double newBalance) => WithdrawalConfig(
        minAmount: minAmount,
        maxAmount: maxAmount,
        instantLimit: instantLimit,
        availableBalance: newBalance,
        isVerified: isVerified,
        availableMethods: availableMethods,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
