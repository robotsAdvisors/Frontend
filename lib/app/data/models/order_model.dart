/// Modelos para el endpoint `GET /api/v1/marketplace/orders/`.
///
/// El backend devuelve el envelope:
/// ```
/// {
///   "data": [ <Order>, ... ],
///   "meta": {
///     "total": int,
///     "page": int,
///     "lastPage": int,
///     "stats": {
///       "total_orders": int,
///       "total_spent": double,
///       "total_points_used": int,
///       "total_saved": double,
///       "current_points": int
///     }
///   }
/// }
/// ```

import 'paginated.dart';

class OrderItemModel {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['unit_price'] ?? json['price']);
    final qty = (json['quantity'] ?? 1) is int
        ? json['quantity'] as int
        : int.tryParse(json['quantity'].toString()) ?? 1;
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      productId: (json['product'] ?? '').toString(),
      quantity: qty,
      price: price,
      totalPrice: _toDouble(json['total_price']) == 0
          ? price * qty
          : _toDouble(json['total_price']),
    );
  }
}

class OrderModel {
  final String id;
  final String status;
  final double subtotal;
  final double total;
  final double pointsDiscount;
  final int usedPoints;
  final bool isOpen;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.total,
    required this.pointsDiscount,
    required this.usedPoints,
    required this.isOpen,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'OPEN').toString(),
      subtotal: _toDouble(json['subtotal']),
      total: _toDouble(json['total']),
      pointsDiscount: _toDouble(json['points_discount']),
      usedPoints: (json['used_points'] ?? 0) is int
          ? json['used_points'] as int
          : int.tryParse(json['used_points'].toString()) ?? 0,
      isOpen: json['is_open'] is bool ? json['is_open'] as bool : true,
      createdAt: DateTime.tryParse((json['created'] ?? '').toString()) ??
          DateTime.now(),
      items: rawItems
          .whereType<Map>()
          .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class OrdersStats {
  final int totalOrders;
  final double totalSpent;
  final int totalPointsUsed;
  final double totalSaved;
  final int currentPoints;

  const OrdersStats({
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.totalPointsUsed = 0,
    this.totalSaved = 0,
    this.currentPoints = 0,
  });

  factory OrdersStats.fromJson(Map<String, dynamic> json) {
    return OrdersStats(
      totalOrders: (json['total_orders'] ?? 0) is int
          ? json['total_orders'] as int
          : int.tryParse(json['total_orders'].toString()) ?? 0,
      totalSpent: _toDouble(json['total_spent']),
      totalPointsUsed: (json['total_points_used'] ?? 0) is int
          ? json['total_points_used'] as int
          : int.tryParse(json['total_points_used'].toString()) ?? 0,
      totalSaved: _toDouble(json['total_saved']),
      currentPoints: (json['current_points'] ?? 0) is int
          ? json['current_points'] as int
          : int.tryParse(json['current_points'].toString()) ?? 0,
    );
  }
}

class OrdersPage {
  final List<OrderModel> data;
  final int total;
  final int page;
  final int lastPage;
  final OrdersStats stats;

  const OrdersPage({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
    required this.stats,
  });

  PageMeta get meta => PageMeta(total: total, page: page, lastPage: lastPage);

  factory OrdersPage.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List?) ?? const [];
    final meta = Map<String, dynamic>.from(
      (json['meta'] as Map?) ?? const {},
    );
    final rawStats = Map<String, dynamic>.from(
      (meta['stats'] as Map?) ?? const {},
    );
    return OrdersPage(
      data: rawData
          .whereType<Map>()
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (meta['total'] ?? rawData.length) is int
          ? meta['total'] as int
          : int.tryParse(meta['total'].toString()) ?? rawData.length,
      page: (meta['page'] ?? 1) is int
          ? meta['page'] as int
          : int.tryParse(meta['page'].toString()) ?? 1,
      lastPage: (meta['lastPage'] ?? 1) is int
          ? meta['lastPage'] as int
          : int.tryParse(meta['lastPage'].toString()) ?? 1,
      stats: OrdersStats.fromJson(rawStats),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
