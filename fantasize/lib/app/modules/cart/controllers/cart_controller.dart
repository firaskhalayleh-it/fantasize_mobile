import 'package:fantasize/app/data/models/address_model.dart';
import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/data/models/payment_method.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';
import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
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
    if (Get.isRegistered<ProductDetailsController>()) {
      Get.delete<ProductDetailsController>();
    }
    if (Get.isRegistered<PackageDetailsController>()) {
      Get.delete<PackageDetailsController>();
    }
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
      }

      if (response.statusCode == 404) {
        Get.snackbar('Error', 'No addresses found');
        addresses.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching addresses: $e');
    }
  }

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
        Get.snackbar('Message', 'No payment methods found');
        paymentMethods.value = [];
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
        'PaymentMethodID': (selectedPaymentMethodId.value.toString()),
        'AddressID': (selectedAddressId.value.toString()),
        'IsGift': isGift.value,
        'IsAnonymous': isAnonymous.value,
      };

      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Checkout completed successfully');
        fetchCart(); // Refresh cart after checkout
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'Invalid request data');
        print('Invalid request data' + response.body);
        print(payload.values);
      } else {
        Get.snackbar('Error', 'Failed to checkout');
        print('Failed to checkout' + response.body);
        print(payload.values);
        print(response.statusCode);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error during checkout: $e');
      print('Error during checkout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrderProduct(int orderProductId) async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.delete(
        Uri.parse('${Strings().apiUrl}/orderproduct/$orderProductId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Product removed from cart');
        fetchCart(); // Refresh cart after deletion
      } else {
        Get.snackbar('Error', 'Failed to remove product from cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error removing product from cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete order package
  Future<void> deleteOrderPackage(int orderPackageId) async {
    isLoading.value = true;
    String? token = await storage.read(key: 'jwt_token');
    try {
      var response = await http.delete(
        Uri.parse('${Strings().apiUrl}/orderpackage/$orderPackageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Package removed from cart');
        fetchCart(); // Refresh cart after deletion
      } else {
        Get.snackbar('Error', 'Failed to remove package from cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error removing package from cart: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
