import 'package:firebase_auth/firebase_auth.dart';

import '../local/my_shared_pref.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static const String customerRole = 'customer';
  static const String storeAdminRole = 'store_admin';
  static const String storeViewerRole = 'store_viewer';
  static const String generalAdminRole = 'general_admin';

  static String? get currentUserEmail =>
      _firebaseAuth.currentUser?.email ?? MySharedPref.getLoggedInUserEmail();

  static String get currentUserRole =>
      MySharedPref.getLoggedInUserRoleOrDefault();

  static bool get isStoreAdmin => currentUserRole == storeAdminRole;

  static bool get isStoreViewer => currentUserRole == storeViewerRole;

  static bool get isGeneralAdmin => currentUserRole == generalAdminRole;

  static bool get isLoggedIn =>
      _firebaseAuth.currentUser != null || MySharedPref.getIsLoggedIn();

  static Future<bool> signInWithEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? savedRole = MySharedPref.getLoggedInUserRole();
      final String nextRole = (savedRole == null || savedRole.isEmpty) ? role : savedRole;

      await MySharedPref.setLoggedIn(true);
      await MySharedPref.setLoggedInUserEmail(userCredential.user?.email ?? email);
      await MySharedPref.setLoggedInUserRole(nextRole);
      return true;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  static Future<bool> registerWithEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await MySharedPref.setLoggedIn(true);
      await MySharedPref.setLoggedInUserEmail(userCredential.user?.email ?? email);
      await MySharedPref.setLoggedInUserRole(role);
      return true;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    await MySharedPref.setLoggedIn(false);
    await MySharedPref.setLoggedInUserEmail('');
    await MySharedPref.setLoggedInUserRole(customerRole);
  }

  /// Simulates a backend call that assigns a virtual card for the current user.
  static Future<Map<String, String>> fetchAssignedVirtualCard() async {
    await Future.delayed(const Duration(milliseconds: 600));
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
