import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../routes/app_pages.dart';
import '../../calendar/views/calendar_view.dart';
import '../../category/views/category_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/base_controller.dart';
import '../../home/views/home_view.dart';

class BaseView extends GetView<BaseController> {
  const BaseView({Key? key}) : super(key: key);

  static const List<Widget> _pages = [
    HomeView(),
    CategoryView(),
    Center(),
    CalendarView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return GetBuilder<BaseController>(
      builder: (_) {
        if (isDesktop) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _desktopHeader(context, theme),
                  Expanded(
                    child: IndexedStack(
                      index: controller.currentIndex,
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ─── MOBILE ───────────────────────────────────────────────────────────
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: controller.currentIndex,
              children: _pages,
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex,
              type: BottomNavigationBarType.fixed,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 0.0,
              items: [
                _mBottomNavItem(label: 'Home', icon: Constants.homeIcon),
                _mBottomNavItem(
                    label: 'category', icon: Constants.categoryIcon),
                const BottomNavigationBarItem(
                    label: '', icon: Center()),
                _mBottomNavItem(
                    label: 'Calendar', icon: Constants.calendarIcon),
                _mBottomNavItem(label: 'Profile', icon: Constants.userIcon),
              ],
              onTap: controller.changeScreen,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            onPressed: () => Get.toNamed(Routes.CART),
            child: GetBuilder<BaseController>(
              id: 'CartBadge',
              builder: (_) => badges.Badge(
                position:
                    badges.BadgePosition.bottomEnd(bottom: -16, end: 13),
                badgeContent: Text(
                  controller.cartItemsCount.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: badges.BadgeStyle(
                  elevation: 2,
                  badgeColor: theme.colorScheme.secondary,
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: theme.primaryColor,
                  child: SvgPicture.asset(Constants.cartIcon,
                      fit: BoxFit.none),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── DESKTOP HEADER ────────────────────────────────────────────────────────

  Widget _desktopHeader(BuildContext context, ThemeData theme) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(Constants.logo, height: 32),
          20.horizontalSpace,
          // Search bar
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: SizedBox(
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en el marketplace...',
                    hintStyle: TextStyle(
                        color: theme.hintColor, fontSize: 13.sp),
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: theme.hintColor),
                    filled: true,
                    fillColor: theme.primaryColorDark,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.h, horizontal: 12.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.r),
                      borderSide:
                          BorderSide(color: theme.primaryColor, width: 1.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          20.horizontalSpace,
          // Navigation tabs
          _navTab(theme, 'Marketplace', 0),
          4.horizontalSpace,
          _navTab(theme, 'Earning', 1),
          4.horizontalSpace,
          _navTab(theme, 'Rewards', 3),
          12.horizontalSpace,
          // Bell notification
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined,
                color: theme.appBarTheme.iconTheme?.color, size: 22),
          ),
          8.horizontalSpace,
          // Points badge
          Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: Colors.white, size: 13),
                    4.horizontalSpace,
                    Text(
                      controller.userPoints.value > 0
                          ? '${controller.userPoints.value} pts'
                          : 'Mis pts',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
          10.horizontalSpace,
          // Avatar
          GestureDetector(
            onTap: () => controller.changeScreen(4),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: theme.primaryColorDark,
              child: ClipOval(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(Constants.avatar),
                ),
              ),
            ),
          ),
          6.horizontalSpace,
        ],
      ),
    );
  }

  Widget _navTab(ThemeData theme, String label, int index) {
    final selected = controller.currentIndex == index;
    return GestureDetector(
      onTap: () => controller.changeScreen(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? theme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _mBottomNavItem(
      {required String label, required String icon}) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(icon,
            colorFilter: ColorFilter.mode(
                Get.theme.iconTheme.color ?? Colors.grey, BlendMode.srcIn)),
      activeIcon: SvgPicture.asset(icon,
            colorFilter: ColorFilter.mode(
                Get.theme.appBarTheme.iconTheme?.color ?? Colors.grey,
                BlendMode.srcIn)),
    );
  }
}
