import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/virtual_card_model.dart';
import '../../../data/repositories/virtual_card_repository.dart';
import '../../../data/services/http/api_client.dart';

class VirtualCardController extends GetxController {
  final _repo = VirtualCardRepository.instance;

  final Rx<VirtualCardModel?> card = Rx<VirtualCardModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isToggling = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  Future<void> refresh() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    try {
      card.value = await _repo.fetchCard();
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo cargar la tarjeta virtual.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive() async {
    final current = card.value;
    if (current == null || isToggling.value) return;

    final next = !current.isActive;
    // Optimistic update
    card.value = current.copyWith(isActive: next);
    isToggling.value = true;
    try {
      final updated = await _repo.toggleActive(isActive: next);
      card.value = updated;
    } on ApiException catch (e) {
      // Revert on failure
      card.value = current;
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      card.value = current;
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo actualizar el estado de la tarjeta.',
      );
    } finally {
      isToggling.value = false;
    }
  }
}
