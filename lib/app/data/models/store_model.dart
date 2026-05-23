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
    // Support both Django snake_case and legacy camelCase keys.
    final hours = json['opening_hours'] ?? json['openingHours'] ?? const {};
    final cats = json['categories'] ?? const [];
    final published = json['is_published'] ?? json['isPublished'] ?? true;

    // owner can be a nested object {id, email} or a plain ID.
    final ownerRaw = json['owner'];
    final ownerId = ownerRaw is Map
        ? (ownerRaw['id']?.toString() ?? '')
        : (json['owner_id'] ?? json['ownerId'] ?? ownerRaw ?? '').toString();
    final ownerEmail = ownerRaw is Map
        ? (ownerRaw['email']?.toString() ?? '')
        : (json['owner_email'] ?? json['ownerEmail'] ?? '').toString();

    final adminRaw = json['admin_user_ids'] ?? json['adminUserIds'];

    return StoreModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ownerId: ownerId,
      ownerEmail: ownerEmail.isNotEmpty ? ownerEmail : (json['email'] ?? '').toString(),
      adminUserIds: adminRaw is List
          ? List<String>.from(adminRaw.map((e) => e.toString()))
          : const [],
      fiscalId: (json['fiscal_id'] ?? json['fiscalId'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      logoUrl: (json['logo'] ?? json['logo_url'] ?? '').toString(),
      billingEmail: (json['billing_email'] ?? json['billingEmail'] ?? json['email'] ?? '').toString(),
      billingPhone: (json['phone_number'] ?? json['phoneNumber'] ?? '').toString(),
      pin: (json['pin'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
              DateTime.now(),
      banner: (json['banner'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      openingHours: hours is Map ? Map<String, dynamic>.from(hours) : const {},
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