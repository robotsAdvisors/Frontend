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
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMoreVouchers = false.obs;
  final Rx<PageMeta> vouchersMeta = const PageMeta().obs;

  final _repo = MarketplaceRepository.instance;

  @override
  void onInit() {
    super.onInit();
    _bootstrapFromDummy();
    _loadFromBackend();
  }

  void _bootstrapFromDummy() {
    final email = AuthService.currentUserEmail ?? '';
    storeId.value = DummyHelper.storeIdForAdminEmail(email) ?? '';
    currentStore = DummyHelper.stores.firstWhere(
      (store) => store.id == storeId.value,
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
      // El backend aun no expone "tienda asignada al usuario admin",
      // asi que cogemos la primera (o la que coincida en nombre con la dummy).
      final remoteStores = await _repo.fetchStores();
      if (remoteStores.isNotEmpty) {
        final email = AuthService.currentUserEmail ?? '';
        final dummyName = currentStore.name.toLowerCase();
        final picked = remoteStores.firstWhere(
          (s) => s.name.toLowerCase() == dummyName,
          orElse: () => remoteStores.first,
        );
        storeId.value = picked.id;
        currentStore = StoreModel(
          id: picked.id,
          name: picked.name,
          description: picked.description,
          ownerId: picked.ownerId,
          ownerEmail: email.isNotEmpty ? email : picked.ownerEmail,
          adminUserIds: picked.adminUserIds,
          fiscalId: picked.fiscalId,
          address: picked.address,
          logoUrl: picked.logoUrl.isNotEmpty ? picked.logoUrl : currentStore.logoUrl,
          billingEmail: email.isNotEmpty ? email : picked.billingEmail,
          billingPhone: picked.billingPhone,
          pin: picked.pin,
          createdAt: picked.createdAt,
          banner: picked.banner,
          email: picked.email,
          website: picked.website,
          openingHours: picked.openingHours,
          isPublished: picked.isPublished,
          categories: picked.categories,
        );
      }

      final results = await Future.wait<dynamic>([
        _repo.fetchProducts(storeId: storeId.value),
        _repo.fetchVouchersPage(page: 1, pageSize: _vouchersPageSize),
      ]);

      final remoteProducts = results[0] as List<ProductModel>;
      final vouchersPage = results[1] as Paginated<VoucherModel>;
      if (remoteProducts.isNotEmpty) products.assignAll(remoteProducts);
      vouchersMeta.value = vouchersPage.meta;
      vouchers.assignAll(
        vouchersPage.data
            .where((v) => v.storeId.isEmpty || v.storeId == storeId.value)
            .toList(),
      );
      _calculateStoreMetrics();
    } catch (_) {
      // Silencio: ya se muestran los datos dummy.
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStoreMetrics() {
    totalProducts.value = products.length;
    totalStock.value = products.fold<int>(0, (sum, item) => sum + item.quantity);
    averagePrice.value = products.isNotEmpty
        ? products.fold<double>(0.0, (sum, item) => sum + item.discountPrice) /
            products.length
        : 0.0;
  }

  /// Carga la siguiente página de vouchers desde el backend y la concatena
  /// (filtrada por la tienda actual) a la lista en memoria.
  Future<void> loadMoreVouchers() async {
    if (isLoadingMoreVouchers.value) return;
    if (!vouchersMeta.value.hasMore) return;
    isLoadingMoreVouchers.value = true;
    try {
      final next = vouchersMeta.value.page + 1;
      final page = await _repo.fetchVouchersPage(
        page: next,
        pageSize: _vouchersPageSize,
      );
      vouchersMeta.value = page.meta;
      vouchers.addAll(
        page.data
            .where((v) => v.storeId.isEmpty || v.storeId == storeId.value),
      );
    } catch (_) {
      // Silencio: el usuario puede reintentar.
    } finally {
      isLoadingMoreVouchers.value = false;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    // Optimistic add local para no romper la UX.
    products.add(product);
    _calculateStoreMetrics();

    try {
      final payload = <String, dynamic>{
        'store': storeId.value.isEmpty ? null : storeId.value,
        'name': product.name,
        'description': product.description,
        'image_url':
            product.image.startsWith('http') ? product.image : null,
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
          message: 'El producto se guardo en el backend.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'No se pudo persistir',
        message: e.message,
      );
    } catch (_) {
      // Sin conexion: queda solo local.
    }
  }

  void deleteProduct(ProductModel product) {
    // El backend aun no expone DELETE /admin/products/{id}/.
    products.remove(product);
    _calculateStoreMetrics();
  }

  List<VoucherModel> get recentValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return vouchers
        .where((v) =>
            v.createdAt.isAfter(cutoff) && !v.isRedeemed && !v.isExpired)
        .toList();
  }

  List<VoucherModel> get lastMonthValidVouchers {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return vouchers
        .where((v) =>
            v.createdAt.isAfter(cutoff) && !v.isRedeemed && !v.isExpired)
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

  String customerNameFor(VoucherModel voucher) =>
      DummyHelper.customerNameById(voucher.customerUserId);

  String customerEmailFor(VoucherModel voucher) =>
      DummyHelper.customerEmailById(voucher.customerUserId);

  String productNameFor(VoucherModel voucher) {
    if (voucher.productName != null && voucher.productName!.isNotEmpty) {
      return voucher.productName!;
    }
    return DummyHelper.productNameById(voucher.productId);
  }

  /// Valida un voucher contra el backend (POST /vouchers/validate/).
  Future<bool> validateVoucherCode(String code) async {
    try {
      final result = await _repo.validateVoucher(code);
      if (result != null) {
        await _loadFromBackend();
        CustomSnackBar.showCustomSnackBar(
          title: 'Voucher valido',
          message: 'El voucher fue canjeado correctamente.',
        );
        return true;
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Voucher invalido',
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

