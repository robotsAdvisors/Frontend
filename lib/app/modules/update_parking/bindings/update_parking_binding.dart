import 'package:get/get.dart';

import '../controllers/update_parking_controller.dart';

class UpdateParkingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateParkingController>(() => UpdateParkingController());
  }
}
