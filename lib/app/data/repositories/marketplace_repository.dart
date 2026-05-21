import '../../../utils/api_config.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/paginated.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
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
    if (data is Map && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    return const [];
  }
}
