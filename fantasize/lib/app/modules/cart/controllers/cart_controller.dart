import 'package:fantasize/app/data/models/address_model.dart';
import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/data/models/payment_method.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController extends GetxController {
  final storage = FlutterSecureStorage();
  var cart = Rxn<Order>();
  var isLoading = false.obs;
  var addresses = <Address>[].obs;
  var paymentMethods = <PaymentMethod>[].obs;

  var homeController = Get.put(HomeController());

  var selectedAddressId = Rxn<int>();
  var selectedPaymentMethodId = Rxn<int>();
  var isGift = false.obs;
  var isAnonymous = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
    fetchAddresses();
    fetchPaymentMethods();
  }

  // Fetch cart data from the API
  Future<void> fetchCart() async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.get(
        Uri.parse('${Strings().apiUrl}/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      print('Fetched items for cart: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        cart.value = Order.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        cart.value = null;
        Get.snackbar('message', 'No items in cart');
      } else {
        Get.snackbar('Error', 'Failed to fetch cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Allow null values

// Update `fetchAddresses` to set `selectedAddressId` if it is null and addresses are fetched
  Future<void> fetchAddresses() async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.get(
        Uri.parse('${Strings().apiUrl}/user/get_address_user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List;
        addresses.value =
            jsonData.map((json) => Address.fromJson(json)).toList();

        // Set default selected address if list is not empty
        if (addresses.isNotEmpty && selectedAddressId.value == null) {
          selectedAddressId.value = addresses.first.addressID!;
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch addresses');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching addresses: $e');
    }
  }

// Update `fetchPaymentMethods` to set `selectedPaymentMethodId` if it is null and payment methods are fetched
  Future<void> fetchPaymentMethods() async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.get(
        Uri.parse('${Strings().apiUrl}/user/get_payment_method_user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List;
        paymentMethods.value =
            jsonData.map((json) => PaymentMethod.fromJson(json)).toList();

        // Set default selected payment method if list is not empty
        if (paymentMethods.isNotEmpty &&
            selectedPaymentMethodId.value == null) {
          selectedPaymentMethodId.value = paymentMethods.first.paymentMethodID!;
        }
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'No payment methods found');
      } else {
        Get.snackbar('Error', 'Failed to fetch payment methods');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching payment methods: $e');
    }
  }

  // Checkout API call
  Future<void> checkout() async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var payload = {
        'PaymentMethodID': selectedPaymentMethodId.value,
        'AddressID': selectedAddressId.value,
        'IsGift': isGift.value,
        'IsAnonymous': isAnonymous.value,
      };

      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Checkout completed successfully');
        fetchCart(); // Refresh cart after checkout
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'Invalid request data');
      } else {
        Get.snackbar('Error', 'Failed to checkout');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error during checkout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
