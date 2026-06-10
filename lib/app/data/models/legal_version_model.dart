class LegalVersionModel {
  final String id;
  final String documentType;
  final String documentName;
  final String title;
  final String summary;
  final String articleNumber;
  final String description;
  final String currentVersion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int daysToDeadline;

  LegalVersionModel({
    required this.id,
    required this.documentType,
    required this.documentName,
    required this.title,
    required this.summary,
    required this.articleNumber,
    required this.description,
    required this.currentVersion,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
    required this.daysToDeadline,
  });

  factory LegalVersionModel.fromJson(Map<String, dynamic> json) {
    return LegalVersionModel(
      id: (json['id'] ?? '').toString(),
      documentType: (json['document_type'] ?? '').toString(),
      documentName: (json['document_name'] ?? json['title'] ?? '').toString(),
      title: (json['title'] ?? json['document_name'] ?? '').toString(),
      summary: (json['summary'] ?? json['description'] ?? '').toString(),
      articleNumber: (json['article_number'] ?? '').toString(),
      description: (json['description'] ?? json['summary'] ?? '').toString(),
      currentVersion: (json['version'] ?? json['current_version'] ?? '1.0').toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      publishedAt: DateTime.tryParse((json['published_at'] ?? '').toString()),
      daysToDeadline: _toInt(json['days_to_deadline'] ?? 30),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'document_type': documentType,
    'document_name': documentName,
    'title': title,
    'summary': summary,
    'article_number': articleNumber,
    'description': description,
    'version': currentVersion,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'published_at': publishedAt?.toIso8601String(),
    'days_to_deadline': daysToDeadline,
  };

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
}
