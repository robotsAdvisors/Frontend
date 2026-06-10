/// Modelo de producto / premio del marketplace Letdem.
class ProductModel {
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
  DateTime? expiryDate;
  bool isPublished;    // false → "Pausado"
  bool isRedeemable;   // toggle "¿Canjeable?"
  double monetaryPrice; // precio vía Stripe (€), 0 si no aplica
  String type;         // "beneficio" | "descuento" | "carta"
  int salesCount;      // ventas totales (anotado por el backend)

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
    this.expiryDate,
    this.isPublished = true,
    this.isRedeemable = true,
    this.monetaryPrice = 0,
    this.type = 'descuento',
    this.salesCount = 0,
  });

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final days30 = DateTime.now().add(const Duration(days: 30));
    return !isExpired && expiryDate!.isBefore(days30);
  }

  double get price => discountPrice;

  /// Estado derivado para mostrar en tablas de la UI.
  String get statusLabel {
    if (quantity == 0) return 'Sin Stock';
    if (!isPublished) return 'Pausado';
    return 'Activo';
  }

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
          : int.tryParse(
                  '${json['points_required'] ?? json['points_value']}') ??
              0,
      storeId: (json['store_id'] ?? json['store'] ?? '').toString(),
      storeName: json['store_name']?.toString(),
      expiryDate: _parseDate(json['expiry_date'] ?? json['expires_at']),
      isPublished: json['is_published'] as bool? ?? true,
      isRedeemable: json['is_redeemable'] as bool? ?? true,
      monetaryPrice: _toDouble(json['monetary_price'] ?? json['stripe_price']),
      type: (json['type'] ?? 'descuento').toString(),
      salesCount: json['sales_count'] is int
          ? json['sales_count'] as int
          : int.tryParse('${json['sales_count'] ?? 0}') ?? 0,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
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
        'is_published': isPublished,
        'is_redeemable': isRedeemable,
        'monetary_price': monetaryPrice,
        'type': type,
        if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
      };

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
