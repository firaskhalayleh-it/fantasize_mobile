import 'package:fantasize/app/data/models/category_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/categories/controllers/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final RxBool isExpanded = false.obs;
  final CategoriesController controller = Get.find<CategoriesController>();

  CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildCategoryHeader(),
            _buildSubcategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Stack(
      children: [
        // Gradient Overlay
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.darken,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: category.imageUrl != null
                    ? NetworkImage(
                        '${Strings().resourceUrl}/${category.imageUrl!}')
                    : AssetImage('assets/images/placeholder.jpeg')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Category Info
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.name ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildExpandButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildExpandButton() {
    return Obx(() => GestureDetector(
          onTap: () => isExpanded.value = !isExpanded.value,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedRotation(
              duration: Duration(milliseconds: 300),
              turns: isExpanded.value ? 0.5 : 0,
              curve: Curves.easeInOut,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFFF4C5E),
                size: 24,
              ),
            ),
          ),
        ));
  }

  Widget _buildSubcategories() {
    return Obx(() {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: _buildSubcategoryContent(),
          crossFadeState: isExpanded.value
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 300),
        ),
      );
    });
  }

  Widget _buildSubcategoryContent() {
    if (category.subCategories?.isEmpty ?? true) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400]),
            SizedBox(width: 8),
            Text(
              "No subcategories available",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: category.subCategories!.length,
        itemBuilder: (context, index) {
          var subCategory = category.subCategories![index];
          return _buildSubcategoryTile(subCategory);
        },
      ),
    );
  }

  Widget _buildSubcategoryTile(dynamic subCategory) {
    return InkWell(
      onTap: () =>
          controller.NavigateToSubCategories(subCategory.subCategoryId ?? 0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFF4C5E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFFF4C5E).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFF4C5E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFFF4C5E),
                size: 14,
              ),
            ),
            Expanded(
              child: Text(
                subCategory.name ?? '',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
