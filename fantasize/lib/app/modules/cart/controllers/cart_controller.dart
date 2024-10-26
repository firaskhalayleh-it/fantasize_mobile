import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController extends GetxController {
  final storage = FlutterSecureStorage();
  var cart = Rxn<Order>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.get(
        Uri.parse('${Strings().apiUrl}/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'cookie': 'authToken=$token',
        },
      );
      
      if (response.statusCode == 200) {
        cart.value = Order.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        cart.value = null;
      } else {
        Get.snackbar('Error', 'Error fetching cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkout(
      int paymentMethodId, int addressId, bool isGift, bool isAnonymous) async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'PaymentMethodID': paymentMethodId,
          'AddressID': addressId,
          'IsGift': isGift,
          'IsAnonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Checkout completed successfully');
        fetchCart();
      } else {
        Get.snackbar('Error', 'Checkout failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error during checkout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
