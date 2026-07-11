import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/withdrawal_model.dart';

void main() {
  group('PayoutMethod', () {
    test('fromJson normaliza country/currency a mayúsculas', () {
      final m = PayoutMethod.fromJson({
        'id': '1',
        'country': 'es',
        'currency': 'eur',
        'account_holder_name': 'Ana',
        'account_number': '****1234',
        'is_default': true,
      });
      expect(m.country, 'ES');
      expect(m.currency, 'EUR');
      expect(m.isDefault, true);
    });

    test('shortLabel usa últimos 4 dígitos', () {
      const m = PayoutMethod(
        id: '1',
        country: 'ES',
        currency: 'EUR',
        accountHolderName: 'Ana',
        accountNumber: 'ES9820385778981234',
      );
      expect(m.shortLabel, '····1234 · EUR');
    });

    test('shortLabel con número corto no rompe', () {
      const m = PayoutMethod(
        id: '1',
        country: 'ES',
        currency: 'USD',
        accountHolderName: 'Ana',
        accountNumber: '12',
      );
      expect(m.shortLabel, '····12 · USD');
    });
  });

  group('WithdrawalModel', () {
    test('parsea status conocidos y default pending', () {
      expect(WithdrawalModel.fromJson({'status': 'completed'}).status,
          WithdrawalStatus.completed);
      expect(WithdrawalModel.fromJson({'status': 'FAILED'}).status,
          WithdrawalStatus.failed);
      expect(WithdrawalModel.fromJson({'status': 'cancelled'}).status,
          WithdrawalStatus.cancelled);
      expect(WithdrawalModel.fromJson({'status': 'raro'}).status,
          WithdrawalStatus.pending);
    });

    test('extrae método embebido como objeto', () {
      final w = WithdrawalModel.fromJson({
        'id': 'w1',
        'amount': '25.5',
        'payout_method': {'id': 'm1', 'account_number': '****9999'},
      });
      expect(w.amount, 25.5);
      expect(w.payoutMethodId, 'm1');
      expect(w.destinationLabel, '****9999');
    });

    test('método como UUID plano', () {
      final w = WithdrawalModel.fromJson({'method': 'm-plain'});
      expect(w.payoutMethodId, 'm-plain');
    });
  });

  group('WithdrawalConfig', () {
    test('hasInstant depende de instantLimit', () {
      expect(WithdrawalConfig.fromJson({'instant_limit': 50}).hasInstant, true);
      expect(WithdrawalConfig.fromJson({'instant_limit': 0}).hasInstant, false);
    });

    test('defaultMethod devuelve el marcado por defecto', () {
      final cfg = WithdrawalConfig.fromJson({
        'available_methods': [
          {'id': 'a', 'is_default': false, 'account_number': '1'},
          {'id': 'b', 'is_default': true, 'account_number': '2'},
        ],
      });
      expect(cfg.defaultMethod?.id, 'b');
    });

    test('defaultMethod cae al primero si ninguno es default', () {
      final cfg = WithdrawalConfig.fromJson({
        'available_methods': [
          {'id': 'a', 'account_number': '1'},
          {'id': 'b', 'account_number': '2'},
        ],
      });
      expect(cfg.defaultMethod?.id, 'a');
    });

    test('defaultMethod null si no hay métodos', () {
      expect(WithdrawalConfig.fromJson({}).defaultMethod, isNull);
    });

    test('copyWithBalance solo cambia el saldo', () {
      final cfg = WithdrawalConfig.fromJson({
        'min_amount': 10,
        'max_amount': 500,
        'available_balance': 100,
        'is_verified': true,
      });
      final updated = cfg.copyWithBalance(250);
      expect(updated.availableBalance, 250);
      expect(updated.minAmount, cfg.minAmount);
      expect(updated.maxAmount, cfg.maxAmount);
      expect(updated.isVerified, cfg.isVerified);
    });
  });
}
