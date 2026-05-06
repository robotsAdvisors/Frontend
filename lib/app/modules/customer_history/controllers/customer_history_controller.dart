import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/services/auth_service.dart';

class CustomerHistoryController extends GetxController {
  final RxList<VoucherModel> customerVouchers = <VoucherModel>[].obs;
  final RxMap<String, int> voucherRatings = <String, int>{}.obs;
  final RxString walletCode = ''.obs;
  final RxString walletStatus = 'Activa'.obs;
  final RxBool loadingWallet = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
    _loadCustomerHistory();
  }

  Future<void> _loadWalletData() async {
    loadingWallet.value = true;
    final card = await AuthService.fetchAssignedVirtualCard();
    walletCode.value = (card['number'] ?? '0000 0000 0000 0000').replaceAll(' ', '');
    walletStatus.value = 'Activa';
    loadingWallet.value = false;
  }

  void _loadCustomerHistory() {
    final userEmail = AuthService.currentUserEmail ?? 'cliente@marketplace.com';
    final customerId = DummyHelper.customerIdForEmail(userEmail);
    final values = DummyHelper.vouchers
        .where((voucher) => voucher.customerUserId == customerId)
        .toList();

    if (values.isEmpty) {
      final fallbackCustomerId = DummyHelper.customerIdForEmail('cliente@marketplace.com');
      customerVouchers.assignAll(
        DummyHelper.vouchers
            .where((voucher) => voucher.customerUserId == fallbackCustomerId)
            .toList(),
      );
      return;
    }

    customerVouchers.assignAll(values);
  }

  List<VoucherModel> get walletMovements {
    final copy = customerVouchers.toList();
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  String statusLabel(VoucherModel voucher) {
    if (voucher.isRedeemed) {
      return 'Canjeado';
    }
    final expiredByDate = voucher.expiresAt != null && voucher.expiresAt!.isBefore(DateTime.now());
    if (voucher.isExpired || expiredByDate) {
      return 'Expirado';
    }
    return 'Pendiente';
  }

  String remainingTime(VoucherModel voucher) {
    if (statusLabel(voucher) != 'Pendiente' || voucher.expiresAt == null) {
      return '-';
    }
    final diff = voucher.expiresAt!.difference(DateTime.now());
    if (diff.isNegative) {
      return 'Expirado';
    }
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    return '${days}d ${hours}h restantes';
  }

  String discountText(VoucherModel voucher) {
    return '${voucher.discountPercent.toStringAsFixed(0)}%';
  }

  String productNameFor(VoucherModel voucher) {
    return DummyHelper.productNameById(voucher.productId);
  }

  bool canRate(VoucherModel voucher) {
    return voucher.isRedeemed;
  }

  int ratingFor(String voucherId) {
    return voucherRatings[voucherId] ?? 0;
  }

  void rateVoucher(String voucherId, int rating) {
    voucherRatings[voucherId] = rating;
    voucherRatings.refresh();
  }
}
