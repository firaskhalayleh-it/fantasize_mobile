// lib/app/modules/order_edit/controllers/order_edit_controller.dart

import 'package:fantasize/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderEditController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  var order = Rxn<Order>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      Order? passedOrder = Get.arguments as Order?;
      if (passedOrder != null) {
        order.value = passedOrder;
      } else {
        Get.snackbar('Error', 'No order data provided');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update the order via API after editing
  Future<void> updateOrder(Order updatedOrder) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      var url = Uri.parse('${Strings().apiUrl}/orders/${updatedOrder.orderId}');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'Status': orderStatusToString(OrderStatus.purchased), // Or other status based on logic
          // Include other fields that can be edited
          // For example, updating products or packages
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order updated successfully');
        Get.back(); // Navigate back to order history
        Get.find<OrderHistoryController>().fetchOrderHistory(); // Refresh order list
      } else {
        Get.snackbar('Error', 'Failed to update order: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    }
  }
}
