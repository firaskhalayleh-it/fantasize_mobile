// products_view.dart
import 'package:fantasize/app/modules/products/views/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';
import 'package:fantasize/app/modules/products/views/widgets/custom_app_bar.dart'; // Import CustomAppBar
class ProductsView extends StatelessWidget {
  final ProductsController controller = Get.find<ProductsController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = Get.width;
    double screenHeight = Get.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              
              String currentTab = controller.subCategoryNames[controller.tabBarIndex.value].toLowerCase();
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: currentTab == "packages" 
                    ? _buildPackagesGrid()
                    : _buildProductsGrid(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4C5E).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4C5E)),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            "Loading items...",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFFF4C5E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFFFF4C5E),
            ),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesGrid() {
    final packages = controller.filteredPackageList;
    if (packages.isEmpty) {
      return _buildEmptyState("No packages found");
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3/5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: InkWell(
            onTap: () => controller.navigateToPackageDetails(packages[index].packageId),
            child: PackageCard(package: packages[index]),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    final products = controller.filteredProductList;
    if (products.isEmpty) {
      return _buildEmptyState("No products found");
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3/5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: InkWell(
            onTap: () => controller.navigateToProductDetails(index),
            child: ProductCard(product: products[index]),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGridItem({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}