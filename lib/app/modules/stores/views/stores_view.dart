import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/api_config.dart';
import '../../../../utils/constants.dart';
import '../../../components/custom_form_field.dart';
import '../../../components/custom_icon_button.dart';
import '../../../data/models/store_model.dart';
import '../../../routes/app_pages.dart';
import '../../products/controllers/products_controller.dart';
import '../controllers/stores_controller.dart';

class StoresView extends StatefulWidget {
  const StoresView({Key? key}) : super(key: key);

  @override
  State<StoresView> createState() => _StoresViewState();
}

class _StoresViewState extends State<StoresView> {
  final StoresController controller = Get.find<StoresController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      controller.loadMore();
    }
  }

  String _resolveImage(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConfig.baseUrl}$url';
    return url;
  }

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
                'Tiendas',
                style: theme.textTheme.displaySmall,
              ),
              CustomIconButton(
                onPressed: () => controller.fetchStores(),
                backgroundColor: theme.cardColor,
                borderColor: theme.dividerColor,
                icon: Icon(
                  Icons.refresh,
                  color: theme.appBarTheme.iconTheme?.color,
                  size: 20,
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
                  hint: 'Buscar tiendas',
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
                  () {
                    final shown = controller.stores.length;
                    final total = controller.meta.value.total;
                    final label = total > 0 && total >= shown
                        ? 'Mostrando $shown de $total tiendas'
                        : '$shown tiendas encontradas';
                    return Text(label, style: theme.textTheme.bodySmall);
                  },
                ),
                16.verticalSpace,
                Expanded(
                  child: Obx(
                    () {
                      if (controller.isLoading.value &&
                          controller.stores.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final items = controller.stores;
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            controller.errorMessage.value.isNotEmpty
                                ? 'No se pudieron cargar las tiendas.'
                                : 'No hay tiendas para mostrar.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final isLoadingMore = controller.isLoadingMore.value;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = 1;
                          if (constraints.maxWidth >= 960) {
                            columns = 3;
                          } else if (constraints.maxWidth >= 640) {
                            columns = 2;
                          }
                          return RefreshIndicator(
                            onRefresh: controller.fetchStores,
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 16.w,
                                    mainAxisSpacing: 16.h,
                                    mainAxisExtent: 132.h,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _StoreCard(
                                      store: items[index],
                                      resolveImage: _resolveImage,
                                      onTap: () => _openStoreSheet(
                                          context, items[index]),
                                    ),
                                    childCount: items.length,
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.h),
                                    child: Center(
                                      child: isLoadingMore
                                          ? const CircularProgressIndicator()
                                          : (controller.meta.value.hasMore
                                              ? Text(
                                                  'Desliza para cargar más',
                                                  style: theme
                                                      .textTheme.bodySmall,
                                                )
                                              : const SizedBox.shrink()),
                                    ),
                                  ),
                                ),
                              ],
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

  void _openStoreSheet(BuildContext context, StoreModel store) {
    final theme = context.theme;
    final image = _resolveImage(store.logoUrl);
    final banner = _resolveImage(store.banner);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  if (banner.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        banner,
                        height: 140.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  if (banner.isNotEmpty) 16.verticalSpace,
                  Row(
                    children: [
                      _StoreLogo(url: image, size: 56.r),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                            if (store.address.isNotEmpty)
                              Text(
                                store.address,
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      if (store.isPublished)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Activa',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (store.description.isNotEmpty) ...[
                    16.verticalSpace,
                    Text(store.description, style: theme.textTheme.bodyMedium),
                  ],
                  16.verticalSpace,
                  if (store.billingPhone.isNotEmpty)
                    _InfoRow(
                        icon: Icons.phone_outlined, text: store.billingPhone),
                  if (store.email.isNotEmpty)
                    _InfoRow(icon: Icons.email_outlined, text: store.email),
                  if (store.website.isNotEmpty)
                    _InfoRow(icon: Icons.language, text: store.website),
                  if (store.categories.isNotEmpty) ...[
                    16.verticalSpace,
                    Text('Categorías', style: theme.textTheme.titleMedium),
                    8.verticalSpace,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: store.categories
                          .map((c) => Chip(label: Text(c)))
                          .toList(),
                    ),
                  ],
                  if (store.openingHours.isNotEmpty) ...[
                    16.verticalSpace,
                    Text('Horarios', style: theme.textTheme.titleMedium),
                    8.verticalSpace,
                    ...store.openingHours.entries.map(
                      (e) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              child: Text(
                                e.key,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value.toString(),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  24.verticalSpace,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Get.back();
                        // Forzamos recreación del ProductsController para que
                        // tome el storeId desde Get.arguments en su onInit.
                        if (Get.isRegistered<ProductsController>()) {
                          Get.delete<ProductsController>();
                        }
                        Get.toNamed(
                          Routes.PRODUCTS,
                          arguments: {
                            'storeId': store.id,
                            'storeName': store.name,
                          },
                        );
                      },
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Ver catálogo'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.onTap,
    required this.resolveImage,
  });

  final StoreModel store;
  final VoidCallback onTap;
  final String Function(String) resolveImage;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final image = resolveImage(store.logoUrl);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StoreLogo(url: image, size: 64.r),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    4.verticalSpace,
                    if (store.address.isNotEmpty)
                      Text(
                        store.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        if (store.categories.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${store.categories.length} categorías',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            color: theme.hintColor, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.storefront_outlined,
          color: theme.hintColor, size: size * 0.5),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          8.horizontalSpace,
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
