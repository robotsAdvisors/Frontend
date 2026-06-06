enum DemandLevel { low, medium, high }

/// Respuesta de GET /parking/spots/{uuid}/
/// Campos exactos según el backend Django (apps/parking/v1/).
class ParkingSpotModel {
  final String id;
  final String name;
  final String address;
  final String? photo;        // URL de la foto (reporte reciente o base del spot)
  final double? price;        // precio/hora — null si no tiene tarifa fija
  final int? waitTime;        // minutos de espera del reporte activo
  final DemandLevel demand;
  final int points;           // puntos que gana el usuario al reportar
  final bool isAvailable;
  final double? lat;
  final double? lng;

  const ParkingSpotModel({
    required this.id,
    required this.name,
    required this.address,
    this.photo,
    this.price,
    this.waitTime,
    this.demand = DemandLevel.low,
    this.points = 50,
    this.isAvailable = true,
    this.lat,
    this.lng,
  });

  factory ParkingSpotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpotModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      photo: json['photo']?.toString(),
      price: _parseDouble(json['price']),
      waitTime: _parseInt(json['wait_time']),
      demand: _parseDemand(json['demand']),
      points: _parseInt(json['points']) ?? 50,
      isAvailable: json['is_available'] as bool? ?? true,
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
    );
  }

  ParkingSpotModel copyWith({
    String? photo,
    int? waitTime,
    DemandLevel? demand,
    bool? isAvailable,
  }) {
    return ParkingSpotModel(
      id: id,
      name: name,
      address: address,
      photo: photo ?? this.photo,
      price: price,
      waitTime: waitTime ?? this.waitTime,
      demand: demand ?? this.demand,
      points: points,
      isAvailable: isAvailable ?? this.isAvailable,
      lat: lat,
      lng: lng,
    );
  }

  static DemandLevel _parseDemand(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'high':
        return DemandLevel.high;
      case 'medium':
        return DemandLevel.medium;
      default:
        return DemandLevel.low;
    }
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}
