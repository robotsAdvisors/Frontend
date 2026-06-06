import 'package:get/get.dart';

import '../controllers/virtual_card_controller.dart';

class VirtualCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VirtualCardController>(() => VirtualCardController());
  }
}
