import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/voucher_model.dart';

void main() {
  group('VoucherModel._parseStatus', () {
    test('mapea todos los estados conocidos (case-insensitive)', () {
      expect(VoucherModel.fromJson({'status': 'paid'}).status,
          VoucherStatus.paid);
      expect(VoucherModel.fromJson({'status': 'REDEEMED'}).status,
          VoucherStatus.redeemed);
      expect(VoucherModel.fromJson({'status': 'Expired'}).status,
          VoucherStatus.expired);
      expect(VoucherModel.fromJson({'status': 'cancelled'}).status,
          VoucherStatus.cancelled);
    });

    test('estado desconocido o ausente cae en pending', () {
      expect(VoucherModel.fromJson({'status': 'wat'}).status,
          VoucherStatus.pending);
      expect(VoucherModel.fromJson({}).status, VoucherStatus.pending);
    });
  });

  group('VoucherModel objetos anidados', () {
    test('extrae ids de user/store/product como objetos', () {
      final v = VoucherModel.fromJson({
        'id': 'v1',
        'user': {'id': 'u1', 'name': 'Juan', 'email': 'j@x.com'},
        'store': {'id': 's1', 'name': 'Tienda'},
        'product': {'id': 'p1', 'name': 'Café', 'sku': 'CAF'},
      });
      expect(v.customerUserId, 'u1');
      expect(v.storeId, 's1');
      expect(v.productId, 'p1');
      expect(v.customerName, 'Juan');
      expect(v.storeName, 'Tienda');
      expect(v.productName, 'Café');
      expect(v.productSku, 'CAF');
    });

    test('extrae ids cuando vienen como valor plano', () {
      final v = VoucherModel.fromJson({
        'user': 'u9',
        'store': 's9',
        'product': 'p9',
      });
      expect(v.customerUserId, 'u9');
      expect(v.storeId, 's9');
      expect(v.productId, 'p9');
      expect(v.customerName, isNull);
    });
  });

  group('VoucherModel getters', () {
    test('isRedeemed refleja el estado', () {
      expect(VoucherModel.fromJson({'status': 'redeemed'}).isRedeemed, true);
      expect(VoucherModel.fromJson({'status': 'pending'}).isRedeemed, false);
    });

    test('isExpired true si estado es expired', () {
      final v = VoucherModel.fromJson({'status': 'expired'});
      expect(v.isExpired, true);
    });

    test('isExpired true si expires_at es pasado', () {
      final v = VoucherModel.fromJson({
        'expires_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(v.isExpired, true);
    });

    test('isExpired false para expires_at futuro y estado activo', () {
      final v = VoucherModel.fromJson({
        'status': 'paid',
        'expires_at':
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      });
      expect(v.isExpired, false);
    });

    test('createdAt es alias de issuedAt', () {
      final iso = '2025-01-01T10:00:00.000';
      final v = VoucherModel.fromJson({'issued_at': iso});
      expect(v.createdAt, v.issuedAt);
      expect(v.issuedAt, DateTime.parse(iso));
    });

    test('acepta discount_percentage o discount_percent', () {
      expect(
          VoucherModel.fromJson({'discount_percentage': 15}).discountPercent,
          15);
      expect(VoucherModel.fromJson({'discount_percent': 20}).discountPercent,
          20);
    });
  });
}
