import 'dart:io';

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
    await AuthRepository.instance.login(email: email, password: password);

    final savedRole = MySharedPref.getLoggedInUserRole();
    final nextRole =
        (savedRole == null || savedRole.isEmpty) ? role : savedRole;
    await MySharedPref.setLoggedInUserRole(nextRole);

    // Cargar perfil en background (no bloquea el login).
    AuthRepository.instance.fetchMe();
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
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false; // usuario cancelo

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);
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

    final savedRole = MySharedPref.getLoggedInUserRole();
    final nextRole =
        (savedRole == null || savedRole.isEmpty) ? role : savedRole;
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
    await MySharedPref.setLoggedInUserRole(customerRole);
  }

  /// Identificador estable por instalacion para enviar al backend.
  static String _deviceId(String uid) {
    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'web';
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
