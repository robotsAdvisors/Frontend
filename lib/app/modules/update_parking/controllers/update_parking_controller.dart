import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/parking_spot_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/http/api_client.dart';

class UpdateParkingController extends GetxController {
  final _repo = MarketplaceRepository.instance;

  final Rx<ParkingSpotModel?> spot = Rx<ParkingSpotModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  // Editable state (espejo local del reporte)
  final RxInt waitTime = 0.obs;

  String get spotId {
    final args = Get.arguments;
    if (args is ParkingSpotModel) return args.id;
    if (args is String) return args;
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ParkingSpotModel) {
      _applySpot(Get.arguments as ParkingSpotModel);
    }
    // Siempre recarga desde el backend para obtener el wait_time y photo actuales.
    if (spotId.isNotEmpty) _loadSpot();
  }

  void _applySpot(ParkingSpotModel s) {
    spot.value = s;
    waitTime.value = s.waitTime ?? 0;
  }

  Future<void> _loadSpot() async {
    isLoading.value = true;
    try {
      final s = await _repo.fetchParkingSpot(spotId);
      if (s != null) _applySpot(s);
    } catch (_) {
      // Datos locales ya cargados desde arguments
    } finally {
      isLoading.value = false;
    }
  }

  void increment() {
    if (waitTime.value < 120) waitTime.value += 5;
  }

  void decrement() {
    if (waitTime.value > 0) waitTime.value -= 5;
  }

  void setWaitTime(int minutes) {
    waitTime.value = minutes.clamp(0, 120);
  }

  Future<void> submitUpdate() async {
    if (spotId.isEmpty) return;
    isSaving.value = true;
    try {
      final updated = await _repo.updateParkingReport(
        spotId,
        waitTime: waitTime.value,
      );
      if (updated != null) _applySpot(updated);
      CustomSnackBar.showCustomSnackBar(
        title: 'Actualizado',
        message: 'Gracias. +${spot.value?.points ?? 50} pts ganados.',
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al actualizar',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo enviar la actualización.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Llamado después de que el usuario confirma en el diálogo de la vista.
  Future<void> deleteReport() async {
    if (spotId.isEmpty) return;
    isDeleting.value = true;
    try {
      await _repo.deleteParkingReport(spotId);
      CustomSnackBar.showCustomSnackBar(
        title: 'Reporte eliminado',
        message: 'Tu reporte de aparcamiento fue eliminado.',
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo eliminar el reporte.',
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
