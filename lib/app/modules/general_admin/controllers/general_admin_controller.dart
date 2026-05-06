import 'package:get/get.dart';

import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../utils/dummy_helper.dart';

class GeneralAdminController extends GetxController {
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxList<StoreUserModel> storeUsers = <StoreUserModel>[].obs;
  final RxInt totalStores = 0.obs;
  final RxInt totalStoreUsers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    stores.assignAll(DummyHelper.stores);
    storeUsers.assignAll(DummyHelper.storeUsers);
    _calculateMetrics();
  }

  void _calculateMetrics() {
    totalStores.value = stores.length;
    totalStoreUsers.value = storeUsers.length;
  }

  void addStore(StoreModel store) {
    stores.add(store);
    _calculateMetrics();
  }

  void addStoreUser(StoreUserModel user) {
    storeUsers.add(user);
    _calculateMetrics();
  }

  void removeStore(String storeId) {
    stores.removeWhere((store) => store.id == storeId);
    storeUsers.removeWhere((user) => user.storeId == storeId);
    _calculateMetrics();
  }

  void removeStoreUser(String userId) {
    storeUsers.removeWhere((user) => user.id == userId);
    _calculateMetrics();
  }
}