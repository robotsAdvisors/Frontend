class AdminUserBenefitsResponse {
  final String badge;
  final String tier;
  final int totalPoints;
  final List<String> benefits;
  final List<Map<String, dynamic>> recentContributions;

  AdminUserBenefitsResponse({
    required this.badge,
    required this.tier,
    required this.totalPoints,
    required this.benefits,
    required this.recentContributions,
  });

  factory AdminUserBenefitsResponse.fromJson(Map<String, dynamic> json) {
    final benefitsRaw = json['benefits'] ?? [];
    final benefits = (benefitsRaw is List)
        ? benefitsRaw.whereType<String>().toList()
        : [benefitsRaw.toString()];

    final contribRaw = json['recent_contributions'] ?? [];
    final contributions = (contribRaw is List)
        ? contribRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    return AdminUserBenefitsResponse(
      badge: (json['badge'] ?? '').toString(),
      tier: (json['tier'] ?? 'Free').toString(),
      totalPoints: _toInt(json['total_points']),
      benefits: benefits,
      recentContributions: contributions,
    );
  }

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

  Map<String, dynamic> toJson() => {
    'badge': badge,
    'tier': tier,
    'total_points': totalPoints,
    'benefits': benefits,
    'recent_contributions': recentContributions,
  };
}
