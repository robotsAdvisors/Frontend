class AdminUserTransactionResponse {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String paymentMethod;
  final String status;

  AdminUserTransactionResponse({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });

  factory AdminUserTransactionResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserTransactionResponse(
      id: (json['id'] ?? json['transaction_id'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? json['created_at'] ?? '').toString()) ?? DateTime.now(),
      description: (json['description'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      paymentMethod: (json['payment_method'] ?? json['method'] ?? '').toString(),
      status: (json['status'] ?? 'completed').toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount,
    'payment_method': paymentMethod,
    'status': status,
  };
}
