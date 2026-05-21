import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/local/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';

class MyTheme {
  static getThemeData({required bool isLight}){
    final Color primary = isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor;
    final Color onPrimary = isLight ? Colors.white : const Color(0xFF0B261B);
    final Color surface = isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor;
    final Color onSurface = isLight ? LightThemeColors.headlinesTextColor : DarkThemeColors.headlinesTextColor;

    return ThemeData(
        useMaterial3: true,
        // main color (app bar,tabs..etc)
        primaryColor: isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor,
        primaryColorLight: isLight ? LightThemeColors.primaryColorLight : DarkThemeColors.primaryColorLight,
        primaryColorDark: isLight ? LightThemeColors.primaryColorDark : DarkThemeColors.primaryColorDark,
        // secondary color is now exposed via colorScheme.secondary
        colorScheme: ColorScheme(
          brightness: isLight ? Brightness.light : Brightness.dark,
          primary: primary,
          onPrimary: onPrimary,
          secondary: isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
          onSecondary: onPrimary,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: surface,
          onSurface: onSurface,
        ),
        // color contrast (if the theme is dark text should be white for example)
        brightness: isLight ? Brightness.light : Brightness.dark,
        // canvas Color
        canvasColor: isLight ? LightThemeColors.canvasColor : DarkThemeColors.canvasColor,
        // card widget background color
        cardColor: isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,
        // hint text color
        hintColor: isLight ? LightThemeColors.hintTextColor : DarkThemeColors.hintTextColor,
        // divider color
        dividerColor: isLight ? LightThemeColors.dividerColor : DarkThemeColors.dividerColor,
        // app background color (now via colorScheme.surface and scaffoldBackgroundColor)
        scaffoldBackgroundColor: isLight ? LightThemeColors.scaffoldBackgroundColor : DarkThemeColors.scaffoldBackgroundColor,

        // progress bar theme
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor,
        ),

        // appBar theme
        appBarTheme: MyStyles.getAppBarTheme(isLightTheme: isLight),

        // elevated button theme
        elevatedButtonTheme: MyStyles.getElevatedButtonTheme(isLightTheme: isLight),

        // text theme
        textTheme: MyStyles.getTextTheme(isLightTheme: isLight),

        // chip theme
        chipTheme: MyStyles.getChipTheme(isLightTheme: isLight),

        // icon theme
        iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),

        // card theme
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isLight ? LightThemeColors.dividerColor : DarkThemeColors.dividerColor,
            ),
          ),
        ),

        // bottom navigation theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: isLight ? Colors.white : DarkThemeColors.backgroundColor,
          selectedItemColor: primary,
          unselectedItemColor: isLight ? LightThemeColors.iconColor : DarkThemeColors.iconColor,
          selectedIconTheme: IconThemeData(color: primary),
          unselectedIconTheme: IconThemeData(
            color: isLight ? LightThemeColors.iconColor : DarkThemeColors.iconColor,
          ),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        // input style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isLight ? Colors.white : DarkThemeColors.primaryColorDark,
          hintStyle: TextStyle(
            color: isLight ? LightThemeColors.hintTextColor : DarkThemeColors.hintTextColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isLight ? LightThemeColors.dividerColor : DarkThemeColors.dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 1.2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // snackbars
        snackBarTheme: SnackBarThemeData(
          backgroundColor: isLight ? LightThemeColors.headlinesTextColor : DarkThemeColors.primaryColorDark,
          contentTextStyle: TextStyle(
            color: isLight ? Colors.white : DarkThemeColors.headlinesTextColor,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
    );
  }

  /// update app theme and save theme type to shared pref
  /// (so when the app is killed and up again theme will remain the same)
  static changeTheme() {
    // *) check if the current theme is light (default is light)
    bool isLightTheme = MySharedPref.getThemeIsLight();
    // *) store the new theme mode on get storage
    MySharedPref.setThemeIsLight(!isLightTheme);
    // *) let GetX change theme
    Get.changeThemeMode(!isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }

  /// check if the theme is light or dark
  bool get getThemeIsLight => MySharedPref.getThemeIsLight();
}