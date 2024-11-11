import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OffersController extends GetxController {
  RxBool isOfferLoading = false.obs;
  List<Product> productList = [];
  List<Package> packageList = [];

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    isOfferLoading.value = true;
    final secureStorage =
        FlutterSecureStorage(); // Replace with your secure storage instance
    final authToken = await secureStorage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${Strings().apiUrl}/offers'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'authToken=$authToken',
      },
    );

    if (response.statusCode == 200) {
      final offersData = json.decode(response.body) as List;

      productList = offersData
          .expand((offer) => offer['Products'])
          .map((productJson) => Product.fromJson(productJson))
          .toList();

      packageList = offersData
          .expand((offer) => offer['Packages'])
          .map((packageJson) => Package.fromJson(packageJson))
          .toList();
    } else {
      // Handle error
      print("Failed to fetch offers: ${response.statusCode}");
    }
    isOfferLoading.value = false;
  }
}
