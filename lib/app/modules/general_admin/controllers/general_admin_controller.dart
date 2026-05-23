import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/http/api_client.dart';

class GeneralAdminController extends GetxController {
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxList<StoreUserModel> storeUsers = <StoreUserModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxInt totalStores = 0.obs;
  final RxInt totalStoreUsers = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalRedemptions = 0.obs;
  final RxInt totalPointsPts = 0.obs;
  final RxMap<String, int> storeRevenue = <String, int>{}.obs;
  final RxBool isLoading = false.obs;

  final _repo = MarketplaceRepository.instance;

  @override
  void onInit() {
    super.onInit();
    stores.assignAll(DummyHelper.stores);
    storeUsers.assignAll(DummyHelper.storeUsers);
    _calculateMetrics();
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    isLoading.value = true;
    try {
      final results = await Future.wait<dynamic>([
        _repo.fetchStores(),
        _repo.fetchCategories(),
        _repo.fetchAdminStats(),
      ]);

      final remoteStores = results[0] as List<StoreModel>;
      final remoteCategories = results[1] as List<CategoryModel>;
      final stats = results[2] as Map<String, dynamic>?;

      if (remoteStores.isNotEmpty) {
        stores.assignAll(remoteStores);
      }
      if (remoteCategories.isNotEmpty) {
        categories.assignAll(remoteCategories);
      }

      if (stats != null) {
        _applyStats(stats);
      }

      _calculateMetrics();
    } catch (_) {
      // Datos dummy ya cargados, ignoramos el error.
    } finally {
      isLoading.value = false;
    }
  }

  void _applyStats(Map<String, dynamic> stats) {
    totalStores.value = _parseInt(stats['total_stores'] ?? stats['stores']) ?? totalStores.value;
    totalCategories.value = _parseInt(stats['total_categories'] ?? stats['categories']) ?? totalCategories.value;
    totalProducts.value = _parseInt(stats['total_products'] ?? stats['products']) ?? totalProducts.value;
    totalRedemptions.value = _parseInt(stats['total_redemptions'] ?? stats['redemptions']) ?? totalRedemptions.value;
    totalPointsPts.value = _parseInt(stats['total_points'] ?? stats['points_value']) ?? totalPointsPts.value;

    final usersRaw = stats['total_users'] ?? stats['active_users'] ?? stats['users'];
    if (usersRaw != null) {
      totalStoreUsers.value = _parseInt(usersRaw) ?? totalStoreUsers.value;
    }

    // Revenue por tienda: acepta lista [{store_id, revenue}] o map {store_id: revenue}
    final storeStats = stats['stores_stats'] ?? stats['store_stats'] ?? stats['stores_revenue'];
    if (storeStats is List) {
      for (final item in storeStats) {
        if (item is Map) {
          final id = (item['store_id'] ?? item['id'] ?? '').toString();
          final rev = _parseInt(item['revenue'] ?? item['total_revenue'] ?? item['total_points']);
          if (id.isNotEmpty && rev != null) {
            storeRevenue[id] = rev;
          }
        }
      }
    } else if (storeStats is Map) {
      storeStats.forEach((k, v) {
        final rev = _parseInt(v);
        if (rev != null) storeRevenue[k.toString()] = rev;
      });
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
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
        'name': store.name,
        'description': store.description,
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