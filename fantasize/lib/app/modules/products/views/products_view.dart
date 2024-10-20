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
              } else if (controller.productList.isEmpty) {
                return Center(child: Text("No products available."));
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.658,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.productList.length,
                  itemBuilder: (context, index) {
                    final product = controller.productList[index];
                    return InkWell(
                      onTap: () => controller.NavigateToProductDetails(index),
                        child:
                            ProductCard(product: product)); // Use ProductCard
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
