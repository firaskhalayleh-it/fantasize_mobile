// Second File: subcategory_tabs.dart
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
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  controller.subCategoryNames.length,
                  (index) {
                    final isSelected = controller.tabBarIndex.value == index;
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: _buildTabButton(
                        text: controller.subCategoryNames[index],
                        isSelected: isSelected,
                        onTap: () => controller.changeTabBarIndex(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // TabBarView with products
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: List.generate(
                controller.subCategoryNames.length,
                (index) {
                  return Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.productList.length,
                        itemBuilder: (context, productIndex) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              title: Text(
                                controller.productList[productIndex].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '\$${controller.productList[productIndex].price}',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
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

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: isSelected ? 1 : 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}