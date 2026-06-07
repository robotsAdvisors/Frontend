import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/api_config.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/paginated.dart';
import '../models/parking_spot_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/store_user_model.dart';
import '../models/voucher_model.dart';
import '../services/http/api_client.dart';

/// Repositorio del modulo marketplace contra el backend Django Letdem.
class MarketplaceRepository {
  MarketplaceRepository._();
  static final MarketplaceRepository instance = MarketplaceRepository._();

  final _dio = ApiClient.instance.dio;

  // ---------- CATALOGO ----------

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get(ApiConfig.categories);
      return _toList(response.data)
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Versión paginada de [fetchCategories] que expone el `meta`.
  Future<Paginated<CategoryModel>> fetchCategoriesPage({int? page, int? pageSize}) async {
    return _fetchPage(
      url: ApiConfig.categories,
      page: page,
      pageSize: pageSize,
      fromJson: CategoryModel.fromJson,
    );
  }

  Future<List<ProductModel>> fetchProducts({
    String? storeId,
    String? search,
    String? categoryName,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.products,
        queryParameters: {
          if (storeId != null && storeId.isNotEmpty) 'store': storeId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryName != null && categoryName.isNotEmpty)
            'category': categoryName,
        },
      );
      return _toList(response.data)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Versión paginada de [fetchProducts] que expone el `meta`.
  Future<Paginated<ProductModel>> fetchProductsPage({
    String? storeId,
    String? search,
    String? categoryName,
    int? page,
    int? pageSize,
  }) async {
    return _fetchPage(
      url: ApiConfig.products,
      page: page,
      pageSize: pageSize,
      query: {
        if (storeId != null && storeId.isNotEmpty) 'store': storeId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryName != null && categoryName.isNotEmpty) 'category': categoryName,
      },
      fromJson: ProductModel.fromJson,
    );
  }

  Future<ProductModel?> fetchProductDetail(String productId) async {
    try {
      final response = await _dio.get('${ApiConfig.products}$productId/');
      if (response.statusCode == 200 && response.data is Map) {
        return ProductModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  Future<List<StoreModel>> fetchStores({
    String? search,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.stores,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return _toList(response.data)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Versión paginada de [fetchStores] que devuelve modelos tipados.
  Future<Paginated<StoreModel>> fetchStoresPage({
    String? search,
    String? category,
    int? page,
    int? pageSize,
  }) async {
    return _fetchPage(
      url: ApiConfig.stores,
      page: page,
      pageSize: pageSize,
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      },
      fromJson: StoreModel.fromJson,
    );
  }

  Future<StoreModel?> fetchStoreDetail(String storeId) async {
    try {
      final response = await _dio.get('${ApiConfig.stores}$storeId/');
      if (response.statusCode == 200 && response.data is Map) {
        return StoreModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  // ---------- VOUCHERS ----------

  Future<List<VoucherModel>> fetchVouchers({
    String? status,
    String? redeemType,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.vouchers,
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (redeemType != null && redeemType.isNotEmpty)
            'redeem_type': redeemType,
        },
      );
      return _toList(response.data)
          .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Versión paginada de [fetchVouchers] que expone el `meta`.
  Future<Paginated<VoucherModel>> fetchVouchersPage({
    String? status,
    String? redeemType,
    int? page,
    int? pageSize,
  }) async {
    return _fetchPage(
      url: ApiConfig.vouchers,
      page: page,
      pageSize: pageSize,
      query: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (redeemType != null && redeemType.isNotEmpty) 'redeem_type': redeemType,
      },
      fromJson: VoucherModel.fromJson,
    );
  }

  Future<VoucherModel?> createVoucherOnline({
    required String storeId,
    required String productId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.vouchersCreateOnline,
        data: {
          'store_id': storeId,
          'product_id': productId,
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return VoucherModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> validateVoucher(String code) async {
    try {
      final response = await _dio.post(
        ApiConfig.vouchersValidate,
        data: {'code': code},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  // ---------- ORDERS ----------

  /// Devuelve el envelope tipado `{data, meta:{total, page, lastPage, stats}}`
  /// del endpoint `GET /marketplace/orders/`.
  Future<OrdersPage> fetchOrders({int? page, int? pageSize}) async {
    try {
      final response = await _dio.get(
        ApiConfig.orders,
        queryParameters: {
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );
      final raw = Map<String, dynamic>.from(response.data as Map);
      return OrdersPage.fromJson(raw);
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- PURCHASE ----------

  /// Compra con canje de puntos (30% off por 500 puntos).
  Future<Map<String, dynamic>> purchaseWithRedeem({
    required String productId,
    int quantity = 1,
    String? paymentIntentId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.purchaseWithRedeem,
        data: {
          'product_id': productId,
          'quantity': quantity,
          if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Compra a precio completo, sin uso de puntos.
  Future<Map<String, dynamic>> purchaseWithoutRedeem({
    required String productId,
    int quantity = 1,
    String? paymentIntentId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.purchaseWithoutRedeem,
        data: {
          'product_id': productId,
          'quantity': quantity,
          if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- ADMIN ----------

  Future<Map<String, dynamic>?> adminCreateProduct(
      Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(ApiConfig.adminProducts, data: payload);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// PUT /marketplace/admin/products/<id>/
  Future<Map<String, dynamic>?> adminUpdateProduct(
      String productId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.adminProducts}$productId/',
        data: payload,
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// DELETE /marketplace/admin/products/<id>/
  Future<void> adminDeleteProduct(String productId) async {
    try {
      await _dio.delete('${ApiConfig.adminProducts}$productId/');
    } catch (e) {
      throw toApiException(e);
    }
  }

  Future<StoreModel?> adminCreateStore(
      Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(ApiConfig.adminStores, data: payload);
      if (response.data is Map) {
        return StoreModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> adminCreateCategory(
      Map<String, dynamic> payload) async {
    try {
      final response =
          await _dio.post(ApiConfig.adminCategories, data: payload);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// Canjes por día para la tienda.
  /// GET /marketplace/analytics/vouchers/daily/?store_id=X&days=30
  Future<List<Map<String, dynamic>>> fetchAnalyticsVouchersDaily(
      String storeId, {
      int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.analyticsVouchersDaily,
        queryParameters: {
          if (storeId.isNotEmpty) 'store_id': storeId,
          'days': days,
        },
      );
      return _toList(response.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Resumen mensual con growth % para la tienda.
  /// GET /marketplace/analytics/summary/?store_id=X
  Future<Map<String, dynamic>> fetchAnalyticsSummary(String storeId) async {
    try {
      final response = await _dio.get(
        ApiConfig.analyticsSummary,
        queryParameters: {
          if (storeId.isNotEmpty) 'store_id': storeId,
        },
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return const {};
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- PARKING ----------

  /// GET /parking/spots/{id}/
  Future<ParkingSpotModel?> fetchParkingSpot(String spotId) async {
    try {
      final response = await _dio.get(ApiConfig.parkingSpotDetail(spotId));
      if (response.statusCode == 200 && response.data is Map) {
        return ParkingSpotModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// PATCH /parking/spots/{uuid}/report/
  /// Crea o actualiza el reporte del usuario.
  /// [waitTime] en minutos (null = sin cambio).
  /// [photo] es un archivo multipart; pasar null si no hay foto nueva.
  /// Devuelve el spot actualizado con el wait_time y photo del reporte.
  Future<ParkingSpotModel?> updateParkingReport(
    String spotId, {
    int? waitTime,
    // ignore: unused_element
    dynamic photoFile, // MultipartFile cuando se integre image_picker
  }) async {
    try {
      final data = <String, dynamic>{
        if (waitTime != null) 'wait_time': waitTime,
      };
      final response = await _dio.patch(
        ApiConfig.parkingSpotReport(spotId),
        data: data,
      );
      if (response.data is Map) {
        return ParkingSpotModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// DELETE /parking/spots/{uuid}/report/ → 204 No Content
  Future<void> deleteParkingReport(String spotId) async {
    try {
      await _dio.delete(ApiConfig.parkingSpotReport(spotId));
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- PRODUCT IMAGE UPLOAD ----------

  /// GET /marketplace/admin/products/export/?store=<id>&format=csv
  /// Returns raw UTF-8+BOM bytes ready to write as a .csv file.
  Future<List<int>> exportProductsCsv(String storeId) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConfig.adminProductExport,
        queryParameters: {
          if (storeId.isNotEmpty) 'store': storeId,
          'format': 'csv',
        },
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const [];
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// POST /marketplace/admin/products/upload-image/ (multipart/form-data)
  /// Campo: image (JPEG / PNG / WEBP / GIF)
  /// Respuesta: { "image_url": "https://..." }
  Future<String> uploadProductImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        // Dio infers MIME type from filename; no need for http_parser.
        'image': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      final response = await _dio.post(
        ApiConfig.adminProductUploadImage,
        data: formData,
      );
      if (response.data is Map) {
        final url = response.data['image_url']?.toString() ?? '';
        if (url.isNotEmpty) return url;
      }
      throw ApiException('El servidor no devolvió una URL de imagen.');
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ---------- STORE SETTINGS ----------

  /// PATCH /marketplace/stores/<id>/ — actualiza info de la tienda.
  Future<StoreModel?> updateStore(
      String storeId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.patch(
        ApiConfig.storeDetail(storeId),
        data: payload,
      );
      if (response.data is Map) {
        return StoreModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// GET /marketplace/stores/<id>/users/ — lista usuarios con roles.
  Future<List<StoreUserModel>> fetchStoreUsers(String storeId) async {
    try {
      final response = await _dio.get(ApiConfig.storeUsers(storeId));
      return _toList(response.data)
          .whereType<Map>()
          .map((e) => StoreUserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// POST /marketplace/stores/<id>/users/ — invita a un usuario por email y rol.
  /// El mismo endpoint que GET /users/ — el backend distingue por método HTTP.
  Future<void> inviteStoreUser(
      String storeId, String email, String role) async {
    try {
      await _dio.post(
        ApiConfig.storeUsers(storeId),
        data: {'email': email, 'role': role},
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// PATCH /marketplace/stores/<storeId>/users/<userId>/ — cambia rol de un usuario.
  Future<void> updateStoreUserRole(
      String storeId, String userId, String role) async {
    try {
      await _dio.patch(
        ApiConfig.storeUserDetail(storeId, userId),
        data: {'role': role},
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// DELETE /marketplace/stores/<storeId>/users/<userId>/ — elimina usuario de la tienda.
  Future<void> removeStoreUser(String storeId, String userId) async {
    try {
      await _dio.delete(ApiConfig.storeUserDetail(storeId, userId));
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// POST /marketplace/stores/<id>/change-pin/ — cambia el PIN de la tienda.
  Future<void> changeStorePin(
      String storeId, String currentPin, String newPin) async {
    try {
      await _dio.post(
        ApiConfig.storeChangePIN(storeId),
        data: {'current_pin': currentPin, 'new_pin': newPin},
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// PATCH /marketplace/stores/<id>/security/ — activa o desactiva 2FA.
  Future<void> updateStoreSecurity(
      String storeId, {required bool twoFactorEnabled}) async {
    try {
      await _dio.patch(
        ApiConfig.storeSecurity(storeId),
        data: {'two_factor_enabled': twoFactorEnabled},
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Feed de actividad de una tienda específica.
  /// GET /marketplace/stores/<id>/activity/?limit=N
  /// Devuelve {activities: [...], ...} — tipos: voucher_redeemed, product_added, system_update
  Future<List<Map<String, dynamic>>> fetchStoreActivity(
    String storeId, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.storeActivity(storeId),
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      // Backend retorna envelope {activities: [...], ...}
      if (data is Map && data['activities'] is List) {
        return (data['activities'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return _toList(data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// PIN actual de la tienda (masked).
  /// GET /marketplace/stores/<id>/pin/
  /// Retorna: {pin_masked, pin_configured}
  Future<Map<String, dynamic>> fetchStorePIN(String storeId) async {
    try {
      final response = await _dio.get(ApiConfig.storePIN(storeId));
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return const {};
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Regenera el PIN de la tienda (lo muestra UNA sola vez).
  /// POST /marketplace/stores/<id>/pin/regenerate/
  /// Retorna: {pin, pin_masked}
  Future<Map<String, dynamic>> regenerateStorePIN(String storeId) async {
    try {
      final response = await _dio.post(ApiConfig.storePINRegenerate(storeId));
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return const {};
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Log de seguridad de la tienda.
  /// GET /marketplace/stores/<id>/security-log/?limit=N
  /// Tipos de evento: pin_changed, password_changed, role_added
  Future<List<Map<String, dynamic>>> fetchSecurityLog(
    String storeId, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.storeSecurityLog(storeId),
        queryParameters: {'limit': limit},
      );
      return _toList(response.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Meta mensual de fidelización de una tienda.
  /// GET /marketplace/stores/<id>/monthly-goal/
  /// Retorna: {monthly_goal_current, monthly_goal_target,
  ///           monthly_goal_days_remaining, monthly_goal_prize}
  Future<Map<String, dynamic>> fetchMonthlyGoal(String storeId) async {
    try {
      final response = await _dio.get(ApiConfig.storeMonthlyGoal(storeId));
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return const {};
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Estadísticas globales del Super Admin.
  /// GET /marketplace/admin/stats/
  Future<Map<String, dynamic>?> fetchAdminStats() async {
    try {
      final response = await _dio.get(ApiConfig.adminStats);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      throw toApiException(e);
    }
    return null;
  }

  /// Helper genérico para endpoints paginados con envelope `{data, meta}`.
  Future<Paginated<T>> _fetchPage<T>({
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? query,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          ...?query,
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );
      final raw = response.data;
      if (raw is Map) {
        return Paginated<T>.fromJson(Map<String, dynamic>.from(raw), fromJson);
      }
      if (raw is List) {
        final items = raw
            .whereType<Map>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Paginated<T>(
          data: items,
          meta: PageMeta(total: items.length, page: 1, lastPage: 1),
        );
      }
      return Paginated<T>(data: const [], meta: const PageMeta());
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// Extrae la lista del envelope canónico del backend:
  /// `{data: [...], meta: {total, page, lastPage}}`.
  /// Acepta también una lista plana por compatibilidad mínima.
  static List<dynamic> _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      // DRF PageNumberPagination → { "results": [...] }
      if (data['results'] is List) return List<dynamic>.from(data['results'] as List);
      // Custom envelope → { "data": [...] }
      if (data['data'] is List) return List<dynamic>.from(data['data'] as List);
    }
    return const [];
  }
}
