import 'dart:math';

import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/http/api_client.dart';

class GeneralAdminController extends GetxController {
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxList<StoreUserModel> storeUsers = <StoreUserModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Métricas globales
  final RxInt totalStores = 0.obs;
  final RxInt totalStoreUsers = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalRedemptions = 0.obs;
  final RxInt totalPointsPts = 0.obs;
  final RxMap<String, int> storeRevenue = <String, int>{}.obs;

  // Crecimiento
  final RxDouble storesGrowthPercent = 0.0.obs;
  final RxDouble usersGrowthPercent = 0.0.obs;

  // Permisos del sistema
  final RxInt superAdminCount = 0.obs;
  final RxInt supportTeamCount = 0.obs;
  final RxInt securityCompliance = 0.obs;

  // Network Growth chart
  final RxMap<String, List<int>> networkGrowth = <String, List<int>>{}.obs;
  final RxInt selectedGrowthTab = 1.obs;

  // Usuario logueado
  final RxString currentUserName = ''.obs;
  final RxString currentUserInitials = ''.obs;

  final RxBool isLoading = false.obs;

  final _repo = MarketplaceRepository.instance;

  @override
  void onInit() {
    super.onInit();
    stores.assignAll(DummyHelper.stores);
    storeUsers.assignAll(DummyHelper.storeUsers);
    _initUserProfile();
    _calculateMetrics();
    _loadFromBackend();
  }

  void _initUserProfile() {
    final email = AuthService.currentUserEmail ?? '';
    if (email.isNotEmpty) {
      currentUserName.value = email.split('@').first;
      currentUserInitials.value = email[0].toUpperCase();
    }
  }

  Future<void> _loadFromBackend() async {
    isLoading.value = true;

    // Each call is independent — a backend failure on one doesn't block the others.
    await Future.wait<void>([
      _repo.fetchStores().then((s) { if (s.isNotEmpty) stores.assignAll(s); }).catchError((_) {}),
      _repo.fetchCategories().then((c) { if (c.isNotEmpty) categories.assignAll(c); }).catchError((_) {}),
      _repo.fetchAdminStats().then((s) { if (s != null) _applyStats(s); }).catchError((_) {}),
      _repo.fetchOrders(pageSize: 1).then((p) => _applyOrderStats(p.stats)).catchError((_) {}),
      AuthRepository.instance.fetchMe().then((me) { if (me != null) _applyUserProfile(me); }).catchError((_) {}),
    ]);

    _calculateMetrics();
    isLoading.value = false;
  }

  void _applyOrderStats(OrdersStats s) {
    if (totalRedemptions.value == 0 && s.totalOrders > 0) {
      totalRedemptions.value = s.totalOrders;
    }
    if (totalPointsPts.value == 0 && s.totalPointsUsed > 0) {
      totalPointsPts.value = s.totalPointsUsed;
    }
  }

  void _applyUserProfile(Map<String, dynamic> me) {
    final fn = (me['first_name'] ?? me['firstName'] ?? '').toString().trim();
    final ln = (me['last_name'] ?? me['lastName'] ?? '').toString().trim();
    final full = (me['full_name'] ?? me['name'] ?? '').toString().trim();
    final name = full.isNotEmpty ? full : [fn, ln].where((s) => s.isNotEmpty).join(' ');
    if (name.isNotEmpty) {
      currentUserName.value = name;
      currentUserInitials.value = name
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
    }
  }

