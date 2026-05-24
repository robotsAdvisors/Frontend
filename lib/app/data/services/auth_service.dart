import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../local/my_shared_pref.dart';
import '../repositories/auth_repository.dart';

/// Fachada de autenticacion usada por la UI.
///
/// Internamente delega en [AuthRepository] (backend Django Letdem).
/// Mantiene la misma API estatica que el codigo existente espera.
class AuthService {
  AuthService._();

  static const String customerRole = 'customer';
  static const String storeAdminRole = 'store_admin';
  static const String storeViewerRole = 'store_viewer';
  static const String generalAdminRole = 'general_admin';

  static String? get currentUserEmail => MySharedPref.getLoggedInUserEmail();

  static String get currentUserRole =>
      MySharedPref.getLoggedInUserRoleOrDefault();

  static bool get isStoreAdmin => currentUserRole == storeAdminRole;

  static bool get isStoreViewer => currentUserRole == storeViewerRole;

  static bool get isGeneralAdmin => currentUserRole == generalAdminRole;

  static bool get isLoggedIn {
    final token = MySharedPref.getAccessToken();
    return MySharedPref.getIsLoggedIn() && token != null && token.isNotEmpty;
  }

  /// Login contra POST /api/v1/accounts/auth/login/
  static Future<bool> signInWithEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    final loginData = await AuthRepository.instance.login(
      email: email,
      password: password,
    );

    // Try to extract role from response body, then JWT payload.
    String rawRole = (loginData['role'] ?? '').toString();
    if (rawRole.isEmpty) {
      final userMap = loginData['user'];
      if (userMap is Map) rawRole = (userMap['role'] ?? '').toString();
    }
    if (rawRole.isEmpty) {
      final access = (loginData['access'] as String?) ?? '';
      if (access.isNotEmpty) {
        final payload = AuthRepository.decodeJwt(access);
        rawRole = (payload['role'] ??
                payload['user_role'] ??
                payload['type'] ??
                '')
            .toString();
      }
    }
    final mappedRole = AuthRepository.mapRole(rawRole);
    final nextRole = mappedRole.isNotEmpty ? mappedRole : role;
    await MySharedPref.setLoggedInUserRole(nextRole);

    // Await fetchMe so it can override the role with the backend's authoritative value.
    await AuthRepository.instance.fetchMe();
    return true;
  }

  /// Signup contra POST /api/v1/accounts/auth/signup/
  static Future<bool> registerWithEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    await AuthRepository.instance.signup(email: email, password: password);
    await MySharedPref.setLoggedInUserRole(role);
    AuthRepository.instance.fetchMe();
    return true;
  }

  /// Login social con Google.
  ///
  /// Flujo:
  /// 1. `google_sign_in` obtiene `idToken` + `accessToken` del usuario Google.
  /// 2. Se intercambian por una credencial Firebase y se hace `signInWithCredential`.
  /// 3. Se solicita el ID token Firebase y se envia al backend Django:
  ///    `POST /accounts/auth/social-login/` que devuelve un JWT propio.
  /// 4. El JWT propio queda persistido para el resto de la app.
  ///
  /// Devuelve `true` si todo salio bien, `false` si el usuario cancelo.
  static Future<bool> signInWithGoogle({String role = customerRole}) async {
    UserCredential userCred;
    if (kIsWeb) {
      // En web `google_sign_in.signIn()` no devuelve idToken de forma confiable,
      // asi que delegamos en Firebase Auth directamente, que abre su propio
      // popup OAuth y entrega un `UserCredential` ya listo.
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      try {
        userCred =
            await FirebaseAuth.instance.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request') {
          return false; // usuario cerro el popup
        }
        rethrow;
      }
    } else {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false; // usuario cancelo

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }

    final firebaseUser = userCred.user;
    if (firebaseUser == null) {
      throw Exception('Firebase no devolvio usuario.');
    }

    final firebaseIdToken = await firebaseUser.getIdToken(true);
    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw Exception('No se pudo obtener el ID token de Firebase.');
    }

    await AuthRepository.instance.socialLogin(
      firebaseIdToken: firebaseIdToken,
      deviceId: _deviceId(firebaseUser.uid),
      email: firebaseUser.email,
    );

    final backendRole = MySharedPref.getLoggedInUserRole();
    final nextRole = (backendRole != null &&
            backendRole.isNotEmpty &&
            backendRole != customerRole)
        ? backendRole
        : role;
    await MySharedPref.setLoggedInUserRole(nextRole);

    AuthRepository.instance.fetchMe();
    return true;
  }

  static Future<void> signOut() async {
    // Cierra Firebase si hay sesion social activa.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await AuthRepository.instance.logout();
    await MySharedPref.setLoggedInUserRole('');
    await MySharedPref.setLoggedIn(false);
  }

  /// Identificador estable por instalacion para enviar al backend.
  static String _deviceId(String uid) {
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else {
      platform = 'other';
    }
    return 'letdem-$platform-$uid';
  }

  /// Tarjeta virtual asignada al usuario. Mientras no exista un endpoint
  /// dedicado en el backend, derivamos un numero estable a partir del email.
  static Future<Map<String, String>> fetchAssignedVirtualCard() async {
    final email = currentUserEmail ?? 'cliente@example.com';
    final digits = email
        .replaceAll(RegExp(r'[^0-9]'), '')
        .padRight(4, '8')
        .substring(0, 4);
    return {
      'type': 'Marketplace Virtual',
      'number': '4589 1234 5678 $digits',
      'expiry': '09/29',
      'owner': email,
    };
  }
}
