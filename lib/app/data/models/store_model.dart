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
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      ownerEmail: json['ownerEmail'],
      adminUserIds: List<String>.from(json['adminUserIds']),
      fiscalId: json['fiscalId'],
      address: json['address'],
      logoUrl: json['logoUrl'],
      billingEmail: json['billingEmail'],
      billingPhone: json['billingPhone'],
      pin: json['pin'],
      createdAt: DateTime.parse(json['createdAt']),
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
      'logoUrl': logoUrl,
      'billingEmail': billingEmail,
      'billingPhone': billingPhone,
      'pin': pin,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}