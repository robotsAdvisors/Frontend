import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/category_item.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_form_field.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/dark_transition.dart';
import '../../../components/product_item.dart';
import '../../../data/models/order_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isWide = MediaQuery.of(context).size.width >= 1100;
    final double contentMaxWidth = isWide ? 1120 : double.infinity;
    return DarkTransition(
      offset: Offset(context.width, -1),
      isDark: !controller.isLightTheme,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -100.h,
              child: SvgPicture.asset(
                Constants.container,
                fit: BoxFit.fill,
                color: theme.canvasColor,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: ListView(
                  children: [
                    Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                      title: Text(
                        'Buenos dias',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp
                        ),
                      ),
                      subtitle: Text(
                        'Amelia Barlow',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      leading: Obx(() {
                        final imageBytes = controller.profileImageBytes;
                        return CircleAvatar(
                          radius: 22.r,
                          backgroundColor: theme.primaryColorDark,
                          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
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
                            icon: Icon(
                              Icons.settings_outlined,
                              color: theme.appBarTheme.iconTheme?.color,
                              size: 20,
                            ),
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
                        hint: 'Search category',
                        hintFontSize: 14.sp,
                        hintColor: theme.hintColor,
                        maxLines: 1,
                        borderRound: 60.r,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 10.w
                        ),
                        focusedBorderColor: Colors.transparent,
                        isSearchField: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        prefixIcon: SvgPicture.asset(
                          Constants.searchIcon,
                          fit: BoxFit.none
                        ),
                      ),
                    ),
                    20.verticalSpace,
                    SizedBox(
                      width: double.infinity,
                      height: 158.h,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          initialPage: 1,
                          viewportFraction: 0.9,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                        ),
                        itemCount: controller.cards.length,
                        itemBuilder: (context, itemIndex, pageViewIndex) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(controller.cards[itemIndex], fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    14.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Historial',
                              onPressed: () =>
                                  Get.toNamed(Routes.CUSTOMER_HISTORY),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              radius: 14.r,
                              verticalPadding: 14.h,
                            ),
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: CustomButton(
                              text: 'Tiendas',
                              onPressed: () => Get.toNamed(Routes.STORES),
                              backgroundColor: theme.primaryColorDark,
                              foregroundColor: theme.primaryColor,
                              radius: 14.r,
                              verticalPadding: 14.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    14.verticalSpace,
                    Obx(() {
                      final stats = controller.ordersStats.value;
                      if (stats == null) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _StatsCard(stats: stats),
                      );
                    }),
                  ],
                ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                    children: [
                      20.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categorias',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                            'Ver todo',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      16.verticalSpace,
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: controller.categories.map((category) {
                              return CategoryItem(category: category);
                            }).toList(),
                          )),
                      20.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mas vendidos',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                            'Ver todo',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      16.verticalSpace,
                      LayoutBuilder(
                        builder: (context, constraints) {
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
                              itemBuilder: (context, index) => ProductItem(
                                product: items[index],
                              ),
                            );
                          });
                        },
                      ),
                      20.verticalSpace,
                    ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final OrdersStats stats;

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.stars_rounded, color: Colors.white, size: 22),
              8.horizontalSpace,
              Text(
                'Mis puntos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Text(
            '${stats.currentPoints}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          12.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Compras',
                  value: '${stats.totalOrders}',
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Gastado',
                  value: '\$${stats.totalSpent.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Ahorrado',
                  value: '\$${stats.totalSaved.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        2.verticalSpace,
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
