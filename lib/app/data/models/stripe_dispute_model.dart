class StripeDisputeModel {
  final String id;
  final String stripeId;
  final String type;       // "dispute" | "refund"
  final double amount;
  final String currency;
  final String fase;       // "backoffice" | "stripe" | "completed" | "needs_response" | "under_review" | "won" | "lost"
  final String status;     // "open" | "completed" | "won" | "lost" | "charge_refunded" | "needs_response" | "under_review"
  final String reason;
  final String userName;
  final String userEmail;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const StripeDisputeModel({
    required this.id,
    this.stripeId = '',
    this.type = 'dispute',
    required this.amount,
    this.currency = 'eur',
    this.fase = '',
    this.status = 'open',
    this.reason = '',
    this.userName = '',
    this.userEmail = '',
    required this.createdAt,
    this.resolvedAt,
  });

  factory StripeDisputeModel.fromJson(Map<String, dynamic> json) {
    return StripeDisputeModel(
      id: (json['id'] ?? '').toString(),
      stripeId: (json['stripe_id'] ?? json['stripeId'] ?? '').toString(),
      type: (json['type'] ?? 'dispute').toString(),
      amount: _toDouble(json['amount'] ?? json['amount_eur'] ?? 0),
      currency: (json['currency'] ?? 'eur').toString().toLowerCase(),
      fase: (json['fase'] ?? json['phase'] ?? json['stage'] ?? '').toString(),
      status: (json['status'] ?? 'open').toString(),
      reason: (json['reason'] ?? '').toString(),
      userName: (json['user_name'] ?? json['user_full_name'] ?? json['userName'] ?? '').toString(),
      userEmail: (json['user_email'] ?? json['userEmail'] ?? '').toString(),
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      resolvedAt: DateTime.tryParse(
          (json['resolved_at'] ?? json['resolvedAt'] ?? '').toString()),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stripe_id': stripeId,
        'type': type,
        'amount': amount,
        'currency': currency,
        'fase': fase,
        'status': status,
        'reason': reason,
        'user_name': userName,
        'user_email': userEmail,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}

class StripeDisputeStats {
  final int totalDisputes;
  final int completed;
  final double successRate;

  const StripeDisputeStats({
    required this.totalDisputes,
    required this.completed,
    required this.successRate,
  });

  factory StripeDisputeStats.fromJson(Map<String, dynamic> json) {
    return StripeDisputeStats(
      totalDisputes: _toInt(json['total_disputes'] ?? json['total'] ?? 0),
      completed: _toInt(json['completed'] ?? json['resolved'] ?? 0),
      successRate: _toDouble(json['success_rate'] ?? json['successRate'] ?? 0),
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static double _toDouble(dynamic v) =>
      v is double ? v : double.tryParse('${v ?? 0}') ?? 0.0;
}
