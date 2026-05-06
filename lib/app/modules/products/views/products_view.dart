import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_form_field.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/product_item.dart';
import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isWide = MediaQuery.of(context).size.width >= 1100;
    final double contentMaxWidth = isWide ? 1120 : double.infinity;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButton(
                onPressed: () => Get.back(),
                backgroundColor: theme.cardColor,
                borderColor: theme.dividerColor,
                icon: SvgPicture.asset(
                  Constants.backArrowIcon,
                  fit: BoxFit.none,
                  color: theme.appBarTheme.iconTheme?.color,
                ),
              ),
              Text(
                'Marketplace',
                style: theme.textTheme.headline3,
              ),
              CustomIconButton(
                onPressed: () => controller.clearSearch(),
                backgroundColor: theme.cardColor,
                borderColor: theme.dividerColor,
                icon: SvgPicture.asset(
                  Constants.searchIcon,
                  fit: BoxFit.none,
                  color: theme.appBarTheme.iconTheme?.color,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFormField(
              hint: 'Buscar productos',
              isSearchField: true,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              borderRound: 30.r,
              backgroundColor: theme.primaryColorDark,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: SvgPicture.asset(
                  Constants.searchIcon,
                  fit: BoxFit.none,
                  color: theme.hintColor,
                ),
              ),
              onChanged: (value) => controller.onSearchChanged(value ?? ''),
              onCanceled: () => controller.clearSearch(),
            ),
            16.verticalSpace,
            Obx(
              () => Text(
                '${controller.filteredProducts.length} productos encontrados',
                style: theme.textTheme.caption,
              ),
            ),
            10.verticalSpace,
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.categories.map((category) {
                    final isSelected = controller.selectedCategory.value == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: theme.primaryColor.withOpacity(0.16),
                        labelStyle: theme.textTheme.bodyText2?.copyWith(
                          color: isSelected ? theme.primaryColor : theme.textTheme.bodyText2?.color,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => controller.onCategorySelected(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            16.verticalSpace,
            Expanded(
              child: Obx(
                () {
                  final items = controller.filteredProducts;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay productos para el filtro seleccionado.',
                        style: theme.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int columns = 2;
                      if (constraints.maxWidth >= 960) {
                        columns = 4;
                      } else if (constraints.maxWidth >= 640) {
                        columns = 3;
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          mainAxisExtent: 214.h,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => ProductItem(
                          product: items[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
