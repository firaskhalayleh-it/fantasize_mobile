import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesController extends GetxController {
  var isLoading = true.obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Stores the list of favorite products.
  RxList<Product> favoriteProducts = RxList<Product>();

  /// Stores the list of favorite packages.
  RxList<Package> favoritePackages = RxList<Package>();

  @override
  void onReady() {
    fetchFavorites();
    super.onReady();
  }

  /// Navigate to details page, distinguishing between Product and Package.
  void navigateToDetails(dynamic item) {
    if (item is Product && item.productId != null) {
      Get.toNamed('/product-details', arguments: [item.productId]);
    } else if (item is Package && item.packageId != null) {
      Get.toNamed('/package-details', arguments: item.packageId);
    } else {
      Get.snackbar('Error', 'ID is null');
    }
  }

  /// Fetch favorite Products and Packages from your API.
  Future<void> fetchFavorites() async {
    try {
      isLoading(true);

      final jwtToken = await _secureStorage.read(key: 'jwt_token');
      // If no token, clear lists and prompt login or handle gracefully
      if (jwtToken == null) {
        favoriteProducts.clear();
        favoritePackages.clear();
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
        'cookie': 'authToken=$jwtToken',
      };

      final productUrl = Uri.parse('${Strings().apiUrl}/favorites');
      final packageUrl = Uri.parse('${Strings().apiUrl}/favoritePackages');

      // Fetch both in parallel
      final responses = await Future.wait([
        http.get(productUrl, headers: headers),
        http.get(packageUrl, headers: headers),
      ]);

      final productResponse = responses[0];
      final packageResponse = responses[1];

      // ---- Handle Products ----
      if (productResponse.statusCode == 200) {
        final productData = json.decode(productResponse.body);
        final productList = productData as List;
        final products = productList
            .map<Product>((item) => Product.fromJson(item['Product']))
            .toList();
        favoriteProducts.assignAll(products);
      } else if (productResponse.statusCode == 404) {
        // No favorites found for products
        favoriteProducts.clear();
      } else if (productResponse.statusCode == 401) {
        Get.snackbar('Error', 'Unauthorized for products');
      } else {
        // If you need more specific checks, add them here.
        // Otherwise, throw a generic error
        throw Exception(
            'Error fetching product favorites: ${productResponse.statusCode}');
      }

      // ---- Handle Packages ----
      if (packageResponse.statusCode == 200) {
        final packageData = json.decode(packageResponse.body);
        final packageList = packageData as List;
        final packages = packageList
            .map<Package>((item) => Package.fromJson(item['Package']))
            .toList();
        favoritePackages.assignAll(packages);
      } else if (packageResponse.statusCode == 404) {
        // No favorites found for packages
        favoritePackages.clear();
      } else if (packageResponse.statusCode == 401) {
        Get.snackbar('Error', 'Unauthorized for packages');
      } else {
        throw Exception(
            'Error fetching package favorites: ${packageResponse.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: Colors.red,
      );
      debugPrint('Error fetching favorites: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Locally remove item from favorites list
  void removeFromFavorites(int itemId, {bool isPackage = false}) {
    if (isPackage) {
      favoritePackages.removeWhere((item) => item.packageId == itemId);
    } else {
      favoriteProducts.removeWhere((item) => item.productId == itemId);
    }
  }

  /// Reload all favorites from server
  void reloadFavorites() {
    fetchFavorites();
  }
}
