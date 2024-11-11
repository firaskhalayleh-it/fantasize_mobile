// lib/app/modules/order_history/controllers/order_history_controller.dart

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
      }
    } catch (e) {
      print('Error fetching order history: $e');
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
}
