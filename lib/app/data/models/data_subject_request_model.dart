class DataSubjectRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String rightType; // "access", "erasure", "portability", "rectification", "restrict_processing", "object"
  final String status; // "pending", "in_progress", "completed", "rejected"
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? dueAt; // Vencimiento a los 30 días
  final DateTime? completedAt;
  final String? resultUrl; // URL para descargar el resultado si está disponible

  DataSubjectRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.rightType,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.dueAt,
    this.completedAt,
    this.resultUrl,
  });

  factory DataSubjectRequestModel.fromJson(Map<String, dynamic> json) {
    return DataSubjectRequestModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userName: (json['user_name'] ?? json['userName'] ?? '').toString(),
      userEmail: (json['user_email'] ?? json['userEmail'] ?? json['email'] ?? '').toString(),
      rightType: (json['right_type'] ?? json['rightType'] ?? 'access').toString(),
      status: (json['status'] ?? 'pending').toString(),
      rejectionReason: (json['rejection_reason'] ?? json['rejectionReason'] ?? '').toString().isEmpty
          ? null
          : (json['rejection_reason'] ?? json['rejectionReason'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      dueAt: DateTime.tryParse((json['due_at'] ?? json['dueAt'] ?? '').toString()),
      completedAt: DateTime.tryParse((json['completed_at'] ?? json['completedAt'] ?? '').toString()),
      resultUrl: (json['result_url'] ?? json['resultUrl'] ?? '').toString().isEmpty
          ? null
          : (json['result_url'] ?? json['resultUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'user_email': userEmail,
    'right_type': rightType,
    'status': status,
    'rejection_reason': rejectionReason,
    'created_at': createdAt.toIso8601String(),
    'due_at': dueAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'result_url': resultUrl,
  };
}
