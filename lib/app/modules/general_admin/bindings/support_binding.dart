import 'package:get/get.dart';

import '../controllers/general_admin_controller.dart';
import '../controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GeneralAdminController>(
        () => GeneralAdminController(), fenix: true);
    Get.lazyPut<SupportController>(() => SupportController());
  }
}
