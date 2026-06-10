class AdminUserSubscriptionResponse {
  final String plan;
  final String status;
  final DateTime subscribedAt;
  final DateTime? renewalDate;

  AdminUserSubscriptionResponse({
    required this.plan,
    required this.status,
    required this.subscribedAt,
    this.renewalDate,
  });

  factory AdminUserSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserSubscriptionResponse(
      plan: (json['plan'] ?? json['subscription_plan'] ?? 'Free').toString(),
      status: (json['status'] ?? json['subscription_status'] ?? 'active').toString(),
      subscribedAt: DateTime.tryParse((json['subscribed_at'] ?? json['subscription_start_date'] ?? '').toString()) ?? DateTime.now(),
      renewalDate: DateTime.tryParse((json['renewal_date'] ?? json['subscription_renewal_date'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'plan': plan,
    'status': status,
    'subscribed_at': subscribedAt.toIso8601String(),
    'renewal_date': renewalDate?.toIso8601String(),
  };
}
