import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Avisos flotantes del backoffice.
///
/// Antes era un bloque de color macizo pegado al borde superior y del ancho
/// completo de la pantalla —en un panel de 1900 px, una franja enorme— con
/// esquinas rectas y texto blanco sobre rojo saturado. Parecia una alerta del
/// navegador, no parte de la interfaz.
///
/// Ahora es una tarjeta: fondo claro, esquinas y sombra como las del resto del
/// panel, ancho acotado, y el color reservado al icono y a una franja lateral.
/// El color sirve para distinguir de un vistazo, no para gritar.
class CustomSnackBar {
  static const Color _verde = Color(0xFF10B981);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _texto = Color(0xFF111827);
  static const Color _textoSuave = Color(0xFF6B7280);

  /// En una pantalla ancha, un aviso de borde a borde es ruido.
  static const double _anchoMaximo = 460;

  static void _mostrar({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      maxWidth: _anchoMaximo,
      borderRadius: 16,
      backgroundColor: Colors.white,
      colorText: _texto,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(14, 16, 18, 16),
      // Franja lateral del color del aviso: identifica sin invadir.
      leftBarIndicatorColor: color,
      titleText: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _texto,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: _textoSuave,
        ),
      ),
      icon: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static showCustomSnackBar({
    required String title,
    required String message,
    Duration? duration,
  }) {
    _mostrar(
      title: title,
      message: message,
      color: _verde,
      icon: Icons.check_circle_outline,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static showCustomErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _mostrar(
      title: title,
      message: message,
      color: color ?? _rojo,
      icon: Icons.error_outline,
      // Un error se lee mas despacio que una confirmacion.
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  static showCustomToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _mostrar(
      title: title ?? 'Listo',
      message: message,
      color: color ?? _verde,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static showCustomErrorToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _mostrar(
      title: title ?? 'Error',
      message: message,
      color: color ?? _rojo,
      icon: Icons.error_outline,
      duration: duration ?? const Duration(seconds: 5),
    );
  }
}
