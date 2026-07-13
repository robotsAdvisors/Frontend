class RedemptionCodeCampaignModel {
  final String id;
  final String storeId;
  final String name;
  final DateTime validFrom;
  final DateTime validUntil;
  final double discountPercent;
  final bool isActive;

  RedemptionCodeCampaignModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.validFrom,
    required this.validUntil,
    required this.discountPercent,
    this.isActive = true,
  });
}
