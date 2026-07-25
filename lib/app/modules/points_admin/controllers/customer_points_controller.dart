import 'dart:math';

import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/points_admin_models.dart';
import '../../../data/repositories/points_admin_repository.dart';
import '../../../data/services/http/api_client.dart';

/// Ficha de puntos de un cliente: saldo, movimientos y ajuste manual.
/// Recibe por `Get.arguments` un mapa `{id, email, name}` desde el buscador
/// (o desde la cola de antifraude con `{id}`).
class CustomerPointsController extends GetxController {
  final _repo = PointsAdminRepository.instance;

  late final String userId;
  late final String email;
  late final String name;

  final Rx<PointsBalance?> balance = Rx<PointsBalance?>(null);
  final RxBool isLoadingBalance = false.obs;

  final RxList<PointsMovement> movements = <PointsMovement>[].obs;
  final RxBool isLoadingMovements = false.obs;
  final RxString directionFilter = ''.obs;
  final RxString statusFilter = ''.obs;

  final RxBool isAdjusting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? const {};
    userId = (args['id'] ?? '').toString();
    email = (args['email'] ?? '').toString();
    name = (args['name'] ?? '').toString();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadBalance(), loadMovements()]);
  }

  Future<void> loadBalance() async {
    if (userId.isEmpty || isLoadingBalance.value) return;
    isLoadingBalance.value = true;
    try {
      balance.value = await _repo.fetchBalance(userId);
    } on ApiException catch (e) {
      if (e.statusCode != 403) {
        CustomSnackBar.showCustomErrorSnackBar(
            title: 'Error', message: e.message);
      }
    } catch (_) {
    } finally {
      isLoadingBalance.value = false;
    }
  }

  Future<void> loadMovements() async {
    if (userId.isEmpty || isLoadingMovements.value) return;
    isLoadingMovements.value = true;
    try {
      final page = await _repo.fetchMovements(
        userId,
        direction: directionFilter.value.isEmpty ? null : directionFilter.value,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
      );
      movements.assignAll(page.items);
    } on ApiException catch (e) {
      if (e.statusCode != 403) {
        CustomSnackBar.showCustomErrorSnackBar(
            title: 'Error', message: e.message);
      }
    } catch (_) {
    } finally {
      isLoadingMovements.value = false;
    }
  }

  void setDirectionFilter(String v) {
    directionFilter.value = v;
    loadMovements();
  }

  void setStatusFilter(String v) {
    statusFilter.value = v;
    loadMovements();
  }

  /// Ajuste manual (ADM-PT-03). `amount` con signo (negativo retira).
  /// Devuelve true si se aplicó. Maneja 409 INSUFFICIENT_POINTS con "te faltan N".
  Future<bool> adjust({
    required int amount,
    required String reasonText,
    required String auditReference,
    required String idempotencyKey,
  }) async {
    if (isAdjusting.value) return false;
    isAdjusting.value = true;
    try {
      final res = await _repo.adjust(
        userId,
        amount: amount,
        reasonText: reasonText,
        auditReference: auditReference,
        idempotencyKey: idempotencyKey,
      );
      balance.value = res.saldos;
      await loadMovements();
      CustomSnackBar.showCustomSnackBar(
          title: 'Ajuste aplicado',
          message: 'Movimiento #${res.movementId} registrado.');
      return true;
    } on ApiException catch (e) {
      final missing = e.missingPoints;
      final msg = e.errorCode == 'INSUFFICIENT_POINTS'
          ? (missing != null
              ? 'Te faltan $missing puntos: el saldo no puede quedar negativo.'
              : 'Saldo insuficiente: no puede quedar negativo.')
          : e.message;
      CustomSnackBar.showCustomErrorSnackBar(title: 'No se aplicó', message: msg);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
          title: 'Error', message: 'No se pudo aplicar el ajuste.');
    } finally {
      isAdjusting.value = false;
    }
    return false;
  }

  /// Clave de idempotencia estable para un intento de ajuste.
  static String newIdempotencyKey() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rnd = Random().nextInt(0x7fffffff);
    return 'adj-$ts-$rnd';
  }
}
