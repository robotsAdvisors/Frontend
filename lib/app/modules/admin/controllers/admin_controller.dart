import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/services/auth_service.dart';

class AdminController extends GetxController {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<StoreUserModel> storeUsers = <StoreUserModel>[].obs;
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxSet<String> favoriteVoucherIds = <String>{}.obs;
  late StoreModel currentStore;
  final RxInt totalProducts = 0.obs;
  final RxInt totalStock = 0.obs;
  final RxDouble averagePrice = 0.0.obs;
  final RxString storeId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final email = AuthService.currentUserEmail ?? '';
    storeId.value = DummyHelper.storeIdForAdminEmail(email) ?? '';
    currentStore = DummyHelper.stores.firstWhere(
      (store) => store.id == storeId.value,
      orElse: () => DummyHelper.stores.first,
    );
    products.assignAll(
      DummyHelper.products.where((product) => product.storeId == currentStore.id).toList(),
    );
    storeUsers.assignAll(
      DummyHelper.storeUsers.where((user) => user.storeId == currentStore.id).toList(),
    );
    vouchers.assignAll(
      DummyHelper.vouchers.where((voucher) => voucher.storeId == currentStore.id).toList(),
    );
    _calculateStoreMetrics();
  }

  void _calculateStoreMetrics() {
    totalProducts.value = products.length;
    totalStock.value = products.fold<int>(0, (sum, item) => sum + item.quantity);
    averagePrice.value = products.isNotEmpty
        ? products.fold<double>(0.0, (sum, item) => sum + item.discountPrice) / products.length
        : 0.0;
  }

  void addProduct(ProductModel product) {
    products.add(product);
    _calculateStoreMetrics();
  }

  void deleteProduct(ProductModel product) {
    products.remove(product);
    _calculateStoreMetrics();
  }

  List<VoucherModel> get recentValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return vouchers.where((voucher) => voucher.createdAt.isAfter(cutoff) && !voucher.isRedeemed && !voucher.isExpired).toList();
  }

  List<VoucherModel> get lastMonthValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return vouchers.where((voucher) => voucher.createdAt.isAfter(cutoff) && !voucher.isRedeemed && !voucher.isExpired).toList();
  }

  List<VoucherModel> get redeemedVouchers {
    return vouchers.where((voucher) => voucher.isRedeemed).toList();
  }

  List<VoucherModel> get expiredUnredeemedVouchers {
    return vouchers.where((voucher) => voucher.isExpired && !voucher.isRedeemed).toList();
  }

  List<VoucherModel> get favoriteVouchers {
    return vouchers.where((voucher) => favoriteVoucherIds.contains(voucher.id)).toList();
  }

  bool isFavorite(String voucherId) {
    return favoriteVoucherIds.contains(voucherId);
  }

  void toggleFavorite(String voucherId) {
    if (favoriteVoucherIds.contains(voucherId)) {
      favoriteVoucherIds.remove(voucherId);
    } else {
      favoriteVoucherIds.add(voucherId);
    }
  }

  String customerNameFor(VoucherModel voucher) {
    return DummyHelper.customerNameById(voucher.customerUserId);
  }

  String customerEmailFor(VoucherModel voucher) {
    return DummyHelper.customerEmailById(voucher.customerUserId);
  }

  String productNameFor(VoucherModel voucher) {
    return DummyHelper.productNameById(voucher.productId);
  }
}

