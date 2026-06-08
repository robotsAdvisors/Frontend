import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/paginated.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/http/api_client.dart';
import 'admin_controller.dart';

class ReviewsController extends GetxController {
  final _repo = MarketplaceRepository.instance;

  String get _storeId {
    try {
      return Get.find<AdminController>().storeId.value;
    } catch (_) {
      return '';
    }
  }

  final Rx<ReviewsStats> stats = const ReviewsStats().obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final Rx<PageMeta> meta = const PageMeta().obs;
  final RxInt currentPage = 1.obs;

  // Backend filters: positive | negative | pending_reply | hidden
  final RxString activeFilter = 'all'.obs;
  // Backend sorts: recent | rating_asc | rating_desc
  final RxString activeSort   = 'recent'.obs;

  final RxBool isLoading      = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isSubmitting   = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadReviews();
  }

  Future<void> loadStats() async {
    isLoadingStats.value = true;
    try {
      stats.value = await _repo.fetchReviewStats(_storeId);
    } catch (_) {} finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadReviews({int page = 1}) async {
    isLoading.value = true;
    try {
      final filter = activeFilter.value == 'all' ? null : activeFilter.value;
      final result = await _repo.fetchStoreReviews(
        _storeId, filter: filter, sort: activeSort.value, page: page);
      reviews.assignAll(result.data);
      meta.value = result.meta;
      currentPage.value = page;
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void setFilter(String f) { activeFilter.value = f; loadReviews(page: 1); }
  void setSort(String s)   { activeSort.value   = s; loadReviews(page: 1); }

  Future<void> replyToReview(String reviewId, String message) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      final ok = await _repo.replyToReview(reviewId, message);
      if (ok) {
        await loadReviews(page: currentPage.value);
        CustomSnackBar.showCustomSnackBar(
            title: 'Respuesta enviada',
            message: 'Tu respuesta fue publicada correctamente.');
      }
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {
      CustomSnackBar.showCustomErrorSnackBar(
          title: 'Error', message: 'No se pudo enviar la respuesta.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> reportReview(String reviewId, String reason) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      await _repo.reportReview(reviewId, reason);
      await loadReviews(page: currentPage.value);
      CustomSnackBar.showCustomSnackBar(
          title: 'Incidencia reportada',
          message: 'El equipo admin fue notificado.');
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {} finally {
      isSubmitting.value = false;
    }
  }

  Future<void> hideReview(String reviewId) async {
    try {
      await _repo.hideReview(reviewId);
      await loadReviews(page: currentPage.value);
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(title: 'Error', message: e.message);
    } catch (_) {}
  }
}
