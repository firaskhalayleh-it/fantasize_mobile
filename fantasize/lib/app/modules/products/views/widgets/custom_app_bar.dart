import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Section with Back Button, Logo, and Profile Picture
        Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.04,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
          ),
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: SvgPicture.asset('assets/icons/back_button.svg'),
                onPressed: () => Get.back(),
              ),
              const Spacer(flex: 3),

              // Center Logo
              Image.asset(
                'assets/icons/fantasize.png',
                width: screenWidth * 0.1,
                height: screenHeight * 0.05,
              ),
              const Spacer(flex: 3),

              // Right Profile Picture
              InkWell(
                onTap: () {
                  // Navigate to profile
                  Get.toNamed('/profile');
                },
                child: Obx(() {
                  return Hero(
                      tag: 'profile',
                      child: CircleAvatar(
                        radius: screenWidth * 0.07,
                        backgroundImage: productsController
                                .userProfilePicture.isNotEmpty
                            ? NetworkImage(
                                '${Strings().resourceUrl}/${productsController.userProfilePicture.value}')
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                      ));
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Container(
            height: screenHeight * 0.06,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.search),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    width: 2,
                  ),
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Custom TabBar with Buttons for Subcategories
        SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.start,
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                productsController.subCategoryNames.length,
                (index) {
                  final isSelected =
                      productsController.tabBarIndex.value == index;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCategoryButton(
                        screenWidth: screenWidth,
                        text: productsController.subCategoryNames[index],
                        selected: isSelected,
                        onTap: () {
                          productsController.changeTabBarIndex(
                              index); // Dynamically change tab
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  );
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Helper method to build custom category buttons without icons
  Widget _buildCategoryButton({
    required double screenWidth,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.red[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.35);
}
