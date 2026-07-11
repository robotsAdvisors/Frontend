import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letdem/app/data/local/my_shared_pref.dart';
import 'package:letdem/app/data/repositories/marketplace_repository.dart';
import 'package:letdem/app/data/services/http/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adaptador HTTP falso: mapea la ruta pedida a una respuesta predefinida.
/// Permite ejercitar el parseo del repositorio sin red real.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  /// Recibe la ruta y devuelve (statusCode, body json-encodable).
  final (int, Object?) Function(RequestOptions options) handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Adaptador que simula un fallo de red (DioException real).
class _ThrowingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'sin conexión',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MySharedPref.init();
  });

  tearDown(() {
    // Restaura un adaptador real para no filtrar el fake entre tests.
    ApiClient.instance.dio.httpClientAdapter = IOHttpClientAdapter();
  });

  void mock((int, Object?) Function(RequestOptions) handler) {
    ApiClient.instance.dio.httpClientAdapter = _FakeAdapter(handler);
  }

  final repo = MarketplaceRepository.instance;

  group('fetchProducts', () {
    test('parsea envelope {data: [...]}', () async {
      mock((opts) => (200, {
            'data': [
              {'id': 'p1', 'name': 'Café', 'price': 10, 'store': 's1'},
              {'id': 'p2', 'name': 'Té', 'price': 5, 'store': 's1'},
            ],
          }));

      final products = await repo.fetchProducts();
      expect(products, hasLength(2));
      expect(products.first.name, 'Café');
      expect(products.first.originalPrice, 10);
    });

    test('parsea paginación DRF {results: [...]}', () async {
      mock((opts) => (200, {
            'results': [
              {'id': 'p9', 'name': 'Zumo', 'price': 3, 'store': 's1'},
            ],
          }));

      final products = await repo.fetchProducts();
      expect(products, hasLength(1));
      expect(products.single.id, 'p9');
    });

    test('lista vacía ante respuesta inesperada', () async {
      mock((opts) => (200, {'unexpected': true}));
      final products = await repo.fetchProducts();
      expect(products, isEmpty);
    });

    // NOTA DE COMPORTAMIENTO: ApiClient usa validateStatus (status) => status != null,
    // por lo que Dio NO lanza en 4xx/5xx. Un 500 con cuerpo no-lista degrada a
    // lista vacía en lugar de propagar un error a la UI.
    test('un 500 con HTML degrada a lista vacía (errores HTTP no lanzan)',
        () async {
      mock((opts) => (500, '<html>error</html>'));
      final products = await repo.fetchProducts();
      expect(products, isEmpty);
    });

    test('un fallo de red genuino sí lanza ApiException', () async {
      ApiClient.instance.dio.httpClientAdapter = _ThrowingAdapter();
      expect(
        () => repo.fetchProducts(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('fetchProductsPage', () {
    test('expone meta de paginación', () async {
      mock((opts) => (200, {
            'data': [
              {'id': 'p1', 'name': 'A', 'price': 1, 'store': 's1'},
            ],
            'meta': {'total': 25, 'page': 2, 'lastPage': 5},
          }));

      final page = await repo.fetchProductsPage(page: 2);
      expect(page.data, hasLength(1));
      expect(page.meta.total, 25);
      expect(page.meta.page, 2);
      expect(page.meta.hasMore, true);
    });

    test('lista plana se envuelve en una sola página', () async {
      mock((opts) => (200, [
            {'id': 'p1', 'name': 'A', 'price': 1, 'store': 's1'},
            {'id': 'p2', 'name': 'B', 'price': 2, 'store': 's1'},
          ]));

      final page = await repo.fetchProductsPage();
      expect(page.data, hasLength(2));
      expect(page.meta.total, 2);
      expect(page.meta.page, 1);
      expect(page.meta.hasMore, false);
    });
  });

  group('fetchProductDetail', () {
    test('devuelve modelo ante Map 200', () async {
      mock((opts) => (200, {'id': 'p1', 'name': 'Detalle', 'store': 's1'}));
      final product = await repo.fetchProductDetail('p1');
      expect(product, isNotNull);
      expect(product!.name, 'Detalle');
    });
  });
}
