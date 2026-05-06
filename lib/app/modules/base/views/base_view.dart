import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart';
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

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return GetBuilder<BaseController>(
      builder: (_) {
        if (isDesktop) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                SafeArea(
                  child: Container(
                    width: 108,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(right: BorderSide(color: theme.dividerColor)),
                    ),
                    child: NavigationRail(
                      selectedIndex: _desktopSelectedIndex(controller.currentIndex),
                      onDestinationSelected: (value) => controller.changeScreen(_desktopIndexToBaseIndex(value)),
                      backgroundColor: Colors.transparent,
                      useIndicator: true,
                      indicatorColor: theme.primaryColor.withOpacity(0.15),
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          icon: SvgPicture.asset(Constants.homeIcon, color: theme.iconTheme.color),
                          selectedIcon: SvgPicture.asset(Constants.homeIcon, color: theme.primaryColor),
                          label: const Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: SvgPicture.asset(Constants.categoryIcon, color: theme.iconTheme.color),
                          selectedIcon: SvgPicture.asset(Constants.categoryIcon, color: theme.primaryColor),
                          label: const Text('Categorias'),
                        ),
                        NavigationRailDestination(
                          icon: SvgPicture.asset(Constants.calendarIcon, color: theme.iconTheme.color),
                          selectedIcon: SvgPicture.asset(Constants.calendarIcon, color: theme.primaryColor),
                          label: const Text('Calendario'),
                        ),
                        NavigationRailDestination(
                          icon: SvgPicture.asset(Constants.userIcon, color: theme.iconTheme.color),
                          selectedIcon: SvgPicture.asset(Constants.userIcon, color: theme.primaryColor),
                          label: const Text('Perfil'),
                        ),
                      ],
                      trailing: Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: GetBuilder<BaseController>(
                              id: 'CartBadge',
                              builder: (_) => IconButton(
                                onPressed: () => Get.toNamed(Routes.CART),
                                icon: Badge(
                                  position: BadgePosition.topEnd(top: -10, end: -8),
                                  badgeContent: Text(
                                    controller.cartItemsCount.toString(),
                                    style: theme.textTheme.caption?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  badgeStyle: BadgeStyle(
                                    elevation: 2,
                                    badgeColor: theme.accentColor,
                                    borderSide: const BorderSide(color: Colors.white, width: 1),
                                  ),
                                  child: CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: theme.primaryColor,
                                    child: SvgPicture.asset(Constants.cartIcon, fit: BoxFit.none),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _desktopHeader(theme),
                        Expanded(
                          child: IndexedStack(
                            index: controller.currentIndex,
                            children: const [
                              HomeView(),
                              CategoryView(),
                              Center(),
                              CalendarView(),
                              ProfileView()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: controller.currentIndex,
              children: const [
                HomeView(),
                CategoryView(),
                Center(),
                CalendarView(),
                ProfileView()
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.06),
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
                _mBottomNavItem(
                  label: 'Home',
                  icon: Constants.homeIcon,
                ),
                _mBottomNavItem(
                  label: 'category',
                  icon: Constants.categoryIcon,
                ),
                const BottomNavigationBarItem(
                  label: '',
                  icon: Center(),
                ),
                _mBottomNavItem(
                  label: 'Calendar',
                  icon: Constants.calendarIcon,
                ),
                _mBottomNavItem(
                  label: 'Profile',
                  icon: Constants.userIcon,
                ),
              ],
              onTap: controller.changeScreen,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            onPressed:() => Get.toNamed(Routes.CART),
            child: GetBuilder<BaseController>(
              id: 'CartBadge',
              builder: (_) => Badge(
                position: BadgePosition.bottomEnd(bottom: -16, end: 13),
                badgeContent: Text(
                  controller.cartItemsCount.toString(),
                  style: theme.textTheme.bodyText2?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: BadgeStyle(
                  elevation: 2,
                  badgeColor: theme.accentColor,
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: theme.primaryColor,
                  child: SvgPicture.asset(
                    Constants.cartIcon, fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static const Map<int, String> _sectionTitles = {
    0: 'Home',
    1: 'Categorías',
    3: 'Calendario',
    4: 'Mi perfil',
  };

  Widget _desktopHeader(ThemeData theme) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.primaryColorDark,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(Constants.logo),
            ),
          ),
          10.horizontalSpace,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Letdem Marketplace',
                style: theme.textTheme.caption?.copyWith(color: theme.hintColor),
              ),
              GetBuilder<BaseController>(
                builder: (ctrl) => Text(
                  _sectionTitles[ctrl.currentIndex] ?? 'Home',
                  style: theme.textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => controller.changeScreen(4),
            icon: Icon(Icons.person_outline, color: theme.primaryColor),
            label: Text(
              'Mi perfil',
              style: theme.textTheme.bodyText2?.copyWith(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  int _desktopSelectedIndex(int baseIndex) {
    switch (baseIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  int _desktopIndexToBaseIndex(int desktopIndex) {
    switch (desktopIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  _mBottomNavItem({required String label, required String icon}) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(icon, color: Get.theme.iconTheme.color),
      activeIcon: SvgPicture.asset(icon, color: Get.theme.appBarTheme.iconTheme?.color),
    );
  }

}
