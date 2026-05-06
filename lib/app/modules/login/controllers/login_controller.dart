import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;
  final RxString selectedRole = AuthService.customerRole.obs;

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
    } on FirebaseAuthException catch (exception) {
      Get.snackbar(
        'Error',
        _messageForFirebaseException(exception),
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
    } on FirebaseAuthException catch (exception) {
      Get.snackbar(
        'Error',
        _messageForFirebaseException(exception),
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

  String _messageForFirebaseException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Correo inválido.';
      case 'user-disabled':
        return 'El usuario ha sido deshabilitado.';
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      default:
        return exception.message ?? 'Error de autenticación.';
    }
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
