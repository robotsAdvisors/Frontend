import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/translations/localization_service.dart';

class MySharedPref {
  // prevent making instance
  MySharedPref._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _fcmTokenKey = 'fcm_token';
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loggedInUserEmailKey = 'logged_in_user_email';
  static const String _loggedInUserRoleKey = 'logged_in_user_role';
    static const String _customerNameKey = 'customer_name';
    static const String _customerPhoneKey = 'customer_phone';
    static const String _customerAddressKey = 'customer_address';
    static const String _customerProfileImageKey = 'customer_profile_image';
    // JWT tokens del backend Django
    static const String _accessTokenKey = 'access_token';
    static const String _refreshTokenKey = 'refresh_token';
    static const String _totalPointsKey = 'user_total_points';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ?? true; // todo set the default theme (true for light, false for dark)

  /// save current locale
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal(){
      String? langCode = _sharedPreferences.getString(_currentLocalKey);
      // default language is english
      if(langCode == null){
        return LocalizationService.defaultLanguage;
      }
      return LocalizationService.supportedLanguages[langCode]!;
  }

  /// save generated fcm token
  static Future<void> setFcmToken(String token) =>
      _sharedPreferences.setString(_fcmTokenKey, token);

  /// get generated fcm token
  static String? getFcmToken() =>
      _sharedPreferences.getString(_fcmTokenKey);

  /// set login state
  static Future<void> setLoggedIn(bool value) =>
      _sharedPreferences.setBool(_isLoggedInKey, value);

  /// get login state
  static bool getIsLoggedIn() =>
      _sharedPreferences.getBool(_isLoggedInKey) ?? false;

  /// save the current logged in email
  static Future<void> setLoggedInUserEmail(String email) =>
      _sharedPreferences.setString(_loggedInUserEmailKey, email);

  /// get the current logged in email
  static String? getLoggedInUserEmail() =>
      _sharedPreferences.getString(_loggedInUserEmailKey);

  /// save the current logged in role
  static Future<void> setLoggedInUserRole(String role) =>
      _sharedPreferences.setString(_loggedInUserRoleKey, role);

  /// get the current logged in role
  static String? getLoggedInUserRole() =>
      _sharedPreferences.getString(_loggedInUserRoleKey);

  /// get the current logged in role, or customer if missing
  static String getLoggedInUserRoleOrDefault() =>
      _sharedPreferences.getString(_loggedInUserRoleKey) ?? 'customer';

  /// save customer profile data
  static Future<void> setCustomerName(String value) =>
      _sharedPreferences.setString(_customerNameKey, value);

  static Future<void> setCustomerPhone(String value) =>
      _sharedPreferences.setString(_customerPhoneKey, value);

  static Future<void> setCustomerAddress(String value) =>
      _sharedPreferences.setString(_customerAddressKey, value);

  /// get customer profile data
  static String? getCustomerName() =>
      _sharedPreferences.getString(_customerNameKey);

  static String? getCustomerPhone() =>
      _sharedPreferences.getString(_customerPhoneKey);

  static String? getCustomerAddress() =>
      _sharedPreferences.getString(_customerAddressKey);

  static Future<void> setCustomerProfileImage(String path) =>
      _sharedPreferences.setString(_customerProfileImageKey, path);

  static String? getCustomerProfileImage() =>
      _sharedPreferences.getString(_customerProfileImageKey);

  // ---- JWT del backend Django ----
  static Future<void> setAccessToken(String token) =>
      _sharedPreferences.setString(_accessTokenKey, token);

  static String? getAccessToken() =>
      _sharedPreferences.getString(_accessTokenKey);

  static Future<void> setRefreshToken(String token) =>
      _sharedPreferences.setString(_refreshTokenKey, token);

  static String? getRefreshToken() =>
      _sharedPreferences.getString(_refreshTokenKey);

  static Future<void> clearTokens() async {
    await _sharedPreferences.remove(_accessTokenKey);
    await _sharedPreferences.remove(_refreshTokenKey);
  }

  // ---- Total points (gamificacion / wallet) ----
  static Future<void> setTotalPoints(int points) =>
      _sharedPreferences.setInt(_totalPointsKey, points);

  static int getTotalPoints() =>
      _sharedPreferences.getInt(_totalPointsKey) ?? 0;

  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();

}