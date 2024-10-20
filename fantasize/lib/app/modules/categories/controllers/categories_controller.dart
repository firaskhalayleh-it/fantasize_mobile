import 'dart:math';

import 'package:fantasize/app/data/models/category_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesController extends GetxController {
  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;
  late FavoritesController favorites;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => FavoritesController());
    favorites = Get.find<FavoritesController>();
    
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      isLoading(true);
      var response = await http
          .get(Uri.parse('${Strings().apiUrl}/categories/subcategories'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List;
        categories.value = jsonData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      } else {
        // Handle error
      }
    } finally {
      isLoading(false);
    }
  }
  

 void NavigateToSubCategories(int index) {
  // Find the category and subcategory based on the selected index (subcategory ID)
  var category = categories.firstWhere(
    (element) => element.subCategories!
        .any((subCategory) => subCategory.subCategoryId == index),
    orElse: () => throw StateError('No category found for subcategory ID: $index'),
  );

  var subCategory = category.subCategories!.firstWhere(
    (subCategory) => subCategory.subCategoryId == index,
    orElse: () => throw StateError('No subcategory found for ID: $index'),
  );

  // Pass the categoryId, subCategoryId, and the index of the selected subcategory
  Get.toNamed('/products', arguments: [
    category.categoryId,
    subCategory.subCategoryId, // Selected subcategory ID
    category.subCategories!.map((e) => e.subCategoryId).toList(), // List of subcategory IDs
    category.subCategories!.map((e) => e.name).toList(), // List of subcategory names
    category.subCategories!.indexOf(subCategory), // Pass the index of the selected subcategory
  ]);
}

}
