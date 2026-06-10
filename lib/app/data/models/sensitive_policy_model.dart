class SensitivePolicyModel {
  final String id;
  final String name;
  final String plazo;       // e.g. "30 dias"
  final int plazoInDays;
  final String ruta;        // "Informe" | "Backoffice" | "Usuario" | "Global"
  final String status;      // "active" | "pending" | "inactive"
  final String category;    // "retencion" | "gdpr" | "geolocalizacion" | "auditoria"
  final String description;
  final DateTime? updatedAt;
  final bool isEditable;

  const SensitivePolicyModel({
    required this.id,
    required this.name,
    this.plazo = '',
    this.plazoInDays = 0,
    this.ruta = '',
    this.status = 'active',
    this.category = '',
    this.description = '',
    this.updatedAt,
    this.isEditable = true,
  });

  factory SensitivePolicyModel.fromJson(Map<String, dynamic> json) {
    final days = _toInt(
        json['plazo_days'] ?? json['retention_days'] ?? json['plazoInDays'] ?? 0);
    final plazoStr = (json['plazo'] ?? json['retention_period'] ??
            (days > 0 ? '$days dias' : ''))
        .toString();
    return SensitivePolicyModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nombre'] ?? '').toString(),
      plazo: plazoStr,
      plazoInDays: days,
      ruta: (json['ruta'] ?? json['route'] ?? json['scope'] ?? '').toString(),
      status: (json['status'] ?? json['estado'] ?? 'active').toString(),
      category: (json['category'] ?? json['categoria'] ?? '').toString(),
      description: (json['description'] ?? json['descripcion'] ?? '').toString(),
      updatedAt: DateTime.tryParse(
          (json['updated_at'] ?? json['updatedAt'] ?? '').toString()),
      isEditable: json['is_editable'] as bool? ?? json['isEditable'] as bool? ?? true,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse('${v ?? 0}') ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plazo': plazo,
        'retention_days': plazoInDays,
        'ruta': ruta,
        'status': status,
        'category': category,
        'description': description,
      };
}
