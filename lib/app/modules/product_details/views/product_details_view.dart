import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_icon_button.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({Key? key}) : super(key: key);

  // Feature tags shown below the product image
  static const List<Map<String, IconData>> _features = [
    {'Empaque Sostenible': Icons.eco_outlined},
    {'Entrega Inmediata': Icons.local_shipping_outlined},
    {'Garantía Oficial': Icons.verified_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return isDesktop
                ? _desktopLayout(context)
                : _mobileLayout(context);
          },
        ),
      ),
    );
  }

  // ─── DESKTOP ───────────────────────────────────────────────────────────────

  Widget _desktopLayout(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        _desktopNavBar(theme),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: image + feature tags
              Expanded(
                flex: 5,
                child: _leftPanel(context, theme),
              ),
              // Right: details + redeem
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(8.w, 32.h, 40.w, 32.h),
                  child: _rightPanel(context, theme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _desktopNavBar(ThemeData theme) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(Constants.logo, height: 28),
          const Spacer(),
          // Back link
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, size: 16, color: theme.primaryColor),
            label: Text(
              'Back to Marketplace',
              style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          // Bell
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined,
                color: theme.appBarTheme.iconTheme?.color, size: 20),
          ),
          8.horizontalSpace,
          // Points badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 12),
                4.horizontalSpace,
                const Text('Mis pts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          10.horizontalSpace,
          // Avatar
          CircleAvatar(
            radius: 16.r,
            backgroundColor: theme.primaryColorDark,
            child: ClipOval(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(Constants.avatar),
              ),
            ),
          ),
          6.horizontalSpace,
        ],
      ),
    );
  }

  Widget _leftPanel(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(32.r),
      child: Column(
        children: [
          // Product image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: theme.dividerColor),
              ),
              padding: EdgeInsets.all(24.r),
              child: _productImage(controller.product.image, BoxFit.contain)
                  .animate()
                  .fade()
                  .scale(
                      duration: 600.ms, curve: Curves.fastOutSlowIn),
            ),
          ),
          20.verticalSpace,
          // Feature tags
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: _features.map((f) {
              final label = f.keys.first;
              final icon = f.values.first;
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: theme.iconTheme.color),
                    6.horizontalSpace,
                    Text(label,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _rightPanel(BuildContext context, ThemeData theme) {
    final product = controller.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store badge
        if (product.storeName != null) ...[
          Row(
            children: [
              Icon(Icons.storefront_outlined,
                  size: 14, color: theme.primaryColor),
              6.horizontalSpace,
              Text(
                product.storeName!.toUpperCase(),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          12.verticalSpace,
        ],
        // Product title
        Text(
          product.name,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ).animate().fade().slideX(
            duration: 300.ms, begin: 0.5, curve: Curves.easeOut),
        20.verticalSpace,
        // Price in amber
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatPoints(product.price),
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ).animate().fade().slideX(
                duration: 300.ms, begin: 0.5, curve: Curves.easeOut),
            10.horizontalSpace,
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Points',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        24.verticalSpace,
        // Product overview card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Overview',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              12.verticalSpace,
              Text(
                product.description.isNotEmpty
                    ? product.description
                    : 'Disfruta de este exclusivo producto del marketplace Letdem. Canjea tus puntos y obtén una experiencia premium.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(height: 1.6),
              ),
            ],
          ),
        ).animate().fade().slideY(
            duration: 400.ms, begin: 0.3, curve: Curves.easeOut),
        20.verticalSpace,
        // QR redeem card
        Container(
          width: double.infinity,
          height: 130.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withValues(alpha: 0.85),
                theme.primaryColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.9), size: 32),
                    10.verticalSpace,
                    Text(
                      'Redeem to unlock QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms),
        24.verticalSpace,
        // Redeem button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            onPressed: () => controller.onAddToCartPressed(),
            icon: const Icon(Icons.qr_code_2_rounded,
                color: Colors.white, size: 20),
            label: const Text(
              'Redeem Points Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
          ).animate().fade().slideY(
              duration: 400.ms, begin: 0.5, curve: Curves.easeOut),
        ),
        12.verticalSpace,
        Center(
          child: Text(
            'By clicking redeem, ${_formatPoints(product.price)} points will be deducted from your balance.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
        20.verticalSpace,
      ],
    );
  }

  // ─── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _mobileLayout(BuildContext context) {
    final theme = context.theme;
    final product = controller.product;
    return ListView(
      children: [
        // Mobile header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              CustomIconButton(
                onPressed: () => Get.back(),
                backgroundColor: theme.primaryColorDark,
                icon: Icon(Icons.arrow_back,
                    color: theme.appBarTheme.iconTheme?.color, size: 20),
              ),
              16.horizontalSpace,
              Text('Detalle del producto',
                  style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        // Product image
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          height: 260.h,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: EdgeInsets.all(20.r),
          child: _productImage(product.image, BoxFit.contain)
              .animate()
              .fade()
              .scale(duration: 600.ms, curve: Curves.fastOutSlowIn),
        ),
        16.verticalSpace,
        // Feature tags
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _features.map((f) {
              final label = f.keys.first;
              final icon = f.values.first;
              return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: theme.iconTheme.color),
                    5.horizontalSpace,
                    Text(label,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        24.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store name
              if (product.storeName != null)
                Row(
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 13, color: theme.primaryColor),
                    5.horizontalSpace,
                    Text(
                      product.storeName!.toUpperCase(),
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              10.verticalSpace,
              Text(product.name, style: theme.textTheme.displayMedium),
              16.verticalSpace,
              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPoints(product.price),
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  8.horizontalSpace,
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('Points',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
              20.verticalSpace,
              // Description
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Overview',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    10.verticalSpace,
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Canjea tus puntos y obtén este exclusivo producto del marketplace Letdem.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              // QR redeem card
              Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.85),
                      theme.primaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: Colors.white, size: 24),
                      10.horizontalSpace,
                      const Text(
                        'Redeem to unlock QR Code',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              20.verticalSpace,
              // Redeem button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () => controller.onAddToCartPressed(),
                  icon: const Icon(Icons.qr_code_2_rounded,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Redeem Points Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                ),
              ),
              12.verticalSpace,
              Center(
                child: Text(
                  'By clicking redeem, ${_formatPoints(product.price)} points will be deducted from your balance.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              30.verticalSpace,
            ],
          ),
        ),
      ],
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Widget _productImage(String src, BoxFit fit) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(src, fit: fit,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_outlined, size: 64));
    }
    return Image.asset(src, fit: fit,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_outlined, size: 64));
  }

  String _formatPoints(double price) {
    final pts = price.toInt();
    if (pts >= 1000) {
      return '${(pts ~/ 1000)},${(pts % 1000).toString().padLeft(3, '0')}';
    }
    return '$pts';
  }
}
