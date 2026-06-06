import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/services/http/api_client.dart';

enum BookingFilter { all, active, upcoming, completed, cancelled }

class BookingsController extends GetxController {
  final _repo = BookingRepository.instance;

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final Rx<BookingFilter> activeFilter = BookingFilter.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCancelling = false.obs;

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
      final status = _filterToParam(activeFilter.value);
      final list = await _repo.fetchBookings(status: status);
      bookings.assignAll(list);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo cargar tus reservas.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(BookingFilter f) {
    if (activeFilter.value == f) return;
    activeFilter.value = f;
    _load();
  }

  List<BookingModel> get displayed => bookings;

  Future<void> cancelBooking(BookingModel booking) async {
    isCancelling.value = true;
    try {
      await _repo.cancelBooking(booking.id);
      final idx = bookings.indexWhere((b) => b.id == booking.id);
      if (idx != -1) {
        bookings.removeAt(idx);
      }
      CustomSnackBar.showCustomSnackBar(
        title: 'Reserva cancelada',
        message: 'Tu reserva ha sido cancelada correctamente.',
      );
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Sin conexión',
        message: 'No se pudo cancelar la reserva. Inténtalo de nuevo.',
      );
    } finally {
      isCancelling.value = false;
    }
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  int get activeCount =>
      bookings.where((b) => b.status == BookingStatus.active).length;

  int get upcomingCount =>
      bookings.where((b) => b.status == BookingStatus.upcoming).length;

  double get totalSpent => bookings
      .where((b) => b.status == BookingStatus.completed)
      .fold(0.0, (sum, b) => sum + b.totalCost);

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static String? _filterToParam(BookingFilter f) {
    switch (f) {
      case BookingFilter.active:
        return 'active';
      case BookingFilter.upcoming:
        return 'upcoming';
      case BookingFilter.completed:
        return 'completed';
      case BookingFilter.cancelled:
        return 'cancelled';
      case BookingFilter.all:
        return null;
    }
  }
}
