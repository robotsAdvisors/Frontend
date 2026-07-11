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
    final qty = _toInt(json['quantity'], fallback: 1);
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
      usedPoints: _toInt(json['used_points']),
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
      totalOrders: _toInt(json['total_orders']),
      totalSpent: _toDouble(json['total_spent']),
      totalPointsUsed: _toInt(json['total_points_used']),
      totalSaved: _toDouble(json['total_saved']),
      currentPoints: _toInt(json['current_points']),
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
      total: _toInt(meta['total'], fallback: rawData.length),
      page: _toInt(meta['page'], fallback: 1),
      lastPage: _toInt(meta['lastPage'], fallback: 1),
      stats: OrdersStats.fromJson(rawStats),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
