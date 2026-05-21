import 'package:dio/dio.dart';

import '../../../../utils/api_config.dart';
import '../../local/my_shared_pref.dart';

/// Cliente HTTP centralizado que se comunica con el backend Django de Letdem.
///
/// - Inyecta automaticamente el header `Authorization: Bearer <access_token>`.
/// - Si recibe 401 y existe un refresh token, intenta renovar el access token
///   (POST /accounts/token/refresh/) y reintenta la peticion una vez.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = MySharedPref.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final requestPath = error.requestOptions.path;
          final isRefreshRequest = requestPath.contains('token/refresh');

          if (response?.statusCode == 401 && !isRefreshRequest) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              try {
                final cloned = await _retry(error.requestOptions);
                return handler.resolve(cloned);
              } catch (_) {
                // fallthrough al error original
              }
            } else {
              // refresh fallido -> limpiar tokens
              await MySharedPref.clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  Future<bool> _tryRefreshToken() async {
    final refresh = MySharedPref.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final response = await Dio(
        BaseOptions(baseUrl: ApiConfig.apiBaseUrl),
      ).post(
        ApiConfig.tokenRefresh,
        data: {'refresh': refresh},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final newAccess = data['access'] as String?;
        final newRefresh = data['refresh'] as String?;
        if (newAccess != null) {
          await MySharedPref.setAccessToken(newAccess);
          if (newRefresh != null) {
            await MySharedPref.setRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

/// Excepcion legible para la UI al fallar una llamada HTTP.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => message;
}

/// Convierte cualquier error (DioException u otro) en un [ApiException].
ApiException toApiException(Object error) {
  if (error is ApiException) return error;
  if (error is DioException) {
    final data = error.response?.data;
    String message = error.message ?? 'Error de red';
    if (data is Map) {
      // DRF suele devolver {detail: '...'} o errores por campo
      if (data['detail'] is String) {
        message = data['detail'] as String;
      } else if (data['error'] is String) {
        message = data['error'] as String;
      } else {
        message = data.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }
    return ApiException(
      message,
      statusCode: error.response?.statusCode,
      data: data,
    );
  }
  return ApiException(error.toString());
}
