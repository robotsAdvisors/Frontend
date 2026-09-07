import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/services/http/api_client.dart';
import 'package:letdem/app/data/services/http/error_messages.dart';

/// Construye el error tal y como llega de Dio cuando el backend responde con
/// el contrato `{error_code, message, details}`.
DioException _respuestaDelBackend(
  String errorCode,
  String message, {
  int status = 400,
  Map<String, dynamic> details = const {},
}) {
  final peticion = RequestOptions(path: '/cualquiera/');
  return DioException(
    requestOptions: peticion,
    response: Response(
      requestOptions: peticion,
      statusCode: status,
      data: {
        'error_code': errorCode,
        'message': message,
        if (details.isNotEmpty) 'details': details,
      },
    ),
  );
}

void main() {
  group('Traducción de los errores del backend', () {
    test('traduce el mensaje en lugar de mostrar el del servidor', () {
      // El backend responde en inglés y la interfaz está en español: sin esto
      // el administrador veía "Invalid Credentials." en una pantalla española.
      final e = toApiException(
        _respuestaDelBackend('INVALID_CREDENTIALS', 'Invalid Credentials.'),
      );

      expect(e.message, 'Credenciales inválidas. Inténtalo de nuevo.');
      expect(e.errorCode, 'INVALID_CREDENTIALS');
    });

    test('conserva el mensaje del servidor si el código no está traducido', () {
      // Nunca se pierde información: un error nuevo del backend se sigue
      // viendo aunque todavía no tenga traducción.
      final e = toApiException(
        _respuestaDelBackend('CODIGO_NUEVO_SIN_TRADUCIR', 'Something failed'),
      );

      expect(e.message, 'Something failed');
    });

    test('traduce los errores de la política de contraseñas', () {
      final e = toApiException(
        _respuestaDelBackend(
          'PASSWORD_REQUIRES_SPECIAL_CHARACTER',
          'Password must contain at least one special character.',
        ),
      );

      expect(e.message, contains('carácter especial'));
    });

    test('traduce el bloqueo por demasiados intentos', () {
      final e = toApiException(
        _respuestaDelBackend(
          'TOO_MANY_ATTEMPTS',
          'Too many attempts.',
          status: 429,
        ),
      );

      expect(e.message, contains('Demasiados intentos'));
      expect(e.statusCode, 429);
    });

    test('la traducción no rompe details ni missingPoints', () {
      // El mensaje se traduce, pero el resto del contrato debe llegar intacto:
      // la pantalla de puntos construye su propio "te faltan N" a partir de él.
      final e = toApiException(
        _respuestaDelBackend(
          'INSUFFICIENT_POINTS',
          'Not enough points.',
          status: 409,
          details: {'needed': 500, 'available': 120},
        ),
      );

      expect(e.errorCode, 'INSUFFICIENT_POINTS');
      expect(e.missingPoints, 380);
    });

    test('una respuesta sin error_code no se ve afectada', () {
      // nginx, una página HTML de Django o un endpoint fuera del contrato.
      final peticion = RequestOptions(path: '/x/');
      final e = toApiException(
        DioException(
          requestOptions: peticion,
          response: Response(
            requestOptions: peticion,
            statusCode: 500,
            data: {'detail': 'Server exploded'},
          ),
        ),
      );

      expect(e.message, 'Server exploded');
      expect(e.errorCode, isEmpty);
    });
  });

  group('Catálogo de traducciones', () {
    test('ningún mensaje está vacío', () {
      for (final codigo in ErrorMessages.codigos) {
        expect(
          ErrorMessages.of(codigo),
          isNotEmpty,
          reason: '$codigo no tiene texto',
        );
      }
    });

    test('cubre los errores de autenticación y de puntos', () {
      // Los flujos que el backoffice usa a diario. Si alguien retira uno del
      // catálogo, ese error volvería a mostrarse en inglés.
      const imprescindibles = [
        'INVALID_CREDENTIALS',
        'INACTIVE_ACCOUNT',
        'TOO_MANY_ATTEMPTS',
        'INSUFFICIENT_POINTS',
        'MOVEMENT_NOT_FOUND',
        'ALREADY_REVERSED',
        'IDEMPOTENCY_KEY_REQUIRED',
        'VALIDATION_ERROR',
      ];
      for (final codigo in imprescindibles) {
        expect(
          ErrorMessages.of(codigo),
          isNotNull,
          reason: '$codigo dejaría de estar traducido',
        );
      }
    });
  });
}
