import '../../../utils/api_config.dart';
import '../local/my_shared_pref.dart';
import '../services/http/api_client.dart';

/// Repositorio de autenticacion contra el backend Django (Letdem).
///
/// Endpoints utilizados:
/// - POST /api/v1/accounts/auth/login/
/// - POST /api/v1/accounts/auth/signup/
/// - GET  /api/v1/accounts/me
/// - PUT  /api/v1/accounts/me
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final _dio = ApiClient.instance.dio;

  /// Inicia sesion y persiste los tokens (access, refresh).
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
          if (deviceId != null) 'device_id': deviceId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data as Map);
        await _persistTokens(data);
        await MySharedPref.setLoggedInUserEmail(email);
        await MySharedPref.setLoggedIn(true);
        return data;
      }
      throw toApiException(
        Exception(response.data?.toString() ?? 'Error de autenticacion'),
      );
    } catch (error) {
      throw toApiException(error);
    }
  }

  /// Registra un usuario nuevo.
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.authSignup,
        data: {
          'email': email,
          'password': password,
          if (preferences != null) 'preferences': preferences,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data as Map);
        await _persistTokens(data);
        await MySharedPref.setLoggedInUserEmail(email);
        await MySharedPref.setLoggedIn(true);
        return data;
      }
      throw toApiException(
        Exception(response.data?.toString() ?? 'Error de registro'),
      );
    } catch (error) {
      throw toApiException(error);
    }
  }

  /// Reset/cambio de contrasena via OTP.
  Future<void> resetPassword({
    required String email,
    String? otp,
    String? newPassword,
    String? confirmPassword,
  }) async {
    try {
      await _dio.post(ApiConfig.authResetPassword, data: {
        'email': email,
        if (otp != null) 'otp': otp,
        if (newPassword != null) 'new_password': newPassword,
        if (confirmPassword != null) 'confirm_password': confirmPassword,
      });
    } catch (error) {
      throw toApiException(error);
    }
  }

  /// Intercambia un Firebase ID token por un JWT propio del backend.
  ///
  /// Endpoint: POST /accounts/auth/social-login/
  /// Body: `{ "token": "<firebase_id_token>", "device_id": "<id>" }`
  Future<Map<String, dynamic>> socialLogin({
    required String firebaseIdToken,
    required String deviceId,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.authSocialLogin,
        data: {
          'token': firebaseIdToken,
          'device_id': deviceId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data as Map);
        await _persistTokens(data);
        if (email != null && email.isNotEmpty) {
          await MySharedPref.setLoggedInUserEmail(email);
        }
        await MySharedPref.setLoggedIn(true);
        return data;
      }
      throw toApiException(
        Exception(response.data?.toString() ?? 'Error de social login'),
      );
    } catch (error) {
      throw toApiException(error);
    }
  }

  /// Trae los datos del usuario autenticado.
  /// Devuelve `null` si no hay token o falla la peticion.
  Future<Map<String, dynamic>?> fetchMe() async {
    final token = MySharedPref.getAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _dio.get(ApiConfig.me);
      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final totalPoints = data['total_points'];
        if (totalPoints is int) {
          await MySharedPref.setTotalPoints(totalPoints);
        }
        return data;
      }
    } catch (_) {}
    return null;
  }

  /// Actualiza datos del perfil (nombre, telefono, direccion, etc.).
  Future<Map<String, dynamic>?> updateMe(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(ApiConfig.me, data: payload);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (error) {
      throw toApiException(error);
    }
    return null;
  }

  /// Cierra sesion local (limpia tokens y flags).
  Future<void> logout() async {
    await MySharedPref.clearTokens();
    await MySharedPref.setLoggedIn(false);
    await MySharedPref.setLoggedInUserEmail('');
  }

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access != null && access.isNotEmpty) {
      await MySharedPref.setAccessToken(access);
    }
    if (refresh != null && refresh.isNotEmpty) {
      await MySharedPref.setRefreshToken(refresh);
    }
  }
}
