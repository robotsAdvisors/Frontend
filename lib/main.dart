import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';

Future<void> main() async {
  // wait for bindings
  WidgetsFlutterBinding.ensureInitialized();

  // init shared preference
  await MySharedPref.init();

  // init firebase for authentication and future backend support
  // On web we skip Firebase init unless FirebaseOptions are configured,
  // so the smoke test against the REST backend can run without
  // a Firebase project setup.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }
  }

  runApp(const _Bootstrap());
}

/// Roots the app and, on wide viewports (desktop / tablet landscape), renders
/// inside a mobile-shaped frame BEFORE [ScreenUtilInit] reads MediaQuery. This
/// keeps every `flutter_screenutil` scaled value (`.w`, `.h`, `.sp`, `.r`) at
/// its intended mobile proportion instead of being multiplied ~5x by the
/// desktop width.
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  static const double _frameWidth = 480;
  static const double _breakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.fromView(
      view: View.of(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _breakpoint;
          final width = isWide ? _frameWidth : constraints.maxWidth;
          final height = constraints.maxHeight;

          final app = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(width, height),
              textScaler: const TextScaler.linear(1.0),
            ),
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              useInheritedMediaQuery: true,
              rebuildFactor: (old, data) => true,
              builder: (context, widget) {
                final themeIsLight = MySharedPref.getThemeIsLight();
                return GetMaterialApp(
                  title: 'Letdem',
                  useInheritedMediaQuery: true,
                  debugShowCheckedModeBanner: false,
                  theme: MyTheme.getThemeData(isLight: themeIsLight),
                  initialRoute: AppPages.INITIAL,
                  getPages: AppPages.routes,
                  locale: MySharedPref.getCurrentLocal(),
                  translations: LocalizationService.getInstance(),
                );
              },
            ),
          );

          if (!isWide) return app;
          return ColoredBox(
            color: const Color(0xFF111418),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: app,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
