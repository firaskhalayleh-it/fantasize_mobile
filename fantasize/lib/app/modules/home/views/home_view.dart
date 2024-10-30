import 'package:fantasize/app/modules/cart/views/cart_view.dart';
import 'package:fantasize/app/modules/categories/views/categories_view.dart';
import 'package:fantasize/app/modules/explore/views/explore_view.dart';
import 'package:fantasize/app/modules/favorites/views/favorites_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart'; // For handling SVGs
import 'package:get/get.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/home_page_tab_view.dart';

import '../controllers/load_icon.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  final List<Widget> pages = [
    HomeTabView(), // Home page with TabBar
    CategoriesView(), // Categories Page
    ExploreView(), // Explore Page
    FavoritesView(), // Favorites Page
    CartView(), // Cart Page
  ];

  // A function to load the image based on the file type (SVG or normal image)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Obx(
                () => pages[homeController.currentIndexNavigationBar.value]),
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
                  // Home Icon
                  CurvedNavigationBarItem(
                    child: loadIcon(
                      homeController.currentIndexNavigationBar.value == 0
                          ? 'assets/icons/home1.svg' // Selected icon
                          : 'assets/icons/home.svg', // Default icon
                      homeController.currentIndexNavigationBar.value == 0
                          ? 40
                          : 30,
                    ),
                    label: 'Home',
                  ),
                  // Categories Icon
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
                  // Explore Icon
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
                  // Favorites Icon
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
                  // Cart Icon
                  CurvedNavigationBarItem(
                    child: loadIcon(
                      homeController.currentIndexNavigationBar.value == 4
                          ? 'assets/icons/cart1.svg' // Selected icon (SVG)
                          : 'assets/icons/cart.png', // Default icon (PNG)
                      homeController.currentIndexNavigationBar.value == 4
                          ? 40
                          : 30,
                    ),
                    label: 'Cart',
                  ),
                ],
                color: Colors.white, // Background color of the navigation bar
                buttonBackgroundColor: Colors.white, // Button background color
                backgroundColor:
                    Colors.transparent, // Background behind the nav bar
                animationCurve:
                    Curves.fastEaseInToSlowEaseOut, // Animation curve
                animationDuration:
                    Duration(milliseconds: 600), // Animation duration
                onTap: (index) {
                  print("Selected index: $index"); // Debugging statement
                  homeController.changeNavigationBarIndex(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
