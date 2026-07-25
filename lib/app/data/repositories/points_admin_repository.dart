import 'package:dio/dio.dart';

import '../../../utils/api_config.dart';
import '../models/points_admin_models.dart';
import '../services/http/api_client.dart';

/// Página DRF `{count, next, previous, results}`.
class DrfPage<T> {
  final List<T> items;
  final int count;
  final bool hasMore;
  const DrfPage({this.items = const [], this.count = 0, this.hasMore = false});
}

/// Repositorio del Módulo A (SPEC): puntos del cliente para el Super Admin.
/// El superadmin busca al cliente por email y consulta/ajusta sus puntos.
class PointsAdminRepository {
  PointsAdminRepository._();
  static final PointsAdminRepository instance = PointsAdminRepository._();

  final _dio = ApiClient.instance.dio;

  // ---------- BUSCADOR DE CLIENTES ----------

  /// GET /admin/customers/?search=<email> — solo clientes de la app.
  /// `search` < 2 chars devuelve vacío sin llamar (el backend también lo hace).
  Future<DrfPage<CustomerListItem>> searchCustomers(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (query.trim().length < 2) {
      return const DrfPage<CustomerListItem>();
    }
    try {
      final response = await _dio.get(
        ApiConfig.adminCustomers,
        queryParameters: {
          'search': query.trim(),
          'page': page,
          'page_size': pageSize,
        },
      );
      return _parsePage(response.data, CustomerListItem.fromJson);
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- SALDO ----------

  /// GET /admin/users/{id}/points/
  Future<PointsBalance?> fetchBalance(String userId) async {
    try {
      final response = await _dio.get(ApiConfig.adminUserPoints(userId));
      if (response.data is Map) {
        return PointsBalance.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  // ---------- MOVIMIENTOS ----------

  /// GET /admin/users/{id}/points/movements/ (paginado + filtros).
  Future<DrfPage<PointsMovement>> fetchMovements(
    String userId, {
    String? direction,
    String? status,
    String? sourceType,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.adminUserPointsMovements(userId),
        queryParameters: {
          if (direction != null && direction.isNotEmpty) 'direction': direction,
          if (status != null && status.isNotEmpty) 'status': status,
          if (sourceType != null && sourceType.isNotEmpty) 'source_type': sourceType,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
          'page': page,
          'page_size': pageSize,
        },
      );
      return _parsePage(response.data, PointsMovement.fromJson);
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- AJUSTE ----------

  /// POST /admin/users/{id}/points/adjustments/  (Idempotency-Key obligatorio).
  /// Lanza ApiException; el 409 INSUFFICIENT_POINTS trae details:{needed, available}.
  Future<({String movementId, PointsBalance saldos})> adjust(
    String userId, {
    required int amount,
    required String reasonText,
    required String auditReference,
    required String idempotencyKey,
    String bucket = 'disponible',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.adminUserPointsAdjust(userId),
        data: {
          'amount': amount,
          'reason_text': reasonText,
          'audit_reference': auditReference,
          'bucket': bucket,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return (
        movementId: (data['movement_id'] ?? '').toString(),
        saldos: PointsBalance.fromJson(
            Map<String, dynamic>.from((data['saldos'] as Map?) ?? const {})),
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// POST /admin/points/adjustments/{movement_id}/reverse/
  Future<String?> reverse(String movementId, {required String reasonText}) async {
    try {
      final response = await _dio.post(
        ApiConfig.adminPointsAdjustReverse(movementId),
        data: {'reason_text': reasonText},
      );
      if (response.data is Map) {
        return (response.data['movement_id'] ?? '').toString();
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  // ---------- CONFIGURACIÓN ----------

  /// GET /admin/points/config/
  Future<PointsConfig> getConfig() async {
    try {
      final response = await _dio.get(ApiConfig.adminPointsConfig);
      if (response.data is Map) {
        return PointsConfig.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      throw toApiException(e);
    }
    return const PointsConfig();
  }

  /// PUT /admin/points/config/ (parcial: solo lo que se envía).
  Future<PointsConfig> putConfig(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(ApiConfig.adminPointsConfig, data: payload);
      if (response.data is Map) {
        return PointsConfig.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      throw toApiException(e);
    }
    return const PointsConfig();
  }

  // ---------- helper ----------

  DrfPage<T> _parsePage<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is Map) {
      final results = (data['results'] as List?) ?? const [];
      return DrfPage<T>(
        items: results
            .whereType<Map>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        count: _int(data['count']),
        hasMore: data['next'] != null,
      );
    }
    if (data is List) {
      return DrfPage<T>(
        items: data
            .whereType<Map>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        count: data.length,
      );
    }
    return DrfPage<T>();
  }

  static int _int(dynamic v) =>
      v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
}
