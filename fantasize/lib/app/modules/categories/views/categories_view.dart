import 'package:fantasize/app/data/models/category_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/categories/controllers/categories_controller.dart';
import 'package:fantasize/app/modules/categories/views/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class CategoriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF4C5E),
              strokeWidth: 3,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF4C5E).withOpacity(0.05),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 20),
            physics: BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              var category = controller.categories[index];
              return AnimatedBuilder(
                animation: AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 50),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: index == controller.categories.length - 1
                            ? Get.height * 0.12
                            : 20.0,
                      ),
                      child: CategoryCard(category: category),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: SizedBox(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_outlined,
                color: Colors.redAccent,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent ,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
