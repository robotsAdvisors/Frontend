enum VoucherStatus {
  pending,
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
}
