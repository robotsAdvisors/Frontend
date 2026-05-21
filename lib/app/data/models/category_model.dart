class CategoryModel {
  int id;
  String title;
  String image;
  String? displayName;

  CategoryModel({
    required this.id,
    required this.title,
    required this.image,
    this.displayName,
  });

  /// Map de iconos locales por slug de categoria del backend.
  static const Map<String, String> _localIcons = {
    'fruits': 'assets/vectors/apple.svg',
    'vegetables': 'assets/vectors/broccoli.svg',
    'cheeses': 'assets/vectors/cheese.svg',
    'cheese': 'assets/vectors/cheese.svg',
    'meat': 'assets/vectors/meat.svg',
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final iconRemote = (json['icon'] ?? '').toString();
    final iconLocal =
        _localIcons[name.toLowerCase()] ?? 'assets/vectors/corn.svg';
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['display_name'] ?? json['name'] ?? '').toString(),
      image: iconRemote.isNotEmpty ? iconRemote : iconLocal,
      displayName: json['display_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'display_name': displayName ?? title,
        'icon': image,
      };
}