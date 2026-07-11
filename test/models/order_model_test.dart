import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/order_model.dart';

void main() {
  group('OrderItemModel', () {
    test('calcula total_price cuando no viene (price * qty)', () {
      final item = OrderItemModel.fromJson({
        'id': 'i1',
        'product': 'p1',
        'unit_price': 10,
        'quantity': 3,
      });
      expect(item.totalPrice, 30);
      expect(item.price, 10);
      expect(item.quantity, 3);
    });

    test('respeta total_price explícito', () {
      final item = OrderItemModel.fromJson({
        'unit_price': 10,
        'quantity': 3,
        'total_price': 27,
      });
      expect(item.totalPrice, 27);
    });

    test('quantity por defecto 1', () {
      final item = OrderItemModel.fromJson({'price': 5});
      expect(item.quantity, 1);
      expect(item.totalPrice, 5);
    });
  });

  group('OrderModel', () {
    test('parsea items anidados', () {
      final o = OrderModel.fromJson({
        'id': 'o1',
        'status': 'PAID',
        'subtotal': 100,
        'total': 90,
        'points_discount': 10,
        'used_points': 500,
        'items': [
          {'id': 'i1', 'product': 'p1', 'unit_price': 45, 'quantity': 2},
        ],
      });
      expect(o.id, 'o1');
      expect(o.status, 'PAID');
      expect(o.subtotal, 100);
      expect(o.total, 90);
      expect(o.usedPoints, 500);
      expect(o.items, hasLength(1));
      expect(o.items.first.totalPrice, 90);
    });

    test('defaults seguros ante json vacío', () {
      final o = OrderModel.fromJson({});
      expect(o.status, 'OPEN');
      expect(o.isOpen, true);
      expect(o.items, isEmpty);
    });
  });

  group('OrdersPage', () {
    test('parsea data, meta y stats', () {
      final page = OrdersPage.fromJson({
        'data': [
          {'id': 'o1', 'items': []},
        ],
        'meta': {
          'total': 1,
          'page': 1,
          'lastPage': 1,
          'stats': {
            'total_orders': 5,
            'total_spent': 250.5,
            'total_points_used': 1000,
            'total_saved': 30,
            'current_points': 200,
          },
        },
      });
      expect(page.data, hasLength(1));
      expect(page.total, 1);
      expect(page.stats.totalOrders, 5);
      expect(page.stats.totalSpent, 250.5);
      expect(page.stats.currentPoints, 200);
      expect(page.meta.total, 1);
    });

    test('total cae al tamaño de data si falta en meta', () {
      final page = OrdersPage.fromJson({
        'data': [
          {'id': 'a', 'items': []},
          {'id': 'b', 'items': []},
        ],
      });
      expect(page.total, 2);
    });
  });
}
