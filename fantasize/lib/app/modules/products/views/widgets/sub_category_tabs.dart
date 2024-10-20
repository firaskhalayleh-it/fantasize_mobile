import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';

class SubCategoryTabs extends StatelessWidget {
  final ProductsController controller = Get.put(ProductsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          // Subcategory Tab Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(controller.subCategoryNames.length, (index) {
                return GestureDetector(
                  onTap: () {
                    // When a subcategory is clicked, change the tab
                    controller.changeTabBarIndex(index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: controller.tabBarIndex.value == index
                          ? Colors.red[300]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.subCategoryNames[index],
                      style: TextStyle(
                        color: controller.tabBarIndex.value == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          // TabBarView to show product content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: List.generate(
                controller.subCategoryNames.length,
                (index) {
                  return Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                        itemCount: controller.productList.length,
                        itemBuilder: (context, productIndex) {
                          return ListTile(
                            title: Text(controller.productList[productIndex].name),
                            subtitle: Text('\$${controller.productList[productIndex].price}'),
                          );
                        },
                      );
                    }
                  });
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
