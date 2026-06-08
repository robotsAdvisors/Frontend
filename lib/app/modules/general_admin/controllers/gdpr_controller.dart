import 'dart:io';

import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/gdpr_request_model.dart';
import '../../../data/models/paginated.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/http/api_client.dart';

class GdprController extends GetxController {
  final _repo = MarketplaceRepository.instance;

  // Stats
  final Rx<GdprStats> stats = const GdprStats().obs;

  // Requests list
  final RxList<GdprRequestModel> requests = <GdprRequestModel>[].obs;
  final Rx<PageMeta> meta = const PageMeta().obs;
  final RxInt currentPage = 1.obs;
  static const int _pageSize = 20;

  // Filters
  final RxString activeFilter = 'all'.obs; // all | overdue | due_1day | due_3days | resolved
  final RxString activeType   = 'all'.obs; // all | erasure | portability | access | ...

  final RxBool isLoading        = false.obs;
  final RxBool isLoadingStats   = false.obs;
  final RxList<GdprFormat> formats = <GdprFormat>[].obs;
  final RxBool isExporting      = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadRequests();
    loadFormats();
  }

  Future<void> loadStats() async {
    isLoadingStats.value = true;
    try {
      stats.value = await _repo.fetchGdprStats();
    } catch (_) {} finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadRequests({int page = 1}) async {
    isLoading.value = true;
    try {
      final filter = activeFilter.value == 'all' ? null : activeFilter.value;
      final type   = activeType.value   == 'all' ? null : activeType.value;
      final result = await _repo.fetchGdprRequests(
        filter: filter, type: type, page: page, pageSize: _pageSize);
      requests.assignAll(result.data);
      meta.value = result.meta;
      currentPage.value = page;
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
    loadRequests(page: 1);
  }

  void setType(String type) {
    activeType.value = type;
    loadRequests(page: 1);
  }

  Future<void> updateStatus(String requestId, String newStatus) async {
    try {
      final updated = await _repo.updateGdprRequest(requestId, {'status': newStatus});
      if (updated != null) {
        final idx = requests.indexWhere((r) => r.id == requestId);
        if (idx != -1) requests[idx] = updated;
        requests.refresh();
        await loadStats();
        CustomSnackBar.showCustomSnackBar(
          title: 'Estado actualizado',
          message: 'La solicitud fue actualizada correctamente.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {}
  }

  /// Asigna una solicitud a un staff por email.
  Future<void> assignRequest(String requestId, String assignedToEmail) async {
    try {
      final updated = await _repo.updateGdprRequest(requestId, {
        'assigned_to': assignedToEmail, // backend acepta email
        'status': 'in_process',
      });
      if (updated != null) {
        final idx = requests.indexWhere((r) => r.id == requestId);
        if (idx != -1) requests[idx] = updated;
        requests.refresh();
        CustomSnackBar.showCustomSnackBar(
          title: 'Solicitud asignada',
          message: 'Asignada a $assignedToEmail.',
        );
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {}
  }

  Future<void> loadFormats() async {
    try {
      final result = await _repo.fetchGdprFormats();
      formats.assignAll(result);
    } catch (_) {}
  }

  Future<void> exportReport() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final filter = activeFilter.value == 'all' ? null : activeFilter.value;
      final type   = activeType.value   == 'all' ? null : activeType.value;
      final bytes  = await _repo.exportGdprReport(status: filter, type: type);
      if (bytes.isEmpty) {
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'Sin datos', message: 'El servidor devolvió un archivo vacío.');
        return;
      }
      final filename = 'gdpr_solicitudes_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = await _resolveFile(filename);
      await file.writeAsBytes(bytes, flush: true);
      CustomSnackBar.showCustomSnackBar(
        title: 'Reporte exportado',
        message: 'Guardado en ${file.path}',
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error', message: 'No se pudo generar el reporte.');
    } finally {
      isExporting.value = false;
    }
  }

  Future<File> _resolveFile(String filename) async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (dir.existsSync()) return File('${dir.path}/$filename');
    }
    return File('${Directory.systemTemp.path}/$filename');
  }
}
