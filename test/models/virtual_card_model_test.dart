import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/virtual_card_model.dart';

void main() {
  group('VirtualCardModel.fromJson', () {
    test('parsea campos y benefits anidados', () {
      final c = VirtualCardModel.fromJson({
        'card_code': 'LD-1',
        'cardholder_name': 'Ana Pérez',
        'tier': 'PREMIUM',
        'points_balance': '1200',
        'is_active': true,
        'benefits': [
          {'id': 'b1', 'key': 'ev_boost', 'title': 'EV', 'description': 'd'},
        ],
      });
      expect(c.cardCode, 'LD-1');
      expect(c.cardholderName, 'Ana Pérez');
      expect(c.tier, 'premium'); // normalizado a minúsculas
      expect(c.pointsBalance, 1200);
      expect(c.benefits, hasLength(1));
      expect(c.benefits.first.key, 'ev_boost');
    });

    test('acepta claves alternativas (code, full_name, points)', () {
      final c = VirtualCardModel.fromJson({
        'code': 'LD-2',
        'full_name': 'Bob',
        'points': 5,
      });
      expect(c.cardCode, 'LD-2');
      expect(c.cardholderName, 'Bob');
      expect(c.pointsBalance, 5);
    });

    test('defaults seguros', () {
      final c = VirtualCardModel.fromJson({});
      expect(c.tier, 'standard');
      expect(c.pointsBalance, 0);
      expect(c.isActive, true);
      expect(c.benefits, isEmpty);
    });
  });

  group('VirtualCardModel.tierLabel', () {
    test('etiquetas por tier', () {
      expect(VirtualCardModel.fromJson({'tier': 'premium'}).tierLabel,
          'PREMIUM MEMBER');
      expect(VirtualCardModel.fromJson({'tier': 'basic'}).tierLabel,
          'BASIC MEMBER');
      expect(VirtualCardModel.fromJson({'tier': 'standard'}).tierLabel,
          'STANDARD MEMBER');
      expect(VirtualCardModel.fromJson({'tier': 'otro'}).tierLabel,
          'STANDARD MEMBER');
    });
  });

  group('VirtualCardModel.copyWith', () {
    test('solo cambia isActive y preserva el resto', () {
      final c = VirtualCardModel.fromJson({
        'card_code': 'LD-9',
        'tier': 'premium',
        'points_balance': 10,
        'is_active': true,
      });
      final updated = c.copyWith(isActive: false);
      expect(updated.isActive, false);
      expect(updated.cardCode, 'LD-9');
      expect(updated.tier, 'premium');
      expect(updated.pointsBalance, 10);
    });
  });

  group('CardBenefit.fromJson', () {
    test('acepta key/type y title/name', () {
      final b = CardBenefit.fromJson({'type': 't', 'name': 'n'});
      expect(b.key, 't');
      expect(b.title, 'n');
    });
  });
}
