import 'package:get/get.dart';

import '../controllers/gdpr_controller.dart';
import '../controllers/general_admin_controller.dart';

class GdprBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GdprController>(() => GdprController());
    // GeneralAdminController might already exist; put only if not
    if (!Get.isRegistered<GeneralAdminController>()) {
      Get.put(GeneralAdminController());
    }
  }
}
