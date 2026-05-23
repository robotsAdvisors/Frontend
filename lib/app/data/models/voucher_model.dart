enum VoucherStatus {
  pending,
  paid,
  redeemed,
  expired,
  cancelled,
}

class VoucherModel {
  final String id;
  final String campaignId;
  final String storeId;
  final String customerUserId;
  final String productId;
  final String code;
  final DateTime issuedAt;
  final DateTime? redeemedAt;
  final DateTime? expiresAt;
  final double discountPercent;
  final VoucherStatus status;
  final int pointsUsed;
  final String redeemType; // 'ONLINE' | 'IN_STORE'
  final String? qrCode;
  final String? productName;
  final String? storeName;
  final String? customerName;
  final String? customerEmail;

  VoucherModel({
    required this.id,
    required this.campaignId,
    required this.storeId,
    required this.customerUserId,
    required this.productId,
    required this.code,
    required this.issuedAt,
    this.redeemedAt,
    this.expiresAt,
    this.discountPercent = 0,
    this.status = VoucherStatus.pending,
    this.pointsUsed = 0,
    this.redeemType = 'ONLINE',
    this.qrCode,
    this.productName,
    this.storeName,
    this.customerName,
    this.customerEmail,
  });

  // Compatibility alias for old UI fields.
  DateTime get createdAt => issuedAt;

  bool get isRedeemed => status == VoucherStatus.redeemed;

  bool get isExpired {
    if (status == VoucherStatus.expired) {
      return true;
    }
    return expiresAt != null && expiresAt!.isBefore(DateTime.now());
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final store = json['store'];
    final product = json['product'];
    final customerId = user is Map
        ? (user['id']?.toString() ?? '')
        : (user?.toString() ?? '');
    final storeId = store is Map
        ? (store['id']?.toString() ?? '')
        : (store?.toString() ?? '');
    final productId = product is Map
        ? (product['id']?.toString() ?? '')
        : (product?.toString() ?? '');

    return VoucherModel(
      id: json['id']?.toString() ?? '',
      campaignId: (json['campaign_id'] ?? '').toString(),
      storeId: storeId,
      customerUserId: customerId,
      productId: productId,
      code: (json['code'] ?? '').toString(),
      issuedAt:
          _parseDate(json['issued_at'] ?? json['created_at']) ?? DateTime.now(),
      redeemedAt: _parseDate(json['redeemed_at']),
      expiresAt: _parseDate(json['expires_at']),
      discountPercent:
          _toDouble(json['discount_percentage'] ?? json['discount_percent']),
      status: _parseStatus(json['status']),
      pointsUsed: json['points_used'] is int
          ? json['points_used'] as int
          : int.tryParse('${json['points_used']}') ?? 0,
      redeemType: (json['redeem_type'] ?? 'ONLINE').toString(),
      qrCode: json['qr_code']?.toString(),
      productName: product is Map ? product['name']?.toString() : null,
      storeName: store is Map ? store['name']?.toString() : null,
      customerName: user is Map
          ? (user['name'] ?? user['username'] ?? user['email'] ?? '').toString()
          : null,
      customerEmail: user is Map ? user['email']?.toString() : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static VoucherStatus _parseStatus(dynamic v) {
    switch ((v ?? '').toString().toUpperCase()) {
      case 'PAID':
        return VoucherStatus.paid;
      case 'REDEEMED':
        return VoucherStatus.redeemed;
      case 'EXPIRED':
        return VoucherStatus.expired;
      case 'CANCELLED':
        return VoucherStatus.cancelled;
      case 'PENDING':
      default:
        return VoucherStatus.pending;
    }
  }
}
