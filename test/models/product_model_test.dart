import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parsea campos básicos y tipos mixtos (string/num)', () {
      final p = ProductModel.fromJson({
        'id': 42,
        'name': 'Café gratis',
        'description': 'Un café',
        'image_url': 'http://x/img.png',
        'category': 'Bebidas',
        'sku': 'SKU-1',
        'price': '10.0',
        'discount': 20,
        'stock': '5',
        'store': 'store-1',
        'type': 'descuento',
      });

      expect(p.id, '42');
      expect(p.name, 'Café gratis');
      expect(p.image, 'http://x/img.png');
      expect(p.category, 'Bebidas');
      expect(p.originalPrice, 10.0);
      expect(p.discountPercent, 20);
      expect(p.stock, 5);
      expect(p.quantity, 5);
      expect(p.storeId, 'store-1');
    });

    test('calcula final_price a partir del descuento cuando no viene', () {
      final p = ProductModel.fromJson({'price': 100, 'discount': 25});
      // 100 * (1 - 25/100) = 75
      expect(p.discountPrice, 75.0);
    });

    test('respeta final_price explícito del backend', () {
      final p = ProductModel.fromJson({
        'price': 100,
        'discount': 25,
        'final_price': 60,
      });
      expect(p.discountPrice, 60.0);
    });

    test('sin descuento, final_price == price', () {
      final p = ProductModel.fromJson({'price': 40});
      expect(p.discountPrice, 40.0);
    });

    test('usa valores por defecto seguros ante json vacío', () {
      final p = ProductModel.fromJson({});
      expect(p.id, '');
      expect(p.name, '');
      expect(p.originalPrice, 0);
      expect(p.isPublished, true);
      expect(p.isRedeemable, true);
      expect(p.type, 'descuento');
    });

    test('acepta claves alternativas (image, category_name, store_id)', () {
      final p = ProductModel.fromJson({
        'image': 'legacy.png',
        'category_name': 'Ocio',
        'store_id': 's-9',
      });
      expect(p.image, 'legacy.png');
      expect(p.category, 'Ocio');
      expect(p.storeId, 's-9');
    });
  });

  group('ProductModel getters derivados', () {
    test('statusLabel prioriza Sin Stock sobre pausado', () {
      final p = ProductModel.fromJson({'stock': 0, 'is_published': false});
      expect(p.statusLabel, 'Sin Stock');
    });

    test('statusLabel Pausado cuando no publicado y con stock', () {
      final p = ProductModel.fromJson({'stock': 3, 'is_published': false});
      expect(p.statusLabel, 'Pausado');
    });

    test('statusLabel Activo cuando publicado y con stock', () {
      final p = ProductModel.fromJson({'stock': 3, 'is_published': true});
      expect(p.statusLabel, 'Activo');
    });

    test('isExpired true para fecha pasada', () {
      final p = ProductModel.fromJson({
        'expiry_date':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(p.isExpired, true);
      expect(p.isExpiringSoon, false);
    });

    test('isExpiringSoon true dentro de 30 días', () {
      final p = ProductModel.fromJson({
        'expires_at':
            DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      });
      expect(p.isExpired, false);
      expect(p.isExpiringSoon, true);
    });

    test('isExpiringSoon false para fecha lejana', () {
      final p = ProductModel.fromJson({
        'expiry_date':
            DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      });
      expect(p.isExpiringSoon, false);
    });

    test('sin expiryDate no está expirado ni por expirar', () {
      final p = ProductModel.fromJson({});
      expect(p.isExpired, false);
      expect(p.isExpiringSoon, false);
    });

    test('price es alias de discountPrice', () {
      final p = ProductModel.fromJson({'price': 100, 'discount': 10});
      expect(p.price, p.discountPrice);
    });
  });

  group('ProductModel.toJson', () {
    test('roundtrip preserva campos clave', () {
      final original = ProductModel.fromJson({
        'id': '1',
        'name': 'X',
        'price': 50,
        'discount': 10,
        'stock': 7,
        'store': 's1',
        'is_published': false,
        'type': 'beneficio',
      });
      final j = original.toJson();
      final restored = ProductModel.fromJson(j);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.originalPrice, original.originalPrice);
      expect(restored.discountPercent, original.discountPercent);
      expect(restored.isPublished, original.isPublished);
      expect(restored.type, original.type);
    });
  });
}
