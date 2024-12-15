// lib/app/modules/home/controllers/search_controller.dart

import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/models/product_model.dart';
import '../../../data/models/package_model.dart';
import '../../../global/strings.dart';

class SearchController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Search Parameters
  RxString name = ''.obs;
  RxString categoryName = ''.obs;
  RxString subCategoryName = ''.obs;
  RxString materialName = ''.obs;
  RxString brand = ''.obs;
  RxInt minPrice = 0.obs;
  RxInt maxPrice = 0.obs;
  RxBool offerAvailable = false.obs;
  RxInt offerDiscount = 0.obs;
  RxString optionName = ''.obs;

  // Search Results
  RxList<dynamic> searchResults = <dynamic>[].obs;

  // Loading State
  RxBool isLoading = false.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  final int limitPerPage = 5;

  /// Constructs the search query based on the provided parameters
  Map<String, dynamic> buildSearchQuery() {
    Map<String, dynamic> search = {};

    if (name.value.isNotEmpty) {
      search['Name'] = name.value;
    }
    if (categoryName.value.isNotEmpty) {
      search['Category'] = {'Name': categoryName.value};
    }
    if (subCategoryName.value.isNotEmpty) {
      search['SubCategory'] = {'Name': subCategoryName.value};
    }
    if (materialName.value.isNotEmpty) {
      search['Material'] = {'Name': materialName.value};
    }
    if (brand.value.isNotEmpty) {
      search['Brand'] = brand.value;
    }
    if (minPrice.value > 0) {
      search['minPrice'] = minPrice.value;
    }
    if (maxPrice.value > 0) {
      search['maxPrice'] = maxPrice.value;
    }
    if (offerAvailable.value) {
      search['offer'] = {
        'available': offerAvailable.value,
        if (offerDiscount.value > 0) 'discount': offerDiscount.value
      };
    }
    if (optionName.value.isNotEmpty) {
      search['option'] = {'name': optionName.value};
    }

    return {'search': search};
  }

  /// Performs the search operation
  Future<void> performSearch({int page = 1}) async {
    isLoading.value = true;
    try {
      String? token = await secureStorage.read(key: 'jwt_token');
      final response = await http.post(
        Uri.parse('${Strings().searchUrl}?page=$page&limit=$limitPerPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
        body: jsonEncode(buildSearchQuery()),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> products = responseData['data']['products'] ?? [];
        List<dynamic> packages = responseData['data']['packages'] ?? [];

        // Parse products
        List<Product> parsedProducts = products
            .map((json) => json.containsKey('ProductID') ? Product.fromJson(json) : null)
            .whereType<Product>()
            .toList();

        // Parse packages
        List<Package> parsedPackages = packages
            .map((json) => json.containsKey('PackageID') ? Package.fromJson(json) : null)
            .whereType<Package>()
            .toList();

        // Combine products and packages
        List<dynamic> combinedResults = [...parsedProducts, ...parsedPackages];

        if (page == 1) {
          searchResults.value = combinedResults;
        } else {
          searchResults.addAll(combinedResults);
        }

        currentPage.value = page;
      } else {
        print('Failed to perform search');
        print(response.body);
        print(response.statusCode);

        Get.snackbar('Error', 'Failed to perform search');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during search');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads more results for pagination
  Future<void> loadMore() async {
    await performSearch(page: currentPage.value + 1);
  }

  /// Resets the search parameters and results
  void resetSearch() {
    name.value = '';
    categoryName.value = '';
    subCategoryName.value = '';
    materialName.value = '';
    brand.value = '';
    minPrice.value = 0;
    maxPrice.value = 0;
    offerAvailable.value = false;
    offerDiscount.value = 0;
    optionName.value = '';
    searchResults.clear();
    currentPage.value = 1;
  }
}
