import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/booking_model.dart';

void main() {
  group('BookingModel._parseStatus', () {
    test('RESERVED/CONFIRMED → active', () {
      expect(BookingModel.fromJson({'status': 'RESERVED'}).status,
          BookingStatus.active);
      expect(BookingModel.fromJson({'status': 'confirmed'}).status,
          BookingStatus.active);
    });

    test('PENDING → upcoming', () {
      expect(BookingModel.fromJson({'status': 'PENDING'}).status,
          BookingStatus.upcoming);
    });

    test('EXPIRED → completed', () {
      expect(BookingModel.fromJson({'status': 'EXPIRED'}).status,
          BookingStatus.completed);
    });

    test('CANCELLED → cancelled', () {
      expect(BookingModel.fromJson({'status': 'CANCELLED'}).status,
          BookingStatus.cancelled);
    });

    test('desconocido → upcoming', () {
      expect(BookingModel.fromJson({'status': 'ZZZ'}).status,
          BookingStatus.upcoming);
    });
  });

  group('BookingModel spot embebido', () {
    test('extrae datos del spot como objeto', () {
      final b = BookingModel.fromJson({
        'id': 'b1',
        'spot': {
          'id': 's1',
          'address': 'Calle Mayor 1',
          'name': 'Plaza A',
          'price': '2.5',
          'spot_type': 'paid',
        },
        'status': 'RESERVED',
      });
      expect(b.spotId, 's1');
      expect(b.address, 'Calle Mayor 1');
      expect(b.spotName, 'Plaza A');
      expect(b.pricePerHour, 2.5);
      expect(b.spotType, 'paid');
    });

    test('spot como UUID plano con fallbacks planos', () {
      final b = BookingModel.fromJson({
        'spot': 's-plain',
        'address': 'Fallback St',
        'spot_name': 'Plaza B',
        'spot_type': 'free',
      });
      expect(b.spotId, 's-plain');
      expect(b.address, 'Fallback St');
      expect(b.spotName, 'Plaza B');
      expect(b.spotType, 'free');
    });
  });

  group('BookingModel.spotTypeLabel', () {
    BookingModel withType(String? t) =>
        BookingModel.fromJson({'spot': {'spot_type': t}});

    test('traduce tipos conocidos', () {
      expect(withType('paid').spotTypeLabel, 'Plaza de pago');
      expect(withType('free').spotTypeLabel, 'Plaza gratuita');
      expect(withType('private').spotTypeLabel, 'Garaje privado');
      expect(withType('underground').spotTypeLabel, 'Plaza subterránea');
      expect(withType('park_and_ride').spotTypeLabel, 'Park & Ride');
    });

    test('tipo desconocido devuelve el raw o vacío', () {
      expect(withType('otro').spotTypeLabel, 'otro');
      expect(BookingModel.fromJson({}).spotTypeLabel, '');
    });
  });
}
