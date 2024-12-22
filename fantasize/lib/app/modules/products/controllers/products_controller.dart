// products_controller.dart
import 'dart:async';
import 'dart:convert';

import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fantasize/app/global/strings.dart';

class ProductsController extends GetxController with GetSingleTickerProviderStateMixin {
  // User Information
  Rxn<User> user = Rxn<User>();
  var userName = 'Guest'.obs;
  var userProfilePicture = ''.obs;

  // Tab and Category Management
  RxInt tabBarIndex = 0.obs;
  RxInt subCategoryId = 0.obs;
  RxList<String> subCategoryNames = <String>[].obs;
  List subCategoryIds = [];
  int categoryId = 0;
  late TabController tabController;

  // Data Lists
  var isLoading = true.obs;
  var productList = <Product>[].obs;
  var packageList = <Package>[].obs;

  // Search Functionality
  var searchQuery = ''.obs;
  var filteredProductList = <Product>[].obs;
  var filteredPackageList = <Package>[].obs;
  Timer? _debounce;

  // Price Range Filtering
  var minPrice = Rxn<double>();
  var maxPrice = Rxn<double>();

  // Secure Storage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();

    // Initialize arguments
    var arguments = Get.arguments;
    if (arguments != null && arguments.length >= 4) {
      categoryId = arguments[0];
      subCategoryId.value = arguments[1]; // Selected subCategory ID
      subCategoryIds = arguments[2];
      subCategoryNames.value = List<String>.from(arguments[3]);
    } else {
      // Handle missing arguments appropriately
      categoryId = 0;
      subCategoryId.value = 0;
      subCategoryIds = [];
      subCategoryNames.value = ["Default"];
    }

    // Initialize TabController
    tabController = TabController(length: subCategoryNames.length, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        changeTabBarIndex(tabController.index);
      }
    });

    // Set initial tab index
    tabBarIndex.value = subCategoryIds.indexOf(subCategoryId.value);
    if (tabBarIndex.value == -1) {
      tabBarIndex.value = 0;
      subCategoryId.value = subCategoryIds.isNotEmpty ? subCategoryIds[0] : 0;
    }
    tabController.index = tabBarIndex.value;

    // Fetch initial data
    fetchData();

  }

  @override
  void onClose() {
    tabController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // Fetch Data Based on Current Tab
  void fetchData() {
    String currentTab = subCategoryNames[tabBarIndex.value].toLowerCase();
    if (currentTab == "packages" || currentTab == "package" ) {
      fetchPackages(categoryId, subCategoryId.value);
    } else {
      fetchProducts(categoryId, subCategoryId.value);
    }
  }

  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query.trim().toLowerCase();
      filterResults();
    });
  }

  // Set Price Range
  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    filterResults();
  }

  // Reset Price Range
  void resetPriceRange() {
    minPrice.value = null;
    maxPrice.value = null;
    filterResults();
  }

  // Filter Results Based on Search Query and Price Range
  void filterResults() {
    String currentTab = subCategoryNames[tabBarIndex.value].toLowerCase();
    double? min = minPrice.value;
    double? max = maxPrice.value;

    if (currentTab == "packages" || currentTab == "package") {
      Iterable<Package> tempPackages = packageList;

      // Apply Search Query Filter
      if (searchQuery.value.isNotEmpty) {
        tempPackages = tempPackages.where((package) {
          return package.name.toLowerCase().contains(searchQuery.value) ||
              package.price.toString().contains(searchQuery.value);
        });
      }

      // Apply Price Range Filter
      if (min != null) {
        tempPackages = tempPackages.where((package) => package.price >= min);
      }
      if (max != null) {
        tempPackages = tempPackages.where((package) => package.price <= max);
      }

      filteredPackageList.assignAll(tempPackages.toList());
    } else {
      Iterable<Product> tempProducts = productList;

      // Apply Search Query Filter
      if (searchQuery.value.isNotEmpty) {
        tempProducts = tempProducts.where((product) {
          return product.name.toLowerCase().contains(searchQuery.value) ||
              product.price.toString().contains(searchQuery.value);
        });
      }

      // Apply Price Range Filter
      if (min != null) {
        tempProducts = tempProducts.where((product) => double.tryParse(product.price) != null && double.parse(product.price) >= min);
      }
      if (max != null) {
        tempProducts = tempProducts.where((product) => double.tryParse(product.price) != null && double.parse(product.price) <= max);
      }

      filteredProductList.assignAll(tempProducts.toList());
    }
  }

  // Fetch Products from API
  Future<void> fetchProducts(int categoryId, int subCategoryId) async {
    try {
      isLoading(true);

      String? token = await _secureStorage.read(key: 'jwt_token');

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

      // API Call to Fetch Products
      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/$categoryId/$subCategoryId/getAllproducts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        var products = data.map((json) => Product.fromJson(json)).toList();
        productList.assignAll(products);
        filterResults();
      } else if (response.statusCode == 401) {
        Get.snackbar('Unauthorized', 'Invalid or missing token');
      } else if (response.statusCode == 404) {
        Get.snackbar('Message', 'No products found');
        productList.clear();
        filteredProductList.clear();
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

  // Fetch Packages from API
  Future<void> fetchPackages(int categoryId, int subCategoryId) async {
    try {
      isLoading(true);
      String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'No token available');
        isLoading(false);
        return;
      }

      // API Call to Fetch Packages
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
        filterResults();
      } else if (response.statusCode == 401) {
        Get.snackbar('Unauthorized', 'Invalid or missing token');
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'No packages found');
        packageList.clear();
        filteredPackageList.clear();
      } else if (response.statusCode == 500) {
        Get.snackbar('Error', 'Internal server error');
      } else {
        Get.snackbar('Error', 'Failed to load packages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch packages: $e');
    } finally {
      isLoading(false);
    }
  }

  // Navigate to Product Details
  void navigateToProductDetails(int index) {
    if (index < 0 || index >= filteredProductList.length) {
      Get.snackbar('Error', 'Invalid product index');
      return;
    }
    final productId = filteredProductList[index].productId;
    if (productId != null) {
      Get.toNamed('/product-details', arguments: [productId]);
    } else {
      Get.snackbar('Error', 'Product ID is null');
    }
  }

  // Navigate to Package Details
  void navigateToPackageDetails(int packageId) {
    Get.toNamed('/package-details', arguments: packageId);
  }

  // Change Tab Index and Fetch Corresponding Data
  void changeTabBarIndex(int index) {
    if (index < 0 || index >= subCategoryNames.length) return;

    tabBarIndex.value = index;
    subCategoryId.value = subCategoryIds[index];
    fetchData();

    // Reset search query and price range when tab changes
    searchQuery.value = '';
    resetPriceRange();
  }

  // Apply Price Filters
  void applyPriceFilter(double? min, double? max) {
    setPriceRange(min, max);
  }
}
