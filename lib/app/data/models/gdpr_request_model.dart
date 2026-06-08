class GdprRequestModel {
  static const Map<String, String> typeLabels = {
    'erasure':     'Derecho al olvido',
    'portability': 'Portabilidad de Datos',
    'access':      'Acceso a Datos',
    'rectification': 'Rectificación',
    'objection':   'Oposición',
    'restriction': 'Limitación del tratamiento',
  };

  final String id;
  final String userName;
  final String userEmail;
  final String requestType; // erasure | portability | access | rectification | objection | restriction
  final String status;      // received | pending_assign | in_process | resolved | overdue
  final DateTime createdAt;
  final DateTime? deadline;
  final String? assignedTo;
  final String? notes;

  GdprRequestModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.requestType,
    required this.status,
    required this.createdAt,
    this.deadline,
    this.assignedTo,
    this.notes,
  });

  String get typeLabel => typeLabels[requestType] ?? requestType;

  String get statusLabel {
    switch (status) {
      case 'received':       return 'Recibido';
      case 'pending_assign': return 'Pendiente Asignar';
      case 'in_process':     return 'En proceso';
      case 'resolved':       return 'Resuelto';
      case 'overdue':        return 'Fuera de plazo';
      default:               return status;
    }
  }

  /// Días restantes hasta el deadline. Negativo = vencido.
  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue   => daysLeft != null && daysLeft! < 0 || status == 'overdue';
  bool get isResolved  => status == 'resolved';
  bool get isDueToday  => daysLeft == 0;
  bool get isDueSoon3  => daysLeft != null && daysLeft! > 0 && daysLeft! <= 3;

  factory GdprRequestModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'] ?? json['requester'];
    final String userName;
    final String userEmail;
    if (userRaw is Map) {
      userName  = (userRaw['name'] ?? userRaw['full_name'] ?? userRaw['alias'] ?? '').toString();
      userEmail = (userRaw['email'] ?? '').toString();
    } else {
      userName  = (json['user_name'] ?? json['requester_name'] ?? '').toString();
      userEmail = (json['user_email'] ?? json['requester_email'] ?? '').toString();
    }

    return GdprRequestModel(
      id:          (json['id'] ?? '').toString(),
      userName:    userName,
      userEmail:   userEmail,
      requestType: (json['request_type'] ?? json['type'] ?? 'access').toString(),
      status:      (json['status'] ?? 'received').toString(),
      createdAt:   DateTime.tryParse((json['created_at'] ?? json['submitted_at'] ?? '').toString()) ?? DateTime.now(),
      deadline:    DateTime.tryParse((json['deadline'] ?? json['due_date'] ?? '').toString()),
      assignedTo:  json['assigned_to']?.toString(),
      notes:       json['notes']?.toString(),
    );
  }
}

/// Formato RGPD — retornado por GET /admin/gdpr/formats/
class GdprFormat {
  final String id;
  final String name;
  final String article;        // e.g. "Art. 17 RGPD"
  final String description;
  final int deadlineDays;      // plazo legal en días

  const GdprFormat({
    required this.id,
    required this.name,
    required this.article,
    required this.description,
    required this.deadlineDays,
  });

  factory GdprFormat.fromJson(Map<String, dynamic> json) {
    return GdprFormat(
      id:           (json['id'] ?? '').toString(),
      name:         (json['name'] ?? json['title'] ?? '').toString(),
      article:      (json['article'] ?? '').toString(),
      description:  (json['description'] ?? '').toString(),
      deadlineDays: _i(json['deadline_days'] ?? 30),
    );
  }

  static int _i(dynamic v) => v is int ? v : int.tryParse('${v ?? 30}') ?? 30;
}

class GdprStats {
  final int pendingToday;
  final double pendingChangePct;
  final int overdue;
  final int upcoming3Days;
  final int resolvedYear;
  final int total;

  const GdprStats({
    this.pendingToday   = 0,
    this.pendingChangePct = 0,
    this.overdue        = 0,
    this.upcoming3Days  = 0,
    this.resolvedYear   = 0,
    this.total          = 0,
  });

  factory GdprStats.fromJson(Map<String, dynamic> json) {
    return GdprStats(
      pendingToday:    _i(json['pending_today'] ?? json['pending']),
      pendingChangePct: _d(json['pending_change_pct'] ?? json['change_pct']),
      overdue:         _i(json['overdue']),
      upcoming3Days:   _i(json['upcoming_3_days'] ?? json['upcoming']),
      resolvedYear:    _i(json['resolved_year'] ?? json['resolved']),
      total:           _i(json['total']),
    );
  }

  static int    _i(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;
}
