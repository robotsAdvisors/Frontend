class AdminUserKycResponse {
  final String status;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final Map<String, dynamic> metadata;

  AdminUserKycResponse({
    required this.status,
    this.submittedAt,
    this.approvedAt,
    this.rejectionReason,
    this.metadata = const {},
  });

  factory AdminUserKycResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserKycResponse(
      status: (json['status'] ?? json['kyc_status'] ?? 'pending').toString(),
      submittedAt: DateTime.tryParse((json['submitted_at'] ?? '').toString()),
      approvedAt: DateTime.tryParse((json['approved_at'] ?? '').toString()),
      rejectionReason: (json['rejection_reason'] ?? '').toString().isEmpty
          ? null
          : (json['rejection_reason'] ?? '').toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'submitted_at': submittedAt?.toIso8601String(),
    'approved_at': approvedAt?.toIso8601String(),
    'rejection_reason': rejectionReason,
    'metadata': metadata,
  };
}
