// custom_app_bar.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;
  final double screenWidth;
  final ProductsController productsController = Get.find<ProductsController>();

  CustomAppBar({
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
        Colors.redAccent.withOpacity(0.05),
        Colors.white.withOpacity(0.95),
        ],
      ),
      ),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Section with Back Button, Logo, and Profile Picture
        Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.05,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
        ),
        child: Stack(
          children: [
          // Back Button
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              ],
            ),
            child: IconButton(
              icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.redAccent,
              ),
              onPressed: () => Get.back(),
            ),
            ),
          ),

          // Center Logo
          Center(
            child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              ],
            ),
            child: Image.asset(
              'assets/icons/fantasize.png',
              width: screenWidth * 0.18,
              height: screenHeight * 0.05,
            ),
            ),
          ),
       
                // Right Profile Picture
               
              ],
            ),
          ),
          SizedBox(height: 15),

          // Search Bar
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        productsController.updateSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products or packages...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),
              _buildFilterButton(screenHeight),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 15),

          // Custom TabBar with Buttons for Subcategories
          SingleChildScrollView(
            dragStartBehavior: DragStartBehavior.start,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  productsController.subCategoryNames.length,
                  (index) {
                    final isSelected = productsController.tabBarIndex.value == index;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? screenWidth * 0.04 : 10,
                        right: index == productsController.subCategoryNames.length - 1
                            ? screenWidth * 0.04
                            : 0,
                      ),
                      child: _buildCategoryButton(
                        screenWidth: screenWidth,
                        text: productsController.subCategoryNames[index],
                        selected: isSelected,
                        onTap: () => productsController.changeTabBarIndex(index),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Builds the filter button with icon
  Widget _buildFilterButton(double screenHeight) {
    return GestureDetector(
      onTap: () {
        _showFilterBottomSheet();
      },
      child: Container(
        height: screenHeight * 0.06,
        width: screenHeight * 0.06,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.tune_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  /// Shows the filter bottom sheet for price range selection
  void _showFilterBottomSheet() {
    final ProductsController controller = Get.find<ProductsController>();
    final TextEditingController minController = TextEditingController(
        text: controller.minPrice.value != null ? controller.minPrice.value.toString() : '');
    final TextEditingController maxController = TextEditingController(
        text: controller.maxPrice.value != null ? controller.maxPrice.value.toString() : '');

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.filter_list_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  'Price Range Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              'Set your price range',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      prefixIcon: Icon(Icons.remove_rounded, color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: maxController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      prefixIcon: Icon(Icons.add_rounded, color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.resetPriceRange();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      double? min = double.tryParse(minController.text.trim());
                      double? max = double.tryParse(maxController.text.trim());

                      if (min != null && max != null && min > max) {
                        Get.snackbar(
                          'Invalid Range',
                          'Minimum price cannot exceed maximum price',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      controller.applyPriceFilter(min, max);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Apply Filter',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Builds each category button
  Widget _buildCategoryButton({
    required double screenWidth,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.redAccent : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: selected ? 1 : 0,
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
            color: selected ? Colors.white : Colors.grey[800],
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.28);
}
