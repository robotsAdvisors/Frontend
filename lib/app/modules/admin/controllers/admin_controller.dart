import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/category_model.dart';
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
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxSet<String> favoriteVoucherIds = <String>{}.obs;
  late StoreModel currentStore;
  final RxInt totalProducts = 0.obs;
  final RxInt totalStock = 0.obs;
  final RxDouble averagePrice = 0.0.obs;
  final RxDouble storeRating = 0.0.obs;
  final RxInt storeReviewCount = 0.obs;
  final RxString storeId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMoreVouchers = false.obs;
  final Rx<PageMeta> vouchersMeta = const PageMeta().obs;
  final RxList<Map<String, dynamic>> dailyVouchers = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>> analyticsSummary = Rx<Map<String, dynamic>>({});

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

  List<String> get categoryNames =>
      categories.map((c) => c.title).where((t) => t.isNotEmpty).toList();

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
        storeRating.value = picked.rating;
        storeReviewCount.value = picked.reviewCount;
      }

      // 2. Cargar productos, vouchers, categorias y analytics en paralelo.
      final results = await Future.wait<dynamic>([
        _repo.fetchProducts(storeId: storeId.value),
        _repo.fetchVouchersPage(page: 1, pageSize: _vouchersPageSize),
        _repo.fetchCategories().catchError((_) => <CategoryModel>[]),
        _repo.fetchAnalyticsVouchersDaily(storeId.value)
            .catchError((_) => <Map<String, dynamic>>[]),
        _repo.fetchAnalyticsSummary(storeId.value)
            .catchError((_) => <String, dynamic>{}),
      ]);

      final remoteProducts = results[0] as List<ProductModel>;
      final vouchersPage = results[1] as Paginated<VoucherModel>;
      final remoteCategories = results[2] as List<CategoryModel>;
      final remoteDailyVouchers = results[3] as List<Map<String, dynamic>>;
      final remoteSummary = results[4] as Map<String, dynamic>;

      products.assignAll(remoteProducts);

      vouchersMeta.value = vouchersPage.meta;
      vouchers.assignAll(
        vouchersPage.data
            .where((v) => v.storeId.isEmpty || v.storeId == storeId.value)
            .toList(),
      );

      if (remoteCategories.isNotEmpty) categories.assignAll(remoteCategories);
      if (remoteDailyVouchers.isNotEmpty) dailyVouchers.assignAll(remoteDailyVouchers);
      if (remoteSummary.isNotEmpty) analyticsSummary.value = remoteSummary;

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
        if (product.category.isNotEmpty) 'category': product.category,
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

  Future<void> deleteProduct(ProductModel product) async {
    final index = products.indexOf(product);
    products.remove(product);
    _calculateStoreMetrics();
    try {
      await _repo.adminDeleteProduct(product.id);
      CustomSnackBar.showCustomSnackBar(
        title: 'Producto eliminado',
        message: 'El producto fue eliminado correctamente.',
      );
    } on ApiException catch (e) {
      if (index != -1) { products.insert(index, product); } else { products.add(product); }
      _calculateStoreMetrics();
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al eliminar',
        message: e.message,
      );
    } catch (_) {
      if (index != -1) { products.insert(index, product); } else { products.add(product); }
      _calculateStoreMetrics();
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> payload) async {
    try {
      final updated = await _repo.adminUpdateProduct(productId, payload);
      if (updated != null) {
        final idx = products.indexWhere((p) => p.id == productId);
        if (idx != -1) {
          products[idx] = ProductModel.fromJson(updated);
          _calculateStoreMetrics();
        }
        CustomSnackBar.showCustomSnackBar(
          title: 'Producto actualizado',
          message: 'Los cambios se guardaron correctamente.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al actualizar',
        message: e.message,
      );
    } catch (_) {}
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

  double get redemptionsGrowthPercent {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final thisMonth = vouchers
        .where((v) => v.isRedeemed && v.createdAt.isAfter(thisMonthStart))
        .length;
    final lastMonth = vouchers
        .where((v) =>
            v.isRedeemed &&
            v.createdAt.isAfter(lastMonthStart) &&
            v.createdAt.isBefore(thisMonthStart))
        .length;
    if (lastMonth == 0) return thisMonth > 0 ? 100.0 : 0.0;
    return ((thisMonth - lastMonth) / lastMonth) * 100.0;
  }

  String get storeTier {
    final count = vouchers.length;
    if (count >= 200) return 'Gold';
    if (count >= 50) return 'Silver';
    return 'Bronze';
  }

  int get maxProductQuantity {
    if (products.isEmpty) return 1;
    return products.map((p) => p.quantity).reduce((a, b) => a > b ? a : b);
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
