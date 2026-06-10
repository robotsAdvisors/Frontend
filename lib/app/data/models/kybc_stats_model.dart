class KybcStatsModel {
  final double approvalRate;
  final double approvalRateDelta; // e.g. +2.4
  final int pendingCount;
  final int inReviewCount;
  final int approvedCount;
  final int rejectedCount;
  final int suspendedCount;

  const KybcStatsModel({
    this.approvalRate = 0.0,
    this.approvalRateDelta = 0.0,
    this.pendingCount = 0,
    this.inReviewCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
    this.suspendedCount = 0,
  });

  factory KybcStatsModel.fromJson(Map<String, dynamic> json) {
    return KybcStatsModel(
      approvalRate: _toDouble(json['approval_rate'] ?? json['approvalRate'] ?? 0),
      approvalRateDelta: _toDouble(json['approval_rate_delta'] ?? json['delta'] ?? 0),
      pendingCount: _toInt(json['pending_count'] ?? json['pending'] ?? 0),
      inReviewCount: _toInt(json['in_review_count'] ?? json['in_review'] ?? 0),
      approvedCount: _toInt(json['approved_count'] ?? json['approved'] ?? 0),
      rejectedCount: _toInt(json['rejected_count'] ?? json['rejected'] ?? 0),
      suspendedCount: _toInt(json['suspended_count'] ?? json['suspended'] ?? 0),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0.0;
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
}
