import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
  final RxList<Map<String, dynamic>> remoteActivity = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>> monthlyGoal = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> storePinData = Rx<Map<String, dynamic>>({});
  final RxString regeneratedPin = ''.obs;
  final RxBool isRegeneratingPin = false.obs;
  final RxList<Map<String, dynamic>> securityLog = <Map<String, dynamic>>[].obs;

  // Inventory (paginated, separate from the preloaded product list)
  final RxList<ProductModel> inventoryProducts = <ProductModel>[].obs;
  final Rx<PageMeta> inventoryMeta = const PageMeta().obs;
  final RxInt inventoryCurrentPage = 1.obs;
  final RxBool isLoadingInventory = false.obs;

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

      // 2. Cargar productos, vouchers, categorias, analytics, actividad y meta mensual en paralelo.
      final results = await Future.wait<dynamic>([
        _repo.fetchProducts(storeId: storeId.value),
        _repo.fetchVouchersPage(page: 1, pageSize: _vouchersPageSize),
        _repo.fetchCategories().catchError((_) => <CategoryModel>[]),
        _repo.fetchAnalyticsVouchersDaily(storeId.value)
            .catchError((_) => <Map<String, dynamic>>[]),
        _repo.fetchAnalyticsSummary(storeId.value)
            .catchError((_) => <String, dynamic>{}),
        _repo.fetchStoreActivity(storeId.value)
            .catchError((_) => <Map<String, dynamic>>[]),
        _repo.fetchMonthlyGoal(storeId.value)
            .catchError((_) => <String, dynamic>{}),
        _repo.fetchStorePIN(storeId.value)
            .catchError((_) => <String, dynamic>{}),
        _repo.fetchSecurityLog(storeId.value)
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);

      final remoteProducts = results[0] as List<ProductModel>;
      final vouchersPage = results[1] as Paginated<VoucherModel>;
      final remoteCategories = results[2] as List<CategoryModel>;
      final remoteDailyVouchers = results[3] as List<Map<String, dynamic>>;
      final remoteSummary = results[4] as Map<String, dynamic>;
      final remoteActivityList = results[5] as List<Map<String, dynamic>>;
      final remoteMonthlyGoal = results[6] as Map<String, dynamic>;
      final remotePinData = results[7] as Map<String, dynamic>;
      final remoteSecurityLog = results[8] as List<Map<String, dynamic>>;

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
      if (remoteActivityList.isNotEmpty) remoteActivity.assignAll(remoteActivityList);
      if (remoteMonthlyGoal.isNotEmpty) monthlyGoal.value = remoteMonthlyGoal;
      if (remotePinData.isNotEmpty) storePinData.value = remotePinData;
      if (remoteSecurityLog.isNotEmpty) securityLog.assignAll(remoteSecurityLog);

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

  // ── Inventory stats ───────────────────────────────────────────────────────

  int get lowStockCount =>
      products.where((p) => p.quantity > 0 && p.quantity < 10).length;

  int get expiringSoonCount => products.where((p) => p.isExpiringSoon).length;

  int get activeCategoriesCount => categories.length;

  /// Carga una página paginada del inventario (con búsqueda opcional).
  Future<void> loadInventoryPage({
    int page = 1,
    String search = '',
    String? category,
  }) async {
    if (isLoadingInventory.value) return;
    isLoadingInventory.value = true;
    try {
      final result = await _repo.fetchProductsPage(
        storeId: storeId.value,
        page: page,
        pageSize: 10,
        search: search.isNotEmpty ? search : null,
        categoryName: category,
      );
      inventoryProducts.assignAll(result.data);
      inventoryMeta.value = result.meta;
      inventoryCurrentPage.value = page;
    } catch (_) {
      // Si falla, usar los productos ya cargados en memoria
      final all = products.where((p) {
        if (search.isNotEmpty &&
            !p.name.toLowerCase().contains(search.toLowerCase()) &&
            !p.sku.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
        if (category != null && category.isNotEmpty && p.category != category) {
          return false;
        }
        return true;
      }).toList();
      final start = (page - 1) * 10;
      final end = (start + 10).clamp(0, all.length);
      inventoryProducts.assignAll(
          start < all.length ? all.sublist(start, end) : []);
      inventoryMeta.value = PageMeta(
          total: all.length,
          page: page,
          lastPage: (all.length / 10).ceil().clamp(1, 9999));
      inventoryCurrentPage.value = page;
    } finally {
      isLoadingInventory.value = false;
    }
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

  // ── Dashboard stats ──────────────────────────────────────────────────────

  // Prefer backend analytics; fall back to local voucher list.
  int get pendingCount {
    final summary = analyticsSummary.value;
    if (summary['pending_vouchers'] != null) {
      return (summary['pending_vouchers'] as num).toInt();
    }
    return vouchers
        .where((v) =>
            v.status == VoucherStatus.pending || v.status == VoucherStatus.paid)
        .length;
  }

  int get completedTodayCount {
    final summary = analyticsSummary.value;
    if (summary['completed_today'] != null) {
      return (summary['completed_today'] as num).toInt();
    }
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    return vouchers.where((v) => v.isRedeemed && v.issuedAt.isAfter(dayStart)).length;
  }

  int get completedMonthCount {
    final summary = analyticsSummary.value;
    if (summary['completed_this_month'] != null) {
      return (summary['completed_this_month'] as num).toInt();
    }
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return vouchers.where((v) => v.isRedeemed && v.issuedAt.isAfter(monthStart)).length;
  }

  int get expiredCount => vouchers.where((v) => v.isExpired && !v.isRedeemed).length;

  int get activePrizesCount {
    final summary = analyticsSummary.value;
    if (summary['active_products'] != null) {
      return (summary['active_products'] as num).toInt();
    }
    return products.where((p) => p.quantity > 0).length;
  }

  int get availablePoints {
    final summary = analyticsSummary.value;
    if (summary['available_points'] != null) {
      return (summary['available_points'] as num).toInt();
    }
    return 0;
  }

  String get storeCardId {
    // Prefer the stable ID returned by GET /stores/<id>/
    if (currentStore.cardId.isNotEmpty) return currentStore.cardId;
    // Fallback: derive from store UUID until backend field is available
    final id = storeId.value.replaceAll('-', '').toUpperCase();
    final part = id.length >= 4 ? id.substring(0, 4) : id.padRight(4, '0');
    return 'TIENDA-$part-X';
  }

  int get accumulatedPoints {
    final summary = analyticsSummary.value;
    if (summary['total_points_accumulated'] != null) {
      return (summary['total_points_accumulated'] as num).toInt();
    }
    return vouchers.fold<int>(0, (sum, v) => sum + v.pointsUsed);
  }

  List<VoucherModel> get recentCanjes {
    final sorted = [...vouchers]
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return sorted.take(10).toList();
  }

  List<Map<String, dynamic>> get activityFeed {
    // Prefer real backend events from GET /stores/<id>/activity/
    if (remoteActivity.isNotEmpty) {
      return remoteActivity.map(_normalizeActivityEvent).toList();
    }
    // Fallback: derive activity locally while backend data is unavailable
    return _derivedActivityFeed();
  }

  Map<String, dynamic> _normalizeActivityEvent(Map<String, dynamic> event) {
    final type = (event['type'] ?? '').toString();
    final title = (event['title'] ?? '').toString();
    final description = (event['description'] ?? event['body'] ?? '').toString();
    final ts = event['timestamp'] ?? event['created_at'];
    final timeLabel = ts != null ? _relativeTime(DateTime.tryParse(ts.toString())) : '';

    String color;
    switch (type) {
      case 'voucher_redeemed':
      case 'redemption':
        color = 'green';
        break;
      case 'voucher_created':
      case 'product_added':
        color = 'orange';
        break;
      case 'low_stock':
        color = 'red';
        break;
      case 'system_update':
        color = 'grey';
        break;
      default:
        color = 'purple';
    }

    return {
      'title': title,
      'body': description,
      'time': timeLabel,
      'color': color,
      'action_label': (event['action_label'] ?? '').toString(),
      'action_route': (event['action_route'] ?? '').toString(),
    };
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    return 'Hace ${diff.inDays} días';
  }

  List<Map<String, dynamic>> _derivedActivityFeed() {
    final items = <Map<String, dynamic>>[];

    final redeemed = redeemedVouchers;
    if (redeemed.length >= 10) {
      final milestone = (redeemed.length ~/ 10) * 10;
      items.add({
        'title': 'Nueva meta alcanzada',
        'body': 'Tienda superó los $milestone canjes totales.',
        'time': 'Reciente',
        'color': 'purple',
      });
    }

    if (vouchers.isNotEmpty) {
      final countByProduct = <String, int>{};
      for (final v in vouchers) {
        countByProduct[v.productId] = (countByProduct[v.productId] ?? 0) + 1;
      }
      final topEntry =
          countByProduct.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topVoucher = vouchers.firstWhere(
        (v) => v.productId == topEntry.key,
        orElse: () => vouchers.first,
      );
      final name = productNameFor(topVoucher);
      items.add({
        'title': 'Premio destacado',
        'body': "'$name' es el más canjeado esta semana.",
        'time': 'Hace 2 horas',
        'color': 'orange',
      });
    }

    final lowStock =
        products.where((p) => p.quantity > 0 && p.quantity < 5).toList();
    if (lowStock.isNotEmpty) {
      final prod = lowStock.first;
      items.add({
        'title': 'Alerta de stock',
        'body': '${prod.name} (${prod.quantity} unidades restantes).',
        'time': 'Hace 4 horas',
        'color': 'red',
      });
    }

    return items;
  }

  // ─────────────────────────────────────────────────────────────────────────

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

  // ── Monthly loyalty goal ──────────────────────────────────────────────────
  // Backend: GET /marketplace/stores/<id>/monthly-goal/
  // Expected fields: monthly_goal_current, monthly_goal_target,
  //                  monthly_goal_days_remaining, monthly_goal_prize

  int get monthlyGoalCurrentPts {
    final g = monthlyGoal.value;
    if (g['monthly_goal_current'] != null) {
      return (g['monthly_goal_current'] as num).toInt();
    }
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return vouchers
        .where((v) => v.isRedeemed && v.issuedAt.isAfter(monthStart))
        .fold<int>(0, (sum, v) => sum + v.pointsUsed);
  }

  int get monthlyGoalTargetPts {
    final g = monthlyGoal.value;
    if (g['monthly_goal_target'] != null) {
      return (g['monthly_goal_target'] as num).toInt();
    }
    return 500000;
  }

  int get monthlyGoalDaysRemaining {
    final g = monthlyGoal.value;
    if (g['monthly_goal_days_remaining'] != null) {
      return (g['monthly_goal_days_remaining'] as num).toInt();
    }
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }

  String get monthlyGoalPrizeName {
    final g = monthlyGoal.value;
    return g['monthly_goal_prize']?.toString() ?? '';
  }

  double get monthlyGoalPercent {
    final target = monthlyGoalTargetPts;
    if (target == 0) return 0;
    return (monthlyGoalCurrentPts / target).clamp(0.0, 1.0);
  }

  int get maxProductQuantity {
    if (products.isEmpty) return 1;
    return products.map((p) => p.quantity).reduce((a, b) => a > b ? a : b);
  }

  /// Descarga el inventario como CSV.
  /// GET /marketplace/admin/products/export/?store={id}&format=csv
  final RxBool isExportingCsv = false.obs;

  Future<void> exportInventoryCsv() async {
    if (isExportingCsv.value) return;
    isExportingCsv.value = true;
    try {
      final bytes = await _repo.exportProductsCsv(storeId.value);
      if (bytes.isEmpty) {
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Sin datos',
          message: 'El servidor devolvió un archivo vacío.',
        );
        return;
      }

      final filename = 'productos_tienda_${storeId.value}.csv';
      final file = await _resolveDownloadFile(filename);
      await file.writeAsBytes(bytes, flush: true);

      CustomSnackBar.showCustomSnackBar(
        title: 'CSV exportado',
        message: 'Guardado en ${file.path}',
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al exportar',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al exportar',
        message: 'No se pudo guardar el archivo.',
      );
    } finally {
      isExportingCsv.value = false;
    }
  }

  Future<File> _resolveDownloadFile(String filename) async {
    if (Platform.isAndroid) {
      // Standard public Downloads folder — works without extra permissions
      // on most Android versions when requestLegacyExternalStorage is set.
      final dir = Directory('/storage/emulated/0/Download');
      if (dir.existsSync()) {
        return File('${dir.path}/$filename');
      }
    }
    // Fallback: app-private temp dir (no extra permissions needed on any OS).
    return File('${Directory.systemTemp.path}/$filename');
  }

  /// Sube una imagen al backend y devuelve la URL resultante.
  /// POST /marketplace/admin/products/upload-image/
  Future<String?> uploadProductImage(XFile file) async {
    try {
      return await _repo.uploadProductImage(file);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al subir imagen',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'No se pudo subir la imagen.',
      );
    }
    return null;
  }

  /// Alterna el estado publicado/pausado de un producto.
  Future<void> toggleProductPublished(ProductModel product) async {
    final newState = !product.isPublished;
    final idx = products.indexWhere((p) => p.id == product.id);
    // Optimistic update
    if (idx != -1) {
      products[idx].isPublished = newState;
      products.refresh();
    }
    final invIdx = inventoryProducts.indexWhere((p) => p.id == product.id);
    if (invIdx != -1) {
      inventoryProducts[invIdx].isPublished = newState;
      inventoryProducts.refresh();
    }
    try {
      await _repo.adminUpdateProduct(
          product.id, {'is_published': newState});
    } on ApiException catch (e) {
      // Revert on failure
      if (idx != -1) { products[idx].isPublished = !newState; products.refresh(); }
      if (invIdx != -1) { inventoryProducts[invIdx].isPublished = !newState; inventoryProducts.refresh(); }
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error', message: e.message);
    } catch (_) {
      if (idx != -1) { products[idx].isPublished = !newState; products.refresh(); }
      if (invIdx != -1) { inventoryProducts[invIdx].isPublished = !newState; inventoryProducts.refresh(); }
    }
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

  // ── PIN ───────────────────────────────────────────────────────────────────

  String get pinMasked =>
      storePinData.value['pin_masked']?.toString() ?? '●●●●●●';

  bool get pinConfigured =>
      storePinData.value['pin_configured'] as bool? ?? false;

  Future<void> regeneratePin() async {
    if (isRegeneratingPin.value) return;
    isRegeneratingPin.value = true;
    try {
      final result = await _repo.regenerateStorePIN(storeId.value);
      if (result.isNotEmpty) {
        storePinData.value = result;
        regeneratedPin.value = result['pin']?.toString() ?? '';
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error', message: 'No se pudo regenerar el PIN.');
    } finally {
      isRegeneratingPin.value = false;
    }
  }

  void clearRegeneratedPin() => regeneratedPin.value = '';

  // ── Settings ──────────────────────────────────────────────────────────────

  final RxBool isSavingSettings = false.obs;

  /// Recarga la lista de usuarios desde el backend.
  Future<void> reloadStoreUsers() async {
    try {
      final users = await _repo.fetchStoreUsers(storeId.value);
      if (users.isNotEmpty) storeUsers.assignAll(users);
    } catch (_) {}
  }

  /// PATCH /marketplace/stores/<id>/ — persiste cambios de la tienda.
  Future<bool> saveStoreSettings(Map<String, dynamic> payload) async {
    if (isSavingSettings.value) return false;
    isSavingSettings.value = true;
    try {
      final updated = await _repo.updateStore(storeId.value, payload);
      if (updated != null) {
        currentStore = updated;
        storeId.value = updated.id;
        CustomSnackBar.showCustomSnackBar(
          title: 'Guardado',
          message: 'Los cambios se guardaron correctamente.',
        );
        return true;
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al guardar',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'No se pudieron guardar los cambios.',
      );
    } finally {
      isSavingSettings.value = false;
    }
    return false;
  }

  /// Invita a un nuevo usuario a la tienda.
  Future<bool> inviteUser(String email, String role) async {
    try {
      await _repo.inviteStoreUser(storeId.value, email, role);
      await reloadStoreUsers();
      CustomSnackBar.showCustomSnackBar(
        title: 'Invitación enviada',
        message: 'Se envió la invitación a $email.',
      );
      return true;
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {}
    return false;
  }

  /// Elimina un usuario de la tienda.
  Future<void> removeUser(String userId) async {
    try {
      await _repo.removeStoreUser(storeId.value, userId);
      storeUsers.removeWhere((u) => u.id == userId);
      CustomSnackBar.showCustomSnackBar(
        title: 'Usuario eliminado',
        message: 'El usuario fue removido de la tienda.',
      );
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {}
  }

  /// Actualiza el rol de un usuario.
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _repo.updateStoreUserRole(storeId.value, userId, role);
      await reloadStoreUsers();
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {}
  }

  /// Cambia el PIN de la tienda.
  Future<bool> changePin(String currentPin, String newPin) async {
    try {
      await _repo.changeStorePin(storeId.value, currentPin, newPin);
      CustomSnackBar.showCustomSnackBar(
        title: 'PIN actualizado',
        message: 'El PIN de la tienda fue cambiado correctamente.',
      );
      return true;
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {}
    return false;
  }

  /// Activa o desactiva el doble factor de autenticación.
  Future<void> toggleTwoFactor(bool enabled) async {
    try {
      await _repo.updateStoreSecurity(storeId.value, twoFactorEnabled: enabled);
      currentStore = StoreModel(
        id: currentStore.id,
        name: currentStore.name,
        description: currentStore.description,
        ownerId: currentStore.ownerId,
        ownerEmail: currentStore.ownerEmail,
        ownerName: currentStore.ownerName,
        adminUserIds: currentStore.adminUserIds,
        fiscalId: currentStore.fiscalId,
        address: currentStore.address,
        logoUrl: currentStore.logoUrl,
        billingEmail: currentStore.billingEmail,
        billingPhone: currentStore.billingPhone,
        pin: currentStore.pin,
        createdAt: currentStore.createdAt,
        banner: currentStore.banner,
        email: currentStore.email,
        website: currentStore.website,
        openingHours: currentStore.openingHours,
        isPublished: currentStore.isPublished,
        categories: currentStore.categories,
        rating: currentStore.rating,
        reviewCount: currentStore.reviewCount,
        cardId: currentStore.cardId,
        latitude: currentStore.latitude,
        longitude: currentStore.longitude,
        billingAddress: currentStore.billingAddress,
        twoFactorEnabled: enabled,
      );
      storeId.refresh();
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {}
  }
}
