import 'package:fantasize/app/data/models/category_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/categories/controllers/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final RxBool isExpanded = false.obs; // Reactive variable for expansion state

  CategoryCard({required this.category});
  CategoriesController controller = Get.find<CategoriesController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        children: [
          Stack(
            children: [
              // Category Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: category.imageUrl != null
                        ? NetworkImage(
                            '${Strings().resourceUrl}/${category.imageUrl!}',
                          )
                        : AssetImage('assets/images/placeholder.jpeg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),

              // Overlay Text (Category Name) and Dropdown Icon
              Positioned(
                left: 15,
                top: 15,
                child: Text(
                  category.name ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown Icon Button to expand/collapse subcategories
              Positioned(
                right: -5,
                bottom: -10,
                child: Obx(() => AnimatedRotation(
                    turns: isExpanded.value ? 0.5 : 0.0, // 180 degrees rotation
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                    icon: isExpanded.value
                      ? Image(
                        image: Svg('assets/icons/category.svg'),
                        colorBlendMode: BlendMode.srcIn,
                        )
                      : Image(
                        image: Svg('assets/icons/category1.svg'),
                        colorBlendMode: BlendMode.srcIn,
                        ),
                    onPressed: () {
                      // Toggle expanded state
                      isExpanded.value = !isExpanded.value;
                    },
                    iconSize: 30.0,
                    ),
                  )),
              ),
            ],
          ),

          // Animated Section for Subcategories
          Obx(() {
            return AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded.value
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: category.subCategories
                                ?.asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              var subCategory = entry.value;
                              return ListTile(
                                splashColor: Color(0xFFFF4C5E),
                                leading: Icon(Icons.remove, color: Colors.red),
                                title: Text(subCategory.name ?? ''),
                                onTap: () {
                                  // Navigate to subcategory page
                                  controller.NavigateToSubCategories(
                                    subCategory.subCategoryId ?? 0,
                                  );
                                },
                              );
                            }).toList() ??
                            [],
                      ),
                    )
                  : SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }
}