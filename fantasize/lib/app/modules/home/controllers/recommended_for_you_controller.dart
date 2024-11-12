import 'package:get/get.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendedForYouController extends GetxController {
  RxList<Product> newArrivalsProducts = <Product>[].obs;
  RxList<dynamic> newArrivalsPackages = <Package>[].obs;
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecommendedForYou();
  }

  Future<void> fetchRecommendedForYou() async {
    isLoading.value = true;
    String? token = await secureStorage.read(key: 'jwt_token');
    var response = await http.get(
      Uri.parse('${Strings().homeUrl}/recommendedForYou'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': 'authToken=$token',
      },
    );

    if (response.statusCode == 200) {
      print('New arrivals fetched');

      // Clear existing lists
      newArrivalsProducts.clear();
      newArrivalsPackages.clear();

      for (var item in jsonDecode(response.body)) {
        if (item.containsKey('ProductID')) {
          newArrivalsProducts.add(Product.fromJson(item));
        } else if (item.containsKey('PackageID')) {
          newArrivalsPackages.add(Package.fromJson(item));
        } else {
          print('Invalid item');
        }
      }
    } else {
      print('Failed to load new arrivals');
    }

    isLoading.value = false;
  }

}
