// First File: custom_app_bar.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;
  final double screenWidth;
  final ProductsController productsController = Get.put(ProductsController());

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
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

                // Center Logo
                Container(
                  padding: EdgeInsets.all(8),
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
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.05,
                  ),
                ),

                // Right Profile Picture
                InkWell(
                  onTap: () => Get.toNamed('/profile'),
                  child: Obx(() {
                    return Hero(
                      tag: 'profile',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF5252).withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(255, 82, 82, 1)
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: screenWidth * 0.06,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: screenWidth * 0.055,
                            backgroundImage: productsController
                                    .userProfilePicture.isNotEmpty
                                ? NetworkImage(
                                    '${Strings().resourceUrl}/${productsController.userProfilePicture.value}')
                                : const AssetImage('assets/images/profile.jpg')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
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
                    decoration: InputDecoration(
                      hintText: 'Search products...',
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
              )),
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
                    final isSelected =
                        productsController.tabBarIndex.value == index;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? screenWidth * 0.04 : 10,
                        right: index ==
                                productsController.subCategoryNames.length - 1
                            ? screenWidth * 0.04
                            : 0,
                      ),
                      child: _buildCategoryButton(
                        screenWidth: screenWidth,
                        text: productsController.subCategoryNames[index],
                        selected: isSelected,
                        onTap: () =>
                            productsController.changeTabBarIndex(index),
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
    return Container(
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
    );
  }

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
