// lib/app/modules/order_history/controllers/order_history_controller.dart

import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/order_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fantasize/app/global/strings.dart';

class OrderHistoryController extends GetxController {
  var isLoading = true.obs;
  var orders = <Order>[].obs;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String apiUrl = "${Strings().apiUrl}/orders";
  var expandedIndices = <int>[].obs;

  // Variables for search parameters
  var searchStatus = ''.obs;
  var searchProductName = ''.obs;
  var searchPackageName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        orders.value =
            responseData.map((orderJson) => Order.fromJson(orderJson)).toList();
      } else {
        print('Failed to load order history: ${response.body}');
        Get.snackbar('Error', 'Failed to load order history');
      }
    } catch (e) {
      print('Error fetching order history: $e');
      Get.snackbar('Error', 'An error occurred while fetching orders');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpansion(int index) {
    if (expandedIndices.contains(index)) {
      expandedIndices.remove(index);
    } else {
      expandedIndices.add(index);
    }
  }

  /// Update the status of an order
  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      } 
      print(orderId);

      var url = Uri.parse('${Strings().apiUrl}/orders/$orderId');
      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'Status': orderStatusToString(newStatus),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order status updated to ${orderStatusToString(newStatus)}');
        fetchOrderHistory(); // Refresh the order list
      } else {
        Get.snackbar('Error', 'Failed to update order status: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }

  /// Update an order product
  Future<void> updateOrderProduct(int orderId, int orderProductId, int newProductId, int newQuantity, List<OrderedOption> orderedOptions) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      var url = Uri.parse('${Strings().apiUrl}/order/$orderId/$orderProductId');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'productId': newProductId,
          'quantity': newQuantity,
          'OrderedOptions': orderedOptions.map((option) => option.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order product updated successfully');
        fetchOrderHistory(); // Refresh the order list
      } else {
        Get.snackbar('Error', 'Failed to update order product: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order product: $e');
    }
  }

  /// Update an order package
  Future<void> updateOrderPackage(int orderId, int orderPackageId, int newPackageId, int newQuantity, List<OrderedOption> orderedOptions) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      var url = Uri.parse('${Strings().apiUrl}/orderpackage/$orderId/$orderPackageId');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'packageId': newPackageId,
          'quantity': newQuantity,
          'OrderedOptions': orderedOptions.map((option) => option.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order package updated successfully');
        fetchOrderHistory(); // Refresh the order list
      } else {
        Get.snackbar('Error', 'Failed to update order package: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order package: $e');
    }
  }

  /// Perform search with optional parameters
  Future<void> searchOrders({
    String? status,
    String? productName,
    String? packageName,
  }) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      var url = Uri.parse('${Strings().searchUrl}/order');
      Map<String, dynamic> searchParams = {};

      if (status != null && status.isNotEmpty) {
        searchParams['Status'] = status;
      }
      if (productName != null && productName.isNotEmpty) {
        searchParams['Product'] = {'Name': productName};
      }
      if (packageName != null && packageName.isNotEmpty) {
        searchParams['Package'] = {'Name': packageName};
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'search': searchParams,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        orders.value =
            responseData.map((orderJson) => Order.fromJson(orderJson)).toList();
      } else {
        Get.snackbar('Error', 'Failed to search orders: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search orders: $e');
    }
  }

  /// Reset search and fetch all orders
  Future<void> resetSearch() async {
    searchStatus.value = '';
    searchProductName.value = '';
    searchPackageName.value = '';
    fetchOrderHistory();
  }
}
