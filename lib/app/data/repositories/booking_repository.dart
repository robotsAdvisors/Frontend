import '../../../utils/api_config.dart';
import '../models/booking_model.dart';
import '../services/http/api_client.dart';

class BookingRepository {
  BookingRepository._();
  static final BookingRepository instance = BookingRepository._();

  final _dio = ApiClient.instance.dio;

  /// GET /parking/bookings/
  /// [status] — filtro opcional: 'active', 'upcoming', 'completed', 'cancelled'.
  /// Si es null se devuelven todas.
  Future<List<BookingModel>> fetchBookings({String? status}) async {
    try {
      final response = await _dio.get(
        ApiConfig.bookings,
        queryParameters: status != null ? {'status': status} : null,
      );
      final raw = response.data;
      final list = raw is List
          ? raw
          : (raw is Map && raw['results'] is List)
              ? raw['results'] as List
              : (raw is Map && raw['data'] is List)
                  ? raw['data'] as List
                  : <dynamic>[];
      return list
          .whereType<Map>()
          .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// GET /parking/bookings/{id}/
  Future<BookingModel> fetchBooking(String id) async {
    try {
      final response = await _dio.get(ApiConfig.bookingDetail(id));
      if (response.data is Map) {
        return BookingModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      throw ApiException('Respuesta inválida del servidor.');
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// DELETE /parking/bookings/{id}/cancel/
  Future<void> cancelBooking(String id) async {
    try {
      await _dio.post(ApiConfig.bookingCancel(id));
    } catch (e) {
      throw toApiException(e);
    }
  }
}
