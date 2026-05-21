import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/auth_service.dart';

class CustomerHistoryController extends GetxController {
  final RxList<VoucherModel> customerVouchers = <VoucherModel>[].obs;
  final RxMap<String, int> voucherRatings = <String, int>{}.obs;
  final RxString walletCode = ''.obs;
  final RxString walletStatus = 'Activa'.obs;
  final RxBool loadingWallet = true.obs;
  final RxBool loadingHistory = false.obs;

  final Rxn<OrdersPage> ordersPage = Rxn<OrdersPage>();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool loadingOrders = false.obs;
  final RxBool loadingMoreOrders = false.obs;
  static const int _ordersPageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
    _loadCustomerHistory();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    loadingOrders.value = true;
    try {
      final page = await MarketplaceRepository.instance
          .fetchOrders(page: 1, pageSize: _ordersPageSize);
      ordersPage.value = page;
      orders.assignAll(page.data);
    } catch (_) {
      ordersPage.value = null;
      orders.clear();
    } finally {
      loadingOrders.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    final current = ordersPage.value;
    if (current == null) return;
    if (loadingOrders.value || loadingMoreOrders.value) return;
    if (!current.meta.hasMore) return;
    loadingMoreOrders.value = true;
    try {
      final next = await MarketplaceRepository.instance.fetchOrders(
        page: current.meta.page + 1,
        pageSize: _ordersPageSize,
      );
      orders.addAll(next.data);
      ordersPage.value = next;
    } catch (_) {
      // mantiene la página actual
    } finally {
      loadingMoreOrders.value = false;
    }
  }

  Future<void> _loadWalletData() async {
    loadingWallet.value = true;
    final card = await AuthService.fetchAssignedVirtualCard();
    walletCode.value =
        (card['number'] ?? '0000 0000 0000 0000').replaceAll(' ', '');
    walletStatus.value = 'Activa';
    loadingWallet.value = false;
  }

  /// Trae los vouchers del usuario desde GET /api/v1/marketplace/vouchers/.
  /// Si falla, hace fallback a los vouchers locales (DummyHelper).
  Future<void> _loadCustomerHistory() async {
    loadingHistory.value = true;
    try {
      final remote = await MarketplaceRepository.instance.fetchVouchers();
      customerVouchers.assignAll(remote);
      return;
    } catch (_) {
      // continua con fallback
    } finally {
      loadingHistory.value = false;
    }

    final userEmail =
        AuthService.currentUserEmail ?? 'cliente@marketplace.com';
    final customerId = DummyHelper.customerIdForEmail(userEmail);
    final values = DummyHelper.vouchers
        .where((voucher) => voucher.customerUserId == customerId)
        .toList();

    if (values.isEmpty) {
      final fallbackCustomerId =
          DummyHelper.customerIdForEmail('cliente@marketplace.com');
      customerVouchers.assignAll(
        DummyHelper.vouchers
            .where(
              (voucher) => voucher.customerUserId == fallbackCustomerId,
            )
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
    final expiredByDate = voucher.expiresAt != null &&
        voucher.expiresAt!.isBefore(DateTime.now());
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
    return voucher.productName ?? DummyHelper.productNameById(voucher.productId);
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
