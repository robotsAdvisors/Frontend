import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/paginated.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/http/api_client.dart';

class AdminController extends GetxController {
  static const int _vouchersPageSize = 20;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<StoreUserModel> storeUsers = <StoreUserModel>[].obs;
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxSet<String> favoriteVoucherIds = <String>{}.obs;
  late StoreModel currentStore;
  final RxInt totalProducts = 0.obs;
  final RxInt totalStock = 0.obs;
  final RxDouble averagePrice = 0.0.obs;
  final RxString storeId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMoreVouchers = false.obs;
  final Rx<PageMeta> vouchersMeta = const PageMeta().obs;

  final _repo = MarketplaceRepository.instance;

  @override
  void onInit() {
    super.onInit();
    _bootstrapFromDummy();
    _loadFromBackend();
  }

  // Muestra datos dummy instantáneamente mientras carga el backend.
  void _bootstrapFromDummy() {
    final email = AuthService.currentUserEmail ?? '';
    final resolvedId = DummyHelper.storeIdForAdminEmail(email);
    storeId.value = resolvedId ?? DummyHelper.stores.first.id;
    currentStore = DummyHelper.stores.firstWhere(
      (s) => s.id == storeId.value,
      orElse: () => DummyHelper.stores.first,
    );
    products.assignAll(
      DummyHelper.products.where((p) => p.storeId == currentStore.id).toList(),
    );
    storeUsers.assignAll(
      DummyHelper.storeUsers.where((u) => u.storeId == currentStore.id).toList(),
    );
    vouchers.assignAll(
      DummyHelper.vouchers.where((v) => v.storeId == currentStore.id).toList(),
    );
    _calculateStoreMetrics();
  }

  Future<void> _loadFromBackend() async {
    isLoading.value = true;
    try {
      final email = (AuthService.currentUserEmail ?? '').toLowerCase();

      // 1. Encontrar la tienda del admin logueado.
      final stores = await _repo.fetchStores();
      if (stores.isNotEmpty) {
        final picked = stores.firstWhere(
          (s) =>
              s.ownerEmail.toLowerCase() == email ||
              s.email.toLowerCase() == email,
          orElse: () => stores.first,
        );
        currentStore = picked;
        storeId.value = picked.id;
      }

      // 2. Cargar productos y vouchers en paralelo.
      final results = await Future.wait<dynamic>([
        _repo.fetchProducts(storeId: storeId.value),
        _repo.fetchVouchersPage(page: 1, pageSize: _vouchersPageSize),
      ]);

      final remoteProducts = results[0] as List<ProductModel>;
      final vouchersPage = results[1] as Paginated<VoucherModel>;

      products.assignAll(remoteProducts);

      vouchersMeta.value = vouchersPage.meta;
      vouchers.assignAll(
        vouchersPage.data
            .where((v) => v.storeId.isEmpty || v.storeId == storeId.value)
            .toList(),
      );

      _calculateStoreMetrics();
    } catch (_) {
      // Silencio: se mantienen los datos dummy.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreVouchers() async {
    if (isLoadingMoreVouchers.value || !vouchersMeta.value.hasMore) return;
    isLoadingMoreVouchers.value = true;
    try {
      final next = vouchersMeta.value.page + 1;
      final page = await _repo.fetchVouchersPage(
        page: next,
        pageSize: _vouchersPageSize,
      );
      vouchersMeta.value = page.meta;
      vouchers.addAll(
        page.data.where((v) => v.storeId.isEmpty || v.storeId == storeId.value),
      );
    } catch (_) {
      // El usuario puede reintentar.
    } finally {
      isLoadingMoreVouchers.value = false;
    }
  }

  void _calculateStoreMetrics() {
    totalProducts.value = products.length;
    totalStock.value = products.fold<int>(0, (sum, p) => sum + p.quantity);
    averagePrice.value = products.isNotEmpty
        ? products.fold<double>(0.0, (sum, p) => sum + p.discountPrice) /
            products.length
        : 0.0;
  }

  Future<void> addProduct(ProductModel product) async {
    products.add(product);
    _calculateStoreMetrics();

    try {
      final payload = <String, dynamic>{
        'store': storeId.value.isEmpty ? null : storeId.value,
        'name': product.name,
        'description': product.description,
        'image_url': product.image.startsWith('http') ? product.image : null,
        'price': product.originalPrice,
        'discount': product.discountPercent,
        'stock': product.stock > 0 ? product.stock : product.quantity,
      }..removeWhere((_, v) => v == null);

      final created = await _repo.adminCreateProduct(payload);
      if (created != null) {
        final idx = products.indexOf(product);
        if (idx != -1) {
          products[idx] = ProductModel.fromJson(created);
          _calculateStoreMetrics();
        }
        CustomSnackBar.showCustomSnackBar(
          title: 'Producto creado',
          message: 'El producto se guardó en el backend.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'No se pudo persistir',
        message: e.message,
      );
    } catch (_) {}
  }

  void deleteProduct(ProductModel product) {
    products.remove(product);
    _calculateStoreMetrics();
  }

  List<VoucherModel> get recentValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return vouchers
        .where((v) => v.createdAt.isAfter(cutoff) && !v.isRedeemed && !v.isExpired)
        .toList();
  }

  List<VoucherModel> get lastMonthValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return vouchers
        .where((v) => v.createdAt.isAfter(cutoff) && !v.isRedeemed && !v.isExpired)
        .toList();
  }

  List<VoucherModel> get redeemedVouchers =>
      vouchers.where((v) => v.isRedeemed).toList();

  List<VoucherModel> get expiredUnredeemedVouchers =>
      vouchers.where((v) => v.isExpired && !v.isRedeemed).toList();

  List<VoucherModel> get favoriteVouchers =>
      vouchers.where((v) => favoriteVoucherIds.contains(v.id)).toList();

  bool isFavorite(String voucherId) => favoriteVoucherIds.contains(voucherId);

  void toggleFavorite(String voucherId) {
    if (favoriteVoucherIds.contains(voucherId)) {
      favoriteVoucherIds.remove(voucherId);
    } else {
      favoriteVoucherIds.add(voucherId);
    }
  }

  // Usa datos embebidos del backend; solo cae a dummy si están vacíos.
  String customerNameFor(VoucherModel voucher) {
    final name = voucher.customerName;
    if (name != null && name.isNotEmpty) return name;
    final email = voucher.customerEmail;
    if (email != null && email.isNotEmpty) return email;
    return DummyHelper.customerNameById(voucher.customerUserId);
  }

  String customerEmailFor(VoucherModel voucher) {
    final email = voucher.customerEmail;
    if (email != null && email.isNotEmpty) return email;
    return DummyHelper.customerEmailById(voucher.customerUserId);
  }

  String productNameFor(VoucherModel voucher) {
    if (voucher.productName != null && voucher.productName!.isNotEmpty) {
      return voucher.productName!;
    }
    return DummyHelper.productNameById(voucher.productId);
  }

  Future<bool> validateVoucherCode(String code) async {
    try {
      final result = await _repo.validateVoucher(code);
      if (result != null) {
        await _loadFromBackend();
        CustomSnackBar.showCustomSnackBar(
          title: 'Voucher válido',
          message: 'El voucher fue canjeado correctamente.',
        );
        return true;
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Voucher inválido',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'No fue posible validar el voucher.',
      );
    }
    return false;
  }
}
