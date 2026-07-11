/// Un beneficio de la tarjeta, devuelto embebido en GET /wallet/virtual-card/
class CardBenefit {
  final String id;
  final String key; // "ev_boost" | "marketplace_access" | "cashback" …
  final String title;
  final String description;

  const CardBenefit({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
  });

  factory CardBenefit.fromJson(Map<String, dynamic> json) {
    return CardBenefit(
      id: (json['id'] ?? '').toString(),
      key: (json['key'] ?? json['type'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

/// Tarjeta virtual del usuario.
/// Devuelta por GET /wallet/virtual-card/
class VirtualCardModel {
  final String cardCode;       // "LD-992-550-XP"
  final String cardholderName; // nombre completo del usuario
  final String tier;           // "premium" | "standard" | "basic"
  final int pointsBalance;
  final bool isActive;
  final List<CardBenefit> benefits;

  const VirtualCardModel({
    required this.cardCode,
    required this.cardholderName,
    this.tier = 'standard',
    this.pointsBalance = 0,
    this.isActive = true,
    this.benefits = const [],
  });

  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    final rawBenefits = json['benefits'];
    final benefits = (rawBenefits is List)
        ? rawBenefits
            .whereType<Map>()
            .map((b) => CardBenefit.fromJson(Map<String, dynamic>.from(b)))
            .toList()
        : <CardBenefit>[];

    return VirtualCardModel(
      cardCode: (json['card_code'] ?? json['code'] ?? '').toString(),
      cardholderName:
          (json['cardholder_name'] ?? json['full_name'] ?? '').toString(),
      tier: (json['tier'] ?? 'standard').toString().toLowerCase(),
      pointsBalance: _parseInt(json['points_balance'] ?? json['points']) ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      benefits: benefits,
    );
  }

  /// Etiqueta de nivel para mostrar en la tarjeta.
  String get tierLabel {
    switch (tier) {
      case 'premium':
        return 'PREMIUM MEMBER';
      case 'basic':
        return 'BASIC MEMBER';
      default:
        return 'STANDARD MEMBER';
    }
  }

  VirtualCardModel copyWith({bool? isActive}) => VirtualCardModel(
        cardCode: cardCode,
        cardholderName: cardholderName,
        tier: tier,
        pointsBalance: pointsBalance,
        isActive: isActive ?? this.isActive,
        benefits: benefits,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}
