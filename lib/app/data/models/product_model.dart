/// Modelo de producto.
///
/// Soporta IDs UUID (string) que vienen del backend Django.
class ProductModel {
  /// UUID del producto en el backend; tambien admite ids numericos como string.
  String id;
  String image;
  String name;
  String description;
  String category;
  String sku;
  int quantity;
  double originalPrice;
  double discountPrice;
  double discountPercent;
  int stock;
  double rating;
  int reviewCount;
  int pointsRequired;
  String storeId;
  String? storeName;

  ProductModel({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
    required this.quantity,
    required this.originalPrice,
    required this.discountPrice,
    required this.storeId,
    this.discountPercent = 0,
    this.stock = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.pointsRequired = 0,
    this.storeName,
  });

  double get price => discountPrice;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['price']);
    final discount = _toDouble(json['discount']);
    final finalPrice =
        json.containsKey('final_price') && json['final_price'] != null
            ? _toDouble(json['final_price'])
            : (discount > 0 ? price * (1 - discount / 100) : price);

    return ProductModel(
      id: json['id']?.toString() ?? '',
      image: (json['image_url'] ?? json['image'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? json['category_name'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse('${json['stock']}') ?? 0,
      quantity: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse('${json['stock']}') ?? 0,
      originalPrice: price,
      discountPrice: finalPrice,
      discountPercent: discount,
      rating: _toDouble(json['rating']),
      reviewCount: json['review_count'] is int
          ? json['review_count'] as int
          : int.tryParse('${json['review_count']}') ?? 0,
      pointsRequired: json['points_required'] is int
          ? json['points_required'] as int
          : int.tryParse('${json['points_required'] ?? json['points_value']}') ?? 0,
      storeId: (json['store_id'] ?? json['store'] ?? '').toString(),
      storeName: json['store_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': image,
        'price': originalPrice,
        'discount': discountPercent,
        'final_price': discountPrice,
        'stock': stock,
        'rating': rating,
        'review_count': reviewCount,
        'store_id': storeId,
        'store_name': storeName,
      };

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
