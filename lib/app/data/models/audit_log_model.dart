class AuditLogModel {
  final String id;
  final DateTime timestamp;
  final String action;     // "Revelación de DNI", "Reactivación de cuenta"
  final String adminUser;  // "admin_support_01"
  final String reason;     // motivo/detalle
  final String status;     // "pending" | "done" | "reviewed"

  AuditLogModel({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.adminUser,
    required this.reason,
    this.status = 'done',
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id:        (json['id'] ?? '').toString(),
      timestamp: DateTime.tryParse((json['timestamp'] ?? json['created_at'] ?? '').toString()) ?? DateTime.now(),
      action:    (json['action'] ?? json['action_label'] ?? '').toString(),
      adminUser: (json['admin_user'] ?? json['performed_by'] ?? 'system').toString(),
      reason:    (json['reason'] ?? json['detail'] ?? json['description'] ?? '').toString(),
      status:    (json['status'] ?? 'done').toString(),
    );
  }
}
