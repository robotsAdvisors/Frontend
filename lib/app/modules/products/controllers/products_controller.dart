import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../data/models/product_model.dart';

class ProductsController extends GetxController {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    getProducts();
    super.onInit();
  }

  /// get products from dummy helper
  getProducts() {
    products.assignAll(DummyHelper.products);
  }

  List<String> get categories {
    final values = products.map((product) => product.category).toSet().toList();
    values.sort();
    return ['All', ...values];
  }

  List<ProductModel> get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory.value == 'All' || product.category == selectedCategory.value;
      final term = searchQuery.value.trim().toLowerCase();
      if (term.isEmpty) {
        return matchesCategory;
      }
      final matchesText = product.name.toLowerCase().contains(term) ||
          product.description.toLowerCase().contains(term) ||
          product.sku.toLowerCase().contains(term) ||
          product.category.toLowerCase().contains(term);
      return matchesCategory && matchesText;
    }).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
  }
}
