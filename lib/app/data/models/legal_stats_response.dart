class LegalStatsResponse {
  final int totalActive;
  final double dailyAverage;
  final double conversionRate;
  final DateTime? lastAudit;
  final int pendingApproval;
  final int expiredConsents;

  LegalStatsResponse({
    required this.totalActive,
    required this.dailyAverage,
    required this.conversionRate,
    this.lastAudit,
    required this.pendingApproval,
    required this.expiredConsents,
  });

  factory LegalStatsResponse.fromJson(Map<String, dynamic> json) {
    return LegalStatsResponse(
      totalActive: _toInt(json['total_active'] ?? json['total_this_month'] ?? 0),
      dailyAverage: _toDouble(json['daily_average'] ?? json['daily_avg'] ?? 0),
      conversionRate: _toDouble(json['conversion_rate'] ?? 0),
      lastAudit: DateTime.tryParse((json['last_audit'] ?? '').toString()),
      pendingApproval: _toInt(json['pending_approval'] ?? 0),
      expiredConsents: _toInt(json['expired_consents'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_active': totalActive,
    'daily_average': dailyAverage,
    'conversion_rate': conversionRate,
    'last_audit': lastAudit?.toIso8601String(),
    'pending_approval': pendingApproval,
    'expired_consents': expiredConsents,
  };

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static double _toDouble(dynamic v) => v is double ? v : double.tryParse('${v ?? 0}') ?? 0.0;
}
