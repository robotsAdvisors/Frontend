import 'package:get/get.dart';

import '../controllers/customer_points_controller.dart';
import '../controllers/customer_search_controller.dart';

/// Binding del buscador de clientes.
class PointsSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerSearchController>(() => CustomerSearchController(),
        fenix: true);
  }
}

/// Binding de la ficha de un cliente. Se crea una instancia NUEVA en cada
/// navegación para que lea los `Get.arguments` del cliente elegido.
class PointsDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerPointsController>(CustomerPointsController());
  }
}