  void _applyStats(Map<String, dynamic> stats) {
    totalStores.value = _parseInt(stats['total_stores'] ?? stats['stores']) ?? totalStores.value;
    totalCategories.value = _parseInt(stats['total_categories'] ?? stats['categories']) ?? totalCategories.value;
    totalProducts.value = _parseInt(stats['total_products'] ?? stats['products']) ?? totalProducts.value;
    totalRedemptions.value = _parseInt(stats['total_redemptions'] ?? stats['redemptions']) ?? totalRedemptions.value;
    totalPointsPts.value = _parseInt(stats['total_points'] ?? stats['points_value']) ?? totalPointsPts.value;

    final usersRaw = stats['total_users'] ?? stats['active_users'] ?? stats['users'];
    if (usersRaw != null) totalStoreUsers.value = _parseInt(usersRaw) ?? totalStoreUsers.value;

    // Crecimiento
    final sg = _parseDouble(stats['stores_growth_percent'] ?? stats['stores_growth']);
    if (sg != null) storesGrowthPercent.value = sg;
    final ug = _parseDouble(stats['users_growth_percent'] ?? stats['users_growth']);
    if (ug != null) usersGrowthPercent.value = ug;

    // Permisos
    final sa = _parseInt(stats['super_admin_count'] ?? stats['superadmin_count']);
    if (sa != null) superAdminCount.value = sa;
    final st = _parseInt(stats['support_team_count'] ?? stats['support_count']);
    if (st != null) supportTeamCount.value = st;
    final sc = _parseInt(stats['security_compliance'] ?? stats['compliance']);
    if (sc != null) securityCompliance.value = sc;

    // Revenue por tienda
    final storeStats = stats['stores_stats'] ?? stats['store_stats'] ?? stats['stores_revenue'];
    if (storeStats is List) {
      for (final item in storeStats) {
        if (item is Map) {
          final id = (item['store_id'] ?? item['id'] ?? '').toString();
          final rev = _parseInt(item['revenue'] ?? item['total_revenue'] ?? item['total_points']);
          if (id.isNotEmpty && rev != null) storeRevenue[id] = rev;
        }
      }
    } else if (storeStats is Map) {
      storeStats.forEach((k, v) {
        final rev = _parseInt(v);
        if (rev != null) storeRevenue[k.toString()] = rev;
      });
    }

    // Network growth chart
    final growth = stats['network_growth'];
    if (growth is Map) {
      for (final key in ['7d', '30d', '6m']) {
        final raw = growth[key];
        if (raw is List) {
          networkGrowth[key] = raw.map((v) => _parseInt(v) ?? 0).toList();
        }
      }
    }
  }

  /// Devuelve los datos del gráfico normalizados a [0.0, 1.0] según el tab seleccionado.
  List<double> get currentGrowthData {
    final keys = ['7d', '30d', '6m'];
    final key = keys[selectedGrowthTab.value.clamp(0, 2)];
    final raw = networkGrowth[key] ?? [];
    if (raw.isEmpty) return [];
    final maxVal = raw.reduce(max);
    if (maxVal == 0) return List.filled(raw.length, 0.0);
    return raw.map((v) => v / maxVal).toList();
  }

  List<String> get currentGrowthLabels {
    switch (selectedGrowthTab.value) {
      case 0: return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 1: return ['W1', 'W2', 'W3', 'W4'];
      case 2: return ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
      default: return [];
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void _calculateMetrics() {
    if (totalStores.value == 0) totalStores.value = stores.length;
    if (totalStoreUsers.value == 0) totalStoreUsers.value = storeUsers.length;
    if (totalCategories.value == 0) totalCategories.value = categories.length;
  }

  Future<void> addStore(StoreModel store) async {
    stores.add(store);
    _calculateMetrics();

    try {
      final payload = <String, dynamic>{
        'name': store.name,        'description': store.description,
        'address': store.address,
        'logo':
            store.logoUrl.startsWith('http') ? store.logoUrl : null,
        'phoneNumber': store.billingPhone.isEmpty ? null : store.billingPhone,
        if (store.email.isNotEmpty) 'email': store.email,
        if (store.website.isNotEmpty) 'website': store.website,
        if (store.banner.isNotEmpty) 'banner': store.banner,
        if (store.openingHours.isNotEmpty) 'openingHours': store.openingHours,
        if (store.categories.isNotEmpty) 'categories': store.categories,
      }..removeWhere((_, v) => v == null);

      final created = await _repo.adminCreateStore(payload);
      if (created != null) {
        final idx = stores.indexOf(store);
        if (idx != -1) {
          stores[idx] = created;
          _calculateMetrics();
        }
        CustomSnackBar.showCustomSnackBar(
          title: 'Tienda creada',
          message: 'La tienda se guardo en el backend.',
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

  Future<void> addCategory({
    required String name,
    String? displayName,
    String? icon,
  }) async {
    try {
      final created = await _repo.adminCreateCategory(<String, dynamic>{
        'name': name,
        if (displayName != null) 'display_name': displayName,
        if (icon != null) 'icon': icon,
      });
      if (created != null) {
        categories.add(CategoryModel.fromJson(created));
        CustomSnackBar.showCustomSnackBar(
          title: 'Categoria creada',
          message: 'La categoria se guardo en el backend.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'No se pudo crear',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: 'No fue posible crear la categoria.',
      );
    }
  }

  /// El backend aun no expone alta/baja de usuarios de tienda;
  /// se mantienen en memoria.
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