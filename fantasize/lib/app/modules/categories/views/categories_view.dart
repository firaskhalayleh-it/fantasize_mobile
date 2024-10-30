import 'package:fantasize/app/modules/categories/controllers/categories_controller.dart';
import 'package:fantasize/app/modules/categories/views/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(fontFamily: 'Poppines', fontSize: 30,color: Colors.redAccent),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            var category = controller.categories[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: index == controller.categories.length - 1
                    ? Get.height * 0.12
                    : 10.0, // 60px for the last item, 10px otherwise
              ),
              child: CategoryCard(category: category),
            );
          },
        );
      }),
    );
  }
}
