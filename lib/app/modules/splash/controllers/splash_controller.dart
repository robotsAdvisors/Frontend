import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  @override
  void onInit() async {
    await Future.delayed(const Duration(seconds: 2));
    final bool loggedIn = AuthService.isLoggedIn || MySharedPref.getIsLoggedIn();
    if (loggedIn) {
      // Fetch fresh user data from backend — fetchMe now saves the role.
      await AuthRepository.instance.fetchMe();

      final role = AuthService.currentUserRole;
      if (role == AuthService.storeAdminRole || role == AuthService.storeViewerRole) {
        Get.offNamed(Routes.ADMIN);
      } else if (role == AuthService.generalAdminRole) {
        Get.offNamed(Routes.GENERAL_ADMIN);
      } else {
        Get.offNamed(Routes.BASE);
      }
    } else {
      Get.offNamed(Routes.WELCOME);
    }
    super.onInit();
  }

}
