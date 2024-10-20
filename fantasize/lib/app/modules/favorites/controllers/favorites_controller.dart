import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesController extends GetxController {
  var isLoading = true.obs;
  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  RxList<Product> favoritesList =
      RxList<Product>(); // Updated to RxList to store Product model

  @override
  void onReady() {
    fetchFavorites();
    super.onReady();
  }

  void NavigateToProductDetails(int index) {
    favoritesList[index].productId;
    if (favoritesList[index].productId != null) {
      Get.toNamed('/product-details',
          arguments: [favoritesList[index].productId]);
    } else {
      Get.snackbar('Error', 'Product ID is null');
    }
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading(true);

      var jwtToken = await _secureStorage.read(key: 'jwt_token');

      var response = await http.get(
        Uri.parse(
            '${Strings().apiUrl}/favorites'), // Updated URL to fetch favorites

        // Updated headers to include the JWT token
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Map the products to the Product model
        var products = data
            .map<Product>((item) => Product.fromJson(item['Product']))
            .toList();
        favoritesList.assignAll(products);
      } 
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  void removeFromFavorites(int productId) {
    favoritesList.removeWhere((item) => item.productId == productId);
  }

  void reloadFavorites() {
    fetchFavorites();
  }
}
