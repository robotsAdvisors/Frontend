import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/withdrawal_model.dart';
import '../../../data/repositories/withdrawal_repository.dart';
import '../../../data/services/http/api_client.dart';

class WithdrawalsController extends GetxController {
  final _repo = WithdrawalRepository.instance;

  final RxList<WithdrawalModel> withdrawals = <WithdrawalModel>[].obs;
  final Rx<WithdrawalConfig> config = const WithdrawalConfig().obs;
  final RxBool isLoading = false.obs;
  final RxBool isRequesting = false.obs;

  // Formulario: método seleccionado y monto (null = retirar todo)
  final Rx<PayoutMethod?> selectedMethod = Rx<PayoutMethod?>(null);
  final RxDouble selectedAmount = 0.0.obs;
  final RxBool withdrawAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait<void>([
      _repo
          .fetchConfig()
          .then((c) {
            config.value = c;
            if (selectedMethod.value == null && c.defaultMethod != null) {
              selectedMethod.value = c.defaultMethod;
            }
          })
          .catchError((_) { config.value = const WithdrawalConfig(); }),
      _repo
          .fetchWithdrawals()
          .then((list) => withdrawals.assignAll(list))
          .catchError((_) => withdrawals.clear()),
    ]);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _loadAll();

  void selectMethod(PayoutMethod m) => selectedMethod.value = m;

  void setAmount(double v) {
    withdrawAll.value = false;
    selectedAmount.value = v.clamp(0, config.value.availableBalance);
  }

  void toggleWithdrawAll() {
    withdrawAll.value = !withdrawAll.value;
    if (withdrawAll.value) selectedAmount.value = availableBalance;
  }

  // ─── Getters de conveniencia ─────────────────────────────────────────────

  double get availableBalance => config.value.availableBalance;
  bool get isVerified => config.value.isVerified;
  double get instantLimit => config.value.instantLimit;
  double get minAmount => config.value.minAmount;
  double get maxAmount => config.value.maxAmount;
  List<PayoutMethod> get availableMethods => config.value.availableMethods;

  bool get canWithdraw =>
      isVerified &&
      availableBalance >= minAmount &&
      selectedMethod.value != null &&
      !isRequesting.value;

  /// Importe efectivo a enviar al backend: null si withdrawAll, sino selectedAmount.
  double? get _effectiveAmount =>
      withdrawAll.value ? null : (selectedAmount.value > 0 ? selectedAmount.value : null);

  Future<void> requestWithdrawal() async {
    final method = selectedMethod.value;
    if (method == null) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin método',
        message: 'Selecciona un método de cobro.',
      );
      return;
    }

    final amount = _effectiveAmount;
    if (amount != null && amount < minAmount) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Importe insuficiente',
        message: 'El mínimo de retiro es €${minAmount.toStringAsFixed(2)}.',
      );
      return;
    }
    if (amount != null && amount > availableBalance) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Saldo insuficiente',
        message: 'No tienes saldo suficiente para este retiro.',
      );
      return;
    }

    isRequesting.value = true;
    try {
      final result = await _repo.requestWithdrawal(
        payoutMethodId: method.id,
        amount: amount,
      );
      withdrawals.insert(0, result);

      // Actualizar saldo localmente
      final deducted = amount ?? availableBalance;
      config.value = config.value.copyWithBalance(availableBalance - deducted);
      selectedAmount.value = 0;
      withdrawAll.value = false;

      final displayAmount = amount?.toStringAsFixed(2) ?? availableBalance.toStringAsFixed(2);
      CustomSnackBar.showCustomSnackBar(
        title: 'Solicitud enviada',
        message: 'Tu retiro de €$displayAmount está siendo procesado.',
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo enviar la solicitud. Inténtalo de nuevo.',
      );
    } finally {
      isRequesting.value = false;
    }
  }

  // ─── Helpers de historial ────────────────────────────────────────────────

  double get totalWithdrawn => withdrawals
      .where((w) => w.status == WithdrawalStatus.completed)
      .fold(0.0, (sum, w) => sum + w.amount);

  int get pendingCount =>
      withdrawals.where((w) => w.status == WithdrawalStatus.pending).length;
}
