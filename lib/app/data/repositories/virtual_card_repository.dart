import '../../../utils/api_config.dart';
import '../models/virtual_card_model.dart';
import '../services/http/api_client.dart';

class VirtualCardRepository {
  VirtualCardRepository._();
  static final VirtualCardRepository instance = VirtualCardRepository._();

  final _dio = ApiClient.instance.dio;

  /// GET /wallet/virtual-card/
  Future<VirtualCardModel> fetchCard() async {
    try {
      final response = await _dio.get(ApiConfig.virtualCard);
      if (response.data is Map) {
        return VirtualCardModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      throw ApiException('Respuesta inválida del servidor.');
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// PATCH /wallet/virtual-card/  { "is_active": bool }
  Future<VirtualCardModel> toggleActive({required bool isActive}) async {
    try {
      final response = await _dio.patch(
        ApiConfig.virtualCard,
        data: {'is_active': isActive},
      );
      if (response.data is Map) {
        return VirtualCardModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      throw ApiException('Respuesta inválida del servidor.');
    } catch (e) {
      throw toApiException(e);
    }
  }
}
