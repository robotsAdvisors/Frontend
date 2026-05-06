import 'package:get/get.dart';

import '../controllers/general_admin_controller.dart';

class GeneralAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GeneralAdminController());
  }
}