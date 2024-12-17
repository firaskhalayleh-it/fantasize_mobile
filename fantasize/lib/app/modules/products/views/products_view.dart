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
      appBar: CustomAppBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              // Determine current tab
              String currentTab = controller.subCategoryNames[controller.tabBarIndex.value].toLowerCase();

              if (currentTab == "packages") {
                // Use filteredPackageList for display
                final packages = controller.filteredPackageList;

                if (packages.isEmpty) {
                  return Center(child: Text("No packages found."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return InkWell(
                      onTap: () {
                        controller.navigateToPackageDetails(package.packageId);
                      },
                      child: PackageCard(package: package),
                    );
                  },
                );
              } else {
                // Use filteredProductList for display
                final products = controller.filteredProductList;

                if (products.isEmpty) {
                  return Center(child: Text("No products found."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return InkWell(
                      onTap: () {
                        controller.navigateToProductDetails(index);
                      },
                      child: ProductCard(product: product),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
