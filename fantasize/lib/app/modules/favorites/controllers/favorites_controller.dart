import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesController extends GetxController {
  var isLoading = true.obs;
  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  RxList<Product> favoriteProducts = RxList<Product>(); // Updated for products
  RxList<Package> favoritePackages = RxList<Package>(); // New list for packages

  @override
  void onReady() {
    fetchFavorites();
    super.onReady();
  }

  // Navigate to details for either product or package based on type
  void navigateToDetails(dynamic item) {
    if (item is Product && item.productId != null) {
      Get.toNamed('/product-details', arguments: [item.productId]);
    } else if (item is Package && item.packageId != null) {
      Get.toNamed('/package-details', arguments: item.packageId);
    } else {
      Get.snackbar('Error', 'ID is null');
    }
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading(true);

      var jwtToken = await _secureStorage.read(key: 'jwt_token');

      // Fetch favorite products
      var productResponse = await http.get(
        Uri.parse('${Strings().apiUrl}/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
      );

      // Fetch favorite packages
      var packageResponse = await http.get(
        Uri.parse('${Strings().apiUrl}/favoritePackages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
      );

      // Process product favorites
      if (productResponse.statusCode == 200) {
        var productData = json.decode(productResponse.body);
        var products = productData
            .map<Product>((item) => Product.fromJson(item['Product']))
            .toList();
        favoriteProducts.assignAll(products);
      }

      // Process package favorites
      if (packageResponse.statusCode == 200) {
        var packageData = json.decode(packageResponse.body);
        var packages = packageData
            .map<Package>((item) => Package.fromJson(item['Package']))
            .toList();
        favoritePackages.assignAll(packages);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  void removeFromFavorites(int itemId, {bool isPackage = false}) {
    if (isPackage) {
      favoritePackages.removeWhere((item) => item.packageId == itemId);
    } else {
      favoriteProducts.removeWhere((item) => item.productId == itemId);
    }
  }

  void reloadFavorites() {
    fetchFavorites();
  }
}
