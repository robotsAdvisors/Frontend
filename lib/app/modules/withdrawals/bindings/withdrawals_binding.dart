import 'package:get/get.dart';

import '../controllers/withdrawals_controller.dart';

class WithdrawalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawalsController>(() => WithdrawalsController());
  }
}
