import 'dart:async';

import 'package:get/get.dart';

import '../../../data/models/paginated.dart';
import '../../../data/models/store_model.dart';
import '../../../data/repositories/marketplace_repository.dart';

class StoresController extends GetxController {
  static const int _pageSize = 20;

  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<PageMeta> meta = const PageMeta().obs;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  /// Trae la primera página de tiendas aplicando los filtros actuales.
  Future<void> fetchStores() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final page = await MarketplaceRepository.instance.fetchStoresPage(
        search: _searchOrNull,
        page: 1,
        pageSize: _pageSize,
      );
      stores.assignAll(page.data);
      meta.value = page.meta;
    } catch (e) {
      errorMessage.value = e.toString();
      if (stores.isEmpty) {
        meta.value = const PageMeta();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga la siguiente página y la concatena a la lista actual.
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value) return;
    if (!meta.value.hasMore) return;
    isLoadingMore.value = true;
    try {
      final next = meta.value.page + 1;
      final page = await MarketplaceRepository.instance.fetchStoresPage(
        search: _searchOrNull,
        page: next,
        pageSize: _pageSize,
      );
      stores.addAll(page.data);
      meta.value = page.meta;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingMore.value = false;
    }
  }

  String? get _searchOrNull {
    final s = searchQuery.value.trim();
    return s.isEmpty ? null : s;
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), fetchStores);
  }

  void clearSearch() {
    searchQuery.value = '';
    fetchStores();
  }
}
