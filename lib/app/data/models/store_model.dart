class StoreModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String ownerEmail;
  final List<String> adminUserIds;
  final String fiscalId;
  final String address;
  final String logoUrl;
  final String billingEmail;
  final String billingPhone;
  final String pin;
  final DateTime createdAt;
  // Nuevos campos del backend
  final String banner;
  final String email;
  final String website;
  final Map<String, dynamic> openingHours;
  final bool isPublished;
  final List<String> categories;

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerEmail,
    required this.adminUserIds,
    required this.fiscalId,
    required this.address,
    required this.logoUrl,
    required this.billingEmail,
    required this.billingPhone,
    required this.pin,
    required this.createdAt,
    this.banner = '',
    this.email = '',
    this.website = '',
    this.openingHours = const {},
    this.isPublished = true,
    this.categories = const [],
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final hours = json['openingHours'] ?? const {};
    final cats = json['categories'] ?? const [];
    final published = json['isPublished'] ?? true;

    return StoreModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      ownerEmail: (json['ownerEmail'] ?? json['email'] ?? '').toString(),
      adminUserIds: List<String>.from(
        (json['adminUserIds'] as List?) ?? const [],
      ),
      fiscalId: (json['fiscalId'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      logoUrl: (json['logo'] ?? '').toString(),
      billingEmail: (json['billingEmail'] ?? json['email'] ?? '').toString(),
      billingPhone: (json['phoneNumber'] ?? '').toString(),
      pin: (json['pin'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
              DateTime.now(),
      banner: (json['banner'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      openingHours: hours is Map
          ? Map<String, dynamic>.from(hours)
          : const {},
      isPublished: published is bool
          ? published
          : published.toString().toLowerCase() == 'true',
      categories: cats is List
          ? List<String>.from(cats.map((e) => e.toString()))
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'adminUserIds': adminUserIds,
      'fiscalId': fiscalId,
      'address': address,
      'logo': logoUrl,
      'billingEmail': billingEmail,
      'phoneNumber': billingPhone,
      'pin': pin,
      'createdAt': createdAt.toIso8601String(),
      'banner': banner,
      'email': email,
      'website': website,
      'openingHours': openingHours,
      'isPublished': isPublished,
      'categories': categories,
    };
  }
}