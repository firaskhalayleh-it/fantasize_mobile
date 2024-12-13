import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import '../../../data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';

class ProductsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rxn<User> user = Rxn<User>();
  RxInt tabBarIndex = 0.obs;

  var isLoading = true.obs;
  var productList = <Product>[].obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late TabController tabController;
  var userName = 'Guest'.obs;
  var userProfilePicture = ''.obs;
  RxInt subCategoryId = 0.obs;
  RxList<String> subCategoryNames = <String>[].obs;
  List subCategoryIds = [];
  int categoryId = 0;
  var packageList = <Package>[].obs;

  @override
  void onInit() {
    var arguments = Get.arguments;
    categoryId = arguments[0];
    subCategoryId.value = arguments[1]; // Get the selected subCategory ID
    subCategoryIds = arguments[2];
    subCategoryNames.value = List<String>.from(arguments[3]);

    // Initialize TabController for subcategories
    tabController = TabController(length: subCategoryNames.length, vsync: this);

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        // Update the tab index and fetch products for the selected tab
        changeTabBarIndex(tabController.index);
      }
    });

    // Ensure the tab matches the selected subcategory
    tabBarIndex.value = subCategoryIds
        .indexOf(subCategoryId.value); // Set the selected tab index
    tabController.index = tabBarIndex
        .value; // Update the tabController to reflect the selected tab

    // Fetch products for the initially selected subcategory
    fetchProducts(categoryId, subCategoryId.value);
    super.onInit();
  }

  Future<void> loadUserData() async {
    String? userData = await _secureStorage.read(key: 'user_data');

    if (userData != null) {
      user.value = User.fromJson(jsonDecode(userData));
    }

    if (user.value != null) {
      userName.value = user.value!.username;
      userProfilePicture.value =
          user.value!.userProfilePicture?.entityName?.toString() ??
              'profile.jpg';
    }
  }

  void fetchProducts(int categoryId, int subCategoryId) async {
    try {
      isLoading(true);

      String? token = await _secureStorage.read(key: 'jwt_token');

      loadUserData();

      if (token == null) {
        Get.snackbar('Error', 'No token available');
        isLoading(false);
        return;
      }

      bool isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        Get.snackbar('Error', 'Token has expired. Please login again.');
        isLoading(false);
        return;
      }

      // Fetch the products
      final response = await http.get(
        Uri.parse(
            '${Strings().apiUrl}/$categoryId/$subCategoryId/getAllproducts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        var products = data.map((json) => Product.fromJson(json)).toList();
        productList.assignAll(products);
      } else if (response.statusCode == 401) {
        Get.snackbar('Unauthorized', 'Invalid or missing token');
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'No products found');
        productList.clear();
        packageList.clear();
      } else if (response.statusCode == 500) {
        Get.snackbar('Error', 'Internal server error');
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading(false);
    }
  }

  void NavigateToProductDetails(int index) {
    productList[index].productId;
    if (productList[index].productId != null) {
      Get.toNamed('/product-details',
          arguments: [productList[index].productId]);
    } else {
      Get.snackbar('Error', 'Product ID is null');
    }
  }

  // This method will change the tab index dynamically and fetch products for the new tab
  void changeTabBarIndex(int index) {
    tabBarIndex.value = index;
    subCategoryId.value = subCategoryIds[index];
    if (subCategoryNames[index] == "Packages") {
      fetchPackages(categoryId, subCategoryId.value);
    } else {
      fetchProducts(categoryId, subCategoryId.value);
    }
  }

  void fetchPackages(int categoryId, int subCategoryId) async {
    try {
      isLoading(true);
      String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'No token available');
        isLoading(false);
        return;
      }

      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/$categoryId/$subCategoryId/packages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        var packages = data.map((json) => Package.fromJson(json)).toList();
        packageList.assignAll(packages);
      } else {
        Get.snackbar('Error', 'Failed to load packages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch packages: $e');
    } finally {
      isLoading(false);
    }
  }
}
