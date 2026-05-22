import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // wait for bindings
  WidgetsFlutterBinding.ensureInitialized();

  // init shared preference
  await MySharedPref.init();

  // Init Firebase on all platforms (web included) using the generated
  // options from `flutterfire configure`. Required for Google social login.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  runApp(const _Bootstrap());
}

/// Roots the app. `flutter_screenutil` derives `.w/.h/.sp` from the build
/// constraints, so on a wide desktop viewport every scaled value gets
/// inflated ~5x. We make the design size equal to the real viewport above a
/// breakpoint so the scale factor stays ~1 (text/buttons render at native
/// pixel sizes instead of huge); on mobile widths we keep the original 390x844
/// design so the existing mobile look is unchanged.
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  static const double _mobileBreakpoint = 600;
  static const Size _mobileDesign = Size(390, 844);
  /// On wide viewports, keep `flutter_screenutil` at a comfortable scale
  /// (~1.3x design pixels) instead of letting `.sp/.w` either inflate to ~5x
  /// the viewport (no cap) or shrink to 1:1 (which looks tiny on desktop).
  static const double _desktopScale = 1.3;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.fromView(
      view: View.of(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final designSize = w >= _mobileBreakpoint
              ? Size(w / _desktopScale, h / _desktopScale)
              : _mobileDesign;
          return ScreenUtilInit(
            designSize: designSize,
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, widget) {
              final themeIsLight = MySharedPref.getThemeIsLight();
              return GetMaterialApp(
                title: 'Letdem',
                debugShowCheckedModeBanner: false,
                theme: MyTheme.getThemeData(isLight: themeIsLight),
                initialRoute: AppPages.INITIAL,
                getPages: AppPages.routes,
                locale: MySharedPref.getCurrentLocal(),
                translations: LocalizationService.getInstance(),
              );
            },
          );
        },
      ),
    );
  }
}
