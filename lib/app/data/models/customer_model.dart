class CustomerModel {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    required this.createdAt,
  });
}
