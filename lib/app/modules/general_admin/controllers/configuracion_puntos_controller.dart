import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/points_admin_models.dart';
import '../../../data/repositories/points_admin_repository.dart';
import '../../../data/services/http/api_client.dart';

/// Configuración del programa de puntos (ADM-PT-01).
/// Cablea `GET/PUT /admin/points/config/` con forma real `{settings, rules}`.
class ConfiguracionPuntosController extends GetxController {
  final _repo = PointsAdminRepository.instance;

  final Rx<PointsConfig?> config = Rx<PointsConfig?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      config.value = await _repo.getConfig();
    } on ApiException catch (e) {
      if (e.statusCode != 403) {
        CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  /// PUT parcial. Enviamos settings + rules + antifraud; el backend audita old/new.
  Future<bool> save({
    required Map<String, dynamic> settings,
    required List<Map<String, dynamic>> rules,
    Map<String, dynamic>? antifraud,
  }) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      config.value = await _repo.putConfig({
        'settings': settings,
        'rules': rules,
        if (antifraud != null) 'antifraud': antifraud,
      });
      CustomSnackBar.showCustomSnackBar(
          title: 'Guardado', message: 'Configuración actualizada.');
      return true;
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
          title: 'Error', message: 'No se pudo guardar la configuración.');
    } finally {
      isSaving.value = false;
    }
    return false;
  }
}
