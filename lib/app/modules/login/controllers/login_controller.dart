import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/http/api_client.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;
  final RxString selectedRole = AuthService.storeAdminRole.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
      );
      Get.offAllNamed(
        AuthService.isStoreAdmin || AuthService.isStoreViewer
            ? Routes.ADMIN
            : AuthService.isGeneralAdmin
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      _showLoginError(_authErrorMessage(exception));
    } catch (error) {
      _showLoginError(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Traduce los fallos de autenticación a un mensaje claro y localizado.
  /// El backend (DRF/SimpleJWT) devuelve 401/400 con textos en inglés como
  /// "No active account found with the given credentials"; para credenciales
  /// inválidas mostramos siempre el mismo mensaje en español.
  String _authErrorMessage(ApiException exception) {
    if (exception.statusCode == 401 || exception.statusCode == 400) {
      return 'Correo o contraseña incorrectos.';
    }
    return exception.message;
  }

  void _showLoginError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
      );
      Get.offAllNamed(
        selectedRole.value == AuthService.storeAdminRole
            ? Routes.ADMIN
            : selectedRole.value == AuthService.generalAdminRole
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      Get.snackbar(
        'Error',
        exception.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login social: Google -> Firebase -> backend (`/accounts/auth/social-login/`).
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final ok = await AuthService.signInWithGoogle(role: selectedRole.value);
      if (!ok) return; // usuario cancelo
      Get.offAllNamed(
        AuthService.isStoreAdmin || AuthService.isStoreViewer
            ? Routes.ADMIN
            : AuthService.isGeneralAdmin
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      Get.snackbar(
        'Error',
        _shortenError(exception.message),
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 500,
        duration: const Duration(seconds: 5),
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        _shortenError('No se pudo iniciar sesión con Google: $error'),
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 500,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Recorta mensajes de error gigantes (JSON, stack) para que el snackbar
  /// no rompa el layout.
  String _shortenError(String raw) {
    final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.contains('People API has not been used')) {
      return 'Google rechazó la petición: el proyecto no tiene habilitada la People API. '
          'Actívala en Google Cloud Console y vuelve a intentarlo.';
    }
    if (oneLine.contains('PERMISSION_DENIED')) {
      return 'Google denegó el acceso (PERMISSION_DENIED). Revisa los permisos del OAuth Client.';
    }
    return oneLine.length > 220 ? '${oneLine.substring(0, 220)}…' : oneLine;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (value.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }
}
