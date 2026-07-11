import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/models/paginated.dart';

void main() {
  group('PageMeta', () {
    test('fromJson con tipos mixtos', () {
      final m = PageMeta.fromJson({'total': '30', 'page': 2, 'lastPage': '5'});
      expect(m.total, 30);
      expect(m.page, 2);
      expect(m.lastPage, 5);
    });

    test('valores por defecto ante json vacío', () {
      final m = PageMeta.fromJson({});
      expect(m.total, 0);
      expect(m.page, 1);
      expect(m.lastPage, 1);
    });

    test('hasMore true cuando page < lastPage', () {
      expect(const PageMeta(page: 1, lastPage: 3).hasMore, true);
    });

    test('hasMore false en la última página', () {
      expect(const PageMeta(page: 3, lastPage: 3).hasMore, false);
    });
  });

  group('Paginated<T>', () {
    test('mapea data usando itemFromJson', () {
      final page = Paginated<String>.fromJson({
        'data': [
          {'v': 'a'},
          {'v': 'b'},
        ],
        'meta': {'total': 2, 'page': 1, 'lastPage': 1},
      }, (m) => m['v'] as String);

      expect(page.data, ['a', 'b']);
      expect(page.meta.total, 2);
    });

    test('data vacía y meta ausente son seguras', () {
      final page = Paginated<String>.fromJson({}, (m) => m.toString());
      expect(page.data, isEmpty);
      expect(page.meta.total, 0);
      expect(page.meta.page, 1);
    });

    test('ignora entradas no-Map dentro de data', () {
      final page = Paginated<String>.fromJson({
        'data': [
          {'v': 'ok'},
          'basura',
          123,
        ],
      }, (m) => m['v'] as String);
      expect(page.data, ['ok']);
    });
  });
}
