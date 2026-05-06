class StoreUserModel {
  final String id;
  final String email;
  final String role; // store_admin
  final String storeId;
  final DateTime createdAt;

  StoreUserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.storeId,
    required this.createdAt,
  });

  factory StoreUserModel.fromJson(Map<String, dynamic> json) {
    return StoreUserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      storeId: json['storeId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'storeId': storeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}