import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/category_item.dart';
import '../../../components/custom_form_field.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/dark_transition.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    return DarkTransition(
      offset: Offset(context.width, -1),
      isDark: !controller.isLightTheme,
      builder: (context, _) => Scaffold(
        body: isDesktop
            ? _desktopLayout(context)
            : _mobileLayout(context),
      ),
    );
  }

  // ─── DESKTOP ───────────────────────────────────────────────────────────────

  Widget _desktopLayout(BuildContext context) {
    return Column(
      children: [
        _heroBanner(context, tall: true),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: SingleChildScrollView(
                  child: _sidebarContent(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: _mainContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidebarContent(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorías', style: theme.textTheme.headlineSmall),
          14.verticalSpace,
          Obx(() => Column(
                children: [
                  _sidebarItem(
                    context,
                    icon: Icons.apps_rounded,
                    label: 'Todas',
                    count: controller.products.length,
                    selected: controller.selectedCategoryId.value == -1,
                    onTap: () => controller.selectedCategoryId.value = -1,
                  ),
                  ...controller.categories.map((c) => _sidebarItem(
                        context,
                        icon: _catIcon(c.title),
                        label: c.title,
                        count: controller.products
                            .where((p) =>
                                p.category.toLowerCase() ==
                                c.title.toLowerCase())
                            .length,
                        selected: controller.selectedCategoryId.value == c.id,
                        onTap: () =>
                            controller.selectedCategoryId.value = c.id,
                      )),
                ],
              )),
          24.verticalSpace,
          Obx(() {
            final stats = controller.ordersStats.value;
            if (stats == null) return const SizedBox.shrink();
            return _objetivoCard(context, stats);
          }),
          16.verticalSpace,
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : theme.iconTheme.color),
            9.horizontalSpace,
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? Colors.white : null,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : theme.primaryColorDark,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : theme.primaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _objetivoCard(BuildContext context, OrdersStats stats) {
    final theme = context.theme;
    const nextTarget = 3000;
    final remaining = nextTarget > stats.currentPoints
        ? nextTarget - stats.currentPoints
        : 0;
    final progress = (stats.currentPoints / nextTarget).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Próximo objetivo',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          8.verticalSpace,
          Text(
            'Faltan $remaining pts para el Smartwatch',
            style: theme.textTheme.bodySmall,
          ),
          10.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainContent(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Destacados', style: theme.textTheme.headlineMedium),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ordenar por:', style: theme.textTheme.bodySmall),
                    4.horizontalSpace,
                    Text(
                      'Populares',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.horizontalSpace,
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: theme.primaryColor),
                  ],
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Obx(() {
            final all = _visibleProducts;
            if (all.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(40.r),
                  child: CircularProgressIndicator(
                      color: theme.primaryColor),
                ),
              );
            }
            final featured = all.first;
            final rest = all.skip(1).take(3).toList();
            return LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _featuredCard(context, featured),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: rest
                            .map((p) => Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: _smallProductCard(context, p),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: all
                    .map((p) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _smallProductCard(context, p),
                        ))
                    .toList(),
              );
            });
          }),
          24.verticalSpace,
          Center(
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(Routes.PRODUCTS),
              icon: const Icon(Icons.keyboard_arrow_down),
              label: const Text('Ver más productos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r)),
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ),
          20.verticalSpace,
        ],
      ),
    );
  }

  List<ProductModel> get _visibleProducts {
    final cat = controller.selectedCategoryId.value;
    if (cat == -1) return controller.products;
    final catTitle = controller.categories
        .firstWhereOrNull((c) => c.id == cat)
        ?.title;
    if (catTitle == null) return controller.products;
    return controller.products
        .where((p) => p.category.toLowerCase() == catTitle.toLowerCase())
        .toList();
  }

  Widget _featuredCard(BuildContext context, ProductModel product) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product),
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: _productImage(product.image, BoxFit.cover),
              ),
            ),
            // Bottom overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.storeName != null)
                            Row(
                              children: [
                                const Icon(Icons.storefront,
                                    size: 10, color: Colors.white70),
                                4.horizontalSpace,
                                Text(
                                  (product.storeName ?? '').toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          4.verticalSpace,
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${product.price.toInt()} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Badge
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(
                  'Hot Deal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallProductCard(BuildContext context, ProductModel product) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 64.w,
                height: 64.h,
                child: _productImage(product.image, BoxFit.cover),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category.isNotEmpty)
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  4.verticalSpace,
                  Text(
                    product.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.storeName != null) ...[
                    2.verticalSpace,
                    Row(
                      children: [
                        Icon(Icons.storefront,
                            size: 10, color: theme.iconTheme.color),
                        4.horizontalSpace,
                        Expanded(
                          child: Text(product.storeName!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  6.verticalSpace,
                  Row(
                    children: [
                      Text(
                        '${product.price.toInt()} pts',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: theme.primaryColor,
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HERO BANNER ───────────────────────────────────────────────────────────

  Widget _heroBanner(BuildContext context, {required bool tall}) {
    final theme = context.theme;
    final height = tall ? 230.h : 175.h;
    final bg = controller.cards.isNotEmpty ? controller.cards[0] : null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bg != null)
            Image.asset(bg, fit: BoxFit.cover)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.28),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    'Marketplace Exclusivo',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                10.verticalSpace,
                Text(
                  tall
                      ? 'Canjea tus puntos\npor premios increíbles'
                      : 'Canjea tus puntos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: tall ? 24.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                6.verticalSpace,
                Text(
                  'Explora tecnología, moda y experiencias\npara recompensar tu lealtad.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                    height: 1.4,
                  ),
                ),
                14.verticalSpace,
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Text('Explorar ahora',
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ),
                    10.horizontalSpace,
                    OutlinedButton(
                      onPressed: () => Get.toNamed(Routes.CALENDAR),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                      ),
                      child: Text('Ver misiones',
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _mobileLayout(BuildContext context) {
    final theme = context.theme;
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          child: SvgPicture.asset(
            Constants.container,
            fit: BoxFit.fill,
            colorFilter:
              ColorFilter.mode(theme.canvasColor, BlendMode.srcIn),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ListView(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                title: Text('Buenos días',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: 12.sp)),
                subtitle: Text('Bienvenido',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.normal)),
                leading: Obx(() {
                  final imageBytes = controller.profileImageBytes;
                  return CircleAvatar(
                    radius: 22.r,
                    backgroundColor: theme.primaryColorDark,
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : null,
                    child: imageBytes == null
                        ? ClipOval(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(Constants.avatar),
                            ),
                          )
                        : null,
                  );
                }),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconButton(
                      onPressed: () => Get.toNamed(Routes.PROFILE),
                      backgroundColor: theme.primaryColorDark,
                      icon: Icon(Icons.settings_outlined,
                          color: theme.appBarTheme.iconTheme?.color, size: 20),
                    ),
                    8.horizontalSpace,
                    CustomIconButton(
                      onPressed: () => controller.onChangeThemePressed(),
                      backgroundColor: theme.primaryColorDark,
                      icon: GetBuilder<HomeController>(
                        id: 'Theme',
                        builder: (_) => Icon(
                          controller.isLightTheme
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: theme.appBarTheme.iconTheme?.color,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: CustomFormField(
                  backgroundColor: theme.primaryColorDark,
                  textSize: 14.sp,
                  hint: 'Buscar en el marketplace...',
                  hintFontSize: 14.sp,
                  hintColor: theme.hintColor,
                  maxLines: 1,
                  borderRound: 60.r,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h, horizontal: 10.w),
                  focusedBorderColor: Colors.transparent,
                  isSearchField: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  prefixIcon:
                      SvgPicture.asset(Constants.searchIcon, fit: BoxFit.none),
                ),
              ),
              14.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: _heroBanner(context, tall: false),
                ),
              ),
              16.verticalSpace,
              Obx(() {
                final stats = controller.ordersStats.value;
                if (stats == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _mobileStatsCard(context, stats),
                );
              }),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categorías',
                            style: theme.textTheme.headlineMedium),
                        Text('Ver todo',
                            style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                    16.verticalSpace,
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: controller.categories
                              .map((c) => CategoryItem(category: c))
                              .toList(),
                        )),
                    20.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Destacados',
                            style: theme.textTheme.headlineMedium),
                        Text('Ver todo',
                            style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                    16.verticalSpace,
                    LayoutBuilder(builder: (context, constraints) {
                      int columns = 2;
                      if (constraints.maxWidth >= 960) {
                        columns = 4;
                      } else if (constraints.maxWidth >= 640) {
                        columns = 3;
                      }
                      return Obx(() {
                        final items = controller.products;
                        final visible = items.length < 2 ? items.length : 2;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            mainAxisExtent: 214.h,
                          ),
                          shrinkWrap: true,
                          primary: false,
                          itemCount: visible,
                          itemBuilder: (context, index) =>
                              _mobileProductCard(context, items[index]),
                        );
                      });
                    }),
                    20.verticalSpace,
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(Routes.PRODUCTS),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      label: const Text('Ver más productos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                      ),
                    ),
                    20.verticalSpace,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileProductCard(BuildContext context, ProductModel product) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
            Positioned(
              top: 22.h,
              left: 26.w,
              right: 25.w,
              child: _productImage(product.image, BoxFit.contain),
            ),
            Positioned(
              left: 16.w,
              bottom: 24.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: theme.textTheme.titleLarge),
                  5.verticalSpace,
                  Text(
                    '${product.price.toInt()} pts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileStatsCard(BuildContext context, OrdersStats stats) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.75),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
              8.horizontalSpace,
              Text('Mis puntos',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          8.verticalSpace,
          Text('${stats.currentPoints}',
              style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          12.verticalSpace,
          Row(
            children: [
              Expanded(
                  child: _statTile('Compras', '${stats.totalOrders}')),
              Expanded(
                  child: _statTile('Gastado',
                      '\$${stats.totalSpent.toStringAsFixed(2)}')),
              Expanded(
                  child: _statTile('Ahorrado',
                      '\$${stats.totalSaved.toStringAsFixed(2)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        2.verticalSpace,
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Widget _productImage(String src, BoxFit fit) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(src, fit: fit,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_outlined, size: 32));
    }
    return Image.asset(src, fit: fit,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_outlined, size: 32));
  }

  IconData _catIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('comida') || t.contains('food')) {
      return Icons.restaurant_outlined;
    }
    if (t.contains('tecno') || t.contains('tech')) {
      return Icons.devices_outlined;
    }
    if (t.contains('moda') || t.contains('ropa') || t.contains('fashion')) {
      return Icons.checkroom_outlined;
    }
    if (t.contains('experiencia') || t.contains('experience')) {
      return Icons.theater_comedy_outlined;
    }
    return Icons.category_outlined;
  }
}
