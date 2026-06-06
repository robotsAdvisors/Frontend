/// Estados internos del backend → agrupados en 4 estados de UI.
/// RESERVED/CONFIRMED → active · PENDING → upcoming
/// EXPIRED → completed · CANCELLED → cancelled
enum BookingStatus { active, upcoming, completed, cancelled }

/// Una reserva de plaza de aparcamiento.
/// Devuelta por GET /parking/bookings/ y GET /parking/bookings/{uuid}/
class BookingModel {
  final String id;
  final String spotId;
  final String address;
  final String spotName;

  /// Valor raw del backend: "paid", "free", "private", etc.
  /// Usar [spotTypeLabel] para mostrar en UI.
  final String? spotType;

  final double? pricePerHour;
  final BookingStatus status;
  final DateTime startAt;
  final DateTime endAt;
  final double totalCost;

  const BookingModel({
    required this.id,
    required this.spotId,
    required this.address,
    required this.spotName,
    this.spotType,
    this.pricePerHour,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.totalCost,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // El spot viene embebido como objeto; puede venir también como UUID plano
    final spotRaw = json['spot'] ?? json['parking_spot'];
    String spotId = '';
    String address = '';
    String spotName = '';
    String? spotType;
    double? pricePerHour;

    if (spotRaw is Map) {
      spotId = (spotRaw['id'] ?? '').toString();
      address = (spotRaw['address'] ?? '').toString();
      spotName = (spotRaw['name'] ?? '').toString();
      pricePerHour = _toDouble(spotRaw['price']);
      // spot_type es un string plano: "paid", "free", "private"…
      final t = spotRaw['spot_type'] ?? spotRaw['type'];
      spotType = t?.toString();
    } else if (spotRaw is String) {
      spotId = spotRaw;
    }

    // Fallbacks: campos planos al nivel de la reserva
    if (address.isEmpty) address = (json['address'] ?? '').toString();
    if (spotName.isEmpty) spotName = (json['spot_name'] ?? '').toString();
    spotType ??= (json['spot_type'] ?? json['type'])?.toString();
    pricePerHour ??= _toDouble(json['price_per_hour']);

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      spotId: spotId,
      address: address,
      spotName: spotName,
      spotType: (spotType?.isEmpty ?? true) ? null : spotType,
      pricePerHour: pricePerHour,
      status: _parseStatus(json['status']),
      startAt: DateTime.tryParse(
              (json['start_at'] ?? json['start_datetime'] ?? '').toString()) ??
          DateTime.now(),
      endAt: DateTime.tryParse(
              (json['end_at'] ?? json['end_datetime'] ?? '').toString()) ??
          DateTime.now(),
      totalCost: _toDouble(json['total_cost'] ?? json['total']) ?? 0.0,
    );
  }

  /// Etiqueta en español para mostrar en UI.
  String get spotTypeLabel {
    switch (spotType?.toLowerCase()) {
      case 'paid':
        return 'Plaza de pago';
      case 'free':
        return 'Plaza gratuita';
      case 'private':
        return 'Garaje privado';
      case 'underground':
        return 'Plaza subterránea';
      case 'residential':
        return 'Zona residencial';
      case 'mall':
        return 'Centro comercial';
      case 'park_and_ride':
        return 'Park & Ride';
      default:
        return spotType ?? '';
    }
  }

  /// Backend usa estados en MAYÚSCULAS.
  /// RESERVED/CONFIRMED → active · PENDING → upcoming
  /// EXPIRED → completed · CANCELLED → cancelled
  static BookingStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toUpperCase()) {
      case 'RESERVED':
      case 'CONFIRMED':
        return BookingStatus.active;
      case 'PENDING':
        return BookingStatus.upcoming;
      case 'EXPIRED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
