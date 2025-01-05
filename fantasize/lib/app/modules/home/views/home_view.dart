import 'package:fantasize/app/modules/cart/views/cart_view.dart';
import 'package:fantasize/app/modules/categories/views/categories_view.dart';
import 'package:fantasize/app/modules/explore/views/explore_view.dart';
import 'package:fantasize/app/modules/favorites/views/favorites_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import for SystemNavigator
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/home_page_tab_view.dart';

import '../controllers/load_icon.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  final List<Widget> pages = [
    HomeTabView(),
    CategoriesView(),
    ExploreView(),
    FavoritesView(),
    CartView(),
  ];

  // Function to handle back button press
  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final shouldPop = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              SystemNavigator.pop();  // This will close the app
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(  // Wrap Scaffold with WillPopScope
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Obx(
                () => pages[homeController.currentIndexNavigationBar.value],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => CurvedNavigationBar(
                  index: homeController.currentIndexNavigationBar.value,
                  height: 60.0,
                  items: [
                    CurvedNavigationBarItem(
                      child: loadIcon(
                        homeController.currentIndexNavigationBar.value == 0
                            ? 'assets/icons/home1.svg'
                            : 'assets/icons/home.svg',
                        homeController.currentIndexNavigationBar.value == 0
                            ? 40
                            : 30,
                      ),
                      label: 'Home',
                    ),
                    CurvedNavigationBarItem(
                      child: loadIcon(
                        homeController.currentIndexNavigationBar.value == 1
                            ? 'assets/icons/categories1.svg'
                            : 'assets/icons/categories.png',
                        homeController.currentIndexNavigationBar.value == 1
                            ? 40
                            : 30,
                      ),
                      label: 'Categories',
                    ),
                    CurvedNavigationBarItem(
                      child: loadIcon(
                        homeController.currentIndexNavigationBar.value == 2
                            ? 'assets/icons/explore1.svg'
                            : 'assets/icons/explore.svg',
                        homeController.currentIndexNavigationBar.value == 2
                            ? 40
                            : 30,
                      ),
                      label: 'Explore',
                    ),
                    CurvedNavigationBarItem(
                      child: loadIcon(
                        homeController.currentIndexNavigationBar.value == 3
                            ? 'assets/icons/favorites1.svg'
                            : 'assets/icons/favorites.svg',
                        homeController.currentIndexNavigationBar.value == 3
                            ? 40
                            : 30,
                      ),
                      label: 'Favorites',
                    ),
                    CurvedNavigationBarItem(
                      child: loadIcon(
                        homeController.currentIndexNavigationBar.value == 4
                            ? 'assets/icons/cart1.svg'
                            : 'assets/icons/cart.png',
                        homeController.currentIndexNavigationBar.value == 4
                            ? 40
                            : 30,
                      ),
                      label: 'Cart',
                    ),
                  ],
                  color: Colors.white,
                  buttonBackgroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  animationCurve: Curves.fastEaseInToSlowEaseOut,
                  animationDuration: Duration(milliseconds: 600),
                  onTap: (index) {
                    print("Selected index: $index");
                    homeController.changeNavigationBarIndex(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}