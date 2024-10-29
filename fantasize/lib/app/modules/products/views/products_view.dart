import 'package:fantasize/app/modules/products/views/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';
import 'package:fantasize/app/modules/products/views/widgets/custom_app_bar.dart'; // Import CustomAppBar

class ProductsView extends StatelessWidget {
  final ProductsController controller = Get.put(ProductsController());

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
              } else if (controller.tabBarIndex.value ==
                  controller.subCategoryNames.indexOf("Packages")) {
                // Display packages
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.packageList.length,
                  itemBuilder: (context, index) {
                    final package = controller.packageList[index];
                    if (controller.packageList.isEmpty) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text("No packages available"),
                        ),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        Get.toNamed('/package-details',
                            arguments: package.packageId);
                      },
                      child: PackageCard(package: package),
                    );
                  },
                );
              } else {
                // Display products
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.productList.length,
                  itemBuilder: (context, index) {
                    final product = controller.productList[index];
                    return InkWell(
                      onTap: () {
                        Get.toNamed('/product-details',
                            arguments: [product.productId]);
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
