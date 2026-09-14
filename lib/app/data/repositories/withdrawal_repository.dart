import '../../../utils/api_config.dart';
import '../models/withdrawal_model.dart';
import '../services/http/api_client.dart';

class WithdrawalRepository {
  WithdrawalRepository._();
  static final WithdrawalRepository instance = WithdrawalRepository._();

  final _dio = ApiClient.instance.dio;

  /// GET /wallet/withdrawals/ — historial paginado del usuario autenticado.
  Future<List<WithdrawalModel>> fetchWithdrawals() async {
    try {
      final response = await _dio.get(ApiConfig.withdrawals);
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
          .map((e) => WithdrawalModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// GET /wallet/withdrawals/config/
  /// Devuelve saldo disponible, límites y métodos de pago vinculados.
  Future<WithdrawalConfig> fetchConfig() async {
    try {
      final response = await _dio.get(ApiConfig.withdrawalsConfig);
      if (response.data is Map) {
        return WithdrawalConfig.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      return const WithdrawalConfig();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// POST /wallet/withdrawals/
  /// [payoutMethodId] — UUID del método de cobro seleccionado.
  /// [amount]         — importe a retirar; null → el backend retira todo el saldo.
  /// El backend responde solo `{'message': 'Withdrawal Created'}`, no la
  /// retirada: por eso no devuelve nada y quien llama recarga el historial.
  Future<void> requestWithdrawal({
    required String payoutMethodId,
    double? amount,
  }) async {
    try {
      final data = <String, dynamic>{
        'method': payoutMethodId,
        if (amount != null) 'amount': amount,
      };
      await _dio.post(ApiConfig.withdrawals, data: data);
    } catch (e) {
      throw toApiException(e);
    }
  }
}
