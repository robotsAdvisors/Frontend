class LegalConsentModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String documentType; // "Terms of Service", "Privacy Policy", etc.
  final String documentName;
  final String version;
  final String status; // "accepted", "pending", "rejected", "expired"
  final DateTime acceptedAt;
  final DateTime? expiresAt;
  final String ipAddress;
  final String userAgent;
  final String? rejectionReason;

  LegalConsentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.documentType,
    required this.documentName,
    required this.version,
    required this.status,
    required this.acceptedAt,
    this.expiresAt,
    required this.ipAddress,
    required this.userAgent,
    this.rejectionReason,
  });

  factory LegalConsentModel.fromJson(Map<String, dynamic> json) {
    return LegalConsentModel(
      id: (json['id'] ?? json['consent_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userName: (json['user_full_name'] ?? json['user_name'] ?? json['userName'] ?? '').toString(),
      userEmail: (json['user_email'] ?? json['userEmail'] ?? json['email'] ?? '').toString(),
      documentType: (json['document_type'] ?? json['documentType'] ?? 'Terms of Service').toString(),
      documentName: (json['document_name'] ?? json['documentName'] ?? '').toString(),
      version: (json['version'] ?? '1.0').toString(),
      status: (json['status'] ?? 'pending').toString(),
      acceptedAt: DateTime.tryParse((json['accepted_at'] ?? json['acceptedAt'] ?? '').toString()) ?? DateTime.now(),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? json['expiresAt'] ?? '').toString()),
      ipAddress: (json['ip_address'] ?? json['ipAddress'] ?? '').toString(),
      userAgent: (json['user_agent'] ?? json['userAgent'] ?? '').toString(),
      rejectionReason: (json['rejection_reason'] ?? json['rejectionReason'] ?? '').toString().isEmpty
          ? null
          : (json['rejection_reason'] ?? json['rejectionReason'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'user_email': userEmail,
    'document_type': documentType,
    'document_name': documentName,
    'version': version,
    'status': status,
    'accepted_at': acceptedAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'ip_address': ipAddress,
    'user_agent': userAgent,
    'rejection_reason': rejectionReason,
  };
}
