class ProductModel {
  int id;
  String image;
  String name;
  String description;
  String category;
  String sku;
  int quantity;
  double originalPrice;
  double discountPrice;
  String storeId;

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
  });

  double get price => discountPrice;
}
