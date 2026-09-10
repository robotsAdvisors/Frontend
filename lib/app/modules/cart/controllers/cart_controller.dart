import 'package:get/get.dart';

import '../../../../utils/app_config.dart';
import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/services/http/api_client.dart';
import '../../base/controllers/base_controller.dart';

class CartController extends GetxController {

  /// Productos visibles en el carrito.
  RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    getCartProducts();
    super.onInit();
  }

  /// Crea UN pedido con todo el carrito (POST /marketplace/orders/).
  ///
  /// El pedido nace PENDING: reserva stock y puntos, pero no esta pagado. El
  /// cobro se hace despues contra su PaymentIntent, y de eso todavia no hay
  /// pantalla en el backoffice, asi que aqui solo se registra el pedido y se
  /// dice tal cual.
  ///
  /// Antes se llamaba una vez por producto a `purchaseWithRedeem` /
  /// `purchaseWithoutRedeem` (eliminados del backend: creaban el pedido como
  /// PAID sin verificar pago alguno) y se anunciaba "Compra realizada" sin
  /// mirar la respuesta, asi que un `requires_payment` pasaba por exito
  /// habiendo creado cero pedidos.
  Future<void> onPurchaseNowPressed({bool useRedeem = false}) async {
    if (products.isEmpty) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Carrito vacio',
        message: 'No hay productos para comprar',
      );
      return;
    }

    isProcessing.value = true;
    try {
      // Un pedido = un comercio: el backend rechaza el carrito mezclado, porque
      // el cobro va con destino a la cuenta Connect de la tienda.
      await MarketplaceRepository.instance.createOrder(
        items: products
            .map((p) => {'product_id': p.id, 'quantity': p.quantity})
            .toList(),
        usePoints: useRedeem,
      );

      clearCart();
      Get.back();
      CustomSnackBar.showCustomSnackBar(
        title: 'Pedido creado',
        message: 'Queda pendiente de pago',
      );
    } on ApiException catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.message,
      );
    } catch (e) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// get the cart products from the product list
  // NOTA: el carrito aún se apoya en [DummyHelper] como estado en memoria y no
  // está cableado al backend. En builds reales arranca vacío (no muestra los
  // productos de demostración) hasta que exista un carrito real.
  getCartProducts() {
    products.assignAll(
      AppConfig.useDummyData
          ? DummyHelper.products.where((p) => p.quantity > 0).toList()
          : <ProductModel>[],
    );
    update();
  }

  /// clear products in cart and reset cart items count
  clearCart() {
    if (AppConfig.useDummyData) {
      for (final p in DummyHelper.products) {
        p.quantity = 0;
      }
    }
    products.clear();
    Get.find<BaseController>().getCartItemsCount();
  }
}