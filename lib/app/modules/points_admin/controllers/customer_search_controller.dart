import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/points_admin_models.dart';
import '../../../data/repositories/points_admin_repository.dart';
import '../../../data/services/http/api_client.dart';

/// Buscador de clientes de la app por email (SPEC §13, Petición 1).
class CustomerSearchController extends GetxController {
  final _repo = PointsAdminRepository.instance;

  final TextEditingController searchField = TextEditingController();
  final RxString query = ''.obs;
  final RxList<CustomerListItem> results = <CustomerListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxInt count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Búsqueda con debounce: no dispara petición en cada tecla.
    debounce<String>(query, (_) => search(),
        time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    searchField.dispose();
    super.onClose();
  }

  void onQueryChanged(String value) => query.value = value;

  Future<void> search() async {
    final q = query.value.trim();
    if (q.length < 2) {
      results.clear();
      count.value = 0;
      hasSearched.value = false;
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;
    hasSearched.value = true;
    try {
      final page = await _repo.searchCustomers(q);
      results.assignAll(page.items);
      count.value = page.count;
    } on ApiException catch (e) {
      results.clear();
      count.value = 0;
      if (e.statusCode != 403) {
        CustomSnackBar.showCustomErrorSnackBar(
            title: 'Error', message: e.message);
      }
    } catch (_) {
      results.clear();
      count.value = 0;
    } finally {
      isLoading.value = false;
    }
  }
}
