import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';

import 'package:fantasize/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class OrderProductEditController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Loading state
  var isLoading = true.obs;
  
  // Order details
  int orderId = 0;
  int orderProductId = 0;
  int currentProductId = 0;
  int currentQuantity = 1;
  
  // Ordered Customization
  OrderedCustomization? orderedCustomization;
  
  // TextEditingControllers for attachMessage options
  final Map<String, TextEditingController> _textControllers = {};
  
  // Uploaded images paths for uploadPicture options
  final Map<String, RxString> _uploadedImages = {};
  
  // Attach message visibility state
  final Map<String, RxBool> _attachMessageVisibility = {};
  
  @override
  void onInit() {
    super.onInit();
    fetchArguments();
  }
  
  /// Fetch and parse arguments passed to this view
  void fetchArguments() {
    var args = Get.arguments;
    if (args != null) {
      // Parse order details
      orderId = int.parse(args['orderId'].toString());
      orderProductId = args['orderProductId'] is String
          ? int.parse(args['orderProductId'])
          : args['orderProductId'];
      currentProductId = args['currentProductId'] is String
          ? int.parse(args['currentProductId'])
          : args['currentProductId'];
      currentQuantity = args['currentQuantity'] is String
          ? int.parse(args['currentQuantity'])
          : args['currentQuantity'];
    
      // Parse orderedCustomization if available
      if (args['orderedCustomization'] != null) {
        orderedCustomization = OrderedCustomization.fromJson(args['orderedCustomization']);
      }
    } else {
      Get.snackbar('Error', 'No order product data provided');
    }
    isLoading.value = false;
  }
  
  /// Update the order product via API
  Future<void> updateOrderProduct() async {
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
          'productId': currentProductId,
          'quantity': currentQuantity,
          'OrderedCustomization': orderedCustomization?.toJson(),
        }),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order product updated successfully');
        Get.back(); // Navigate back to order history
        Get.find<OrderHistoryController>().fetchOrderHistory(); // Refresh order list
      } else {
        Get.snackbar('Error', 'Failed to update order product: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order product: $e');
    }
  }
  
  /// Get TextEditingController for Attach Message
  TextEditingController getTextController(String optionName) {
    if (!_textControllers.containsKey(optionName)) {
      _textControllers[optionName] = TextEditingController();
      // Listen to changes and update the orderedCustomization accordingly
      _textControllers[optionName]!.addListener(() {
        updateAttachMessage(optionName, _textControllers[optionName]!.text);
      });
    }
    return _textControllers[optionName]!;
  }
  
  /// Toggle Attach Message visibility
  void toggleAttachMessageVisibility(String optionName) {
    if (!_attachMessageVisibility.containsKey(optionName)) {
      _attachMessageVisibility[optionName] = false.obs;
    }
    _attachMessageVisibility[optionName]!.toggle();
  }
  
  /// Get Attach Message visibility
  RxBool getAttachMessageVisibility(String optionName) {
    if (!_attachMessageVisibility.containsKey(optionName)) {
      _attachMessageVisibility[optionName] = false.obs;
    }
    return _attachMessageVisibility[optionName]!;
  }
  
  /// Update Attach Message in the model
  void updateAttachMessage(String optionName, String message) {
    if (orderedCustomization == null) return;
    var option = orderedCustomization!.selectedOptions.firstWhereOrNull((opt) => opt.name == optionName);
    if (option == null) return;
    if (option.type.toLowerCase() == 'attachmessage') {
      if (option.optionValues.isNotEmpty) {
        option.optionValues[0].value = message;
      }
    }
  }
  
  /// Get Uploaded Image Path for uploadPicture options
  RxString getUploadedImagePath(String optionName) {
    if (!_uploadedImages.containsKey(optionName)) {
      _uploadedImages[optionName] = ''.obs;
    }
    return _uploadedImages[optionName]!;
  }
  
  /// Update Uploaded Image Path in the model
  void updateUploadedImage(String optionName, String imagePath) {
    if (orderedCustomization == null) return;
    var option = orderedCustomization!.selectedOptions.firstWhereOrNull((opt) => opt.name == optionName);
    if (option == null) return;
    if (option.type.toLowerCase() == 'uploadpicture') {
      if (option.optionValues.isNotEmpty) {
        option.optionValues[0].fileName = imagePath;
      }
    }
    getUploadedImagePath(optionName).value = imagePath;
  }
  
  /// Update selected option based on customization
  void updateSelectedOption(String optionName, String selectedValue) {
    if (orderedCustomization == null) return;
    var option = orderedCustomization!.selectedOptions.firstWhereOrNull((opt) => opt.name == optionName);
    if (option == null) return;
    
    switch (option.type.toLowerCase()) {
      case 'button':
      case 'color':
      case 'image':
        // Deselect all other options
        option.optionValues.forEach((optValue) {
          if (optValue.value == selectedValue) {
            optValue.isSelected.value = true;
          } else {
            optValue.isSelected.value = false;
          }
        });
        break;
      // 'attachMessage' and 'uploadPicture' are handled separately
      default:
        break;
    }
  }
  
  /// Check if an option is selected
  bool isOptionSelected(String optionName, String optionValue) {
    if (orderedCustomization == null) return false;
    var option = orderedCustomization!.selectedOptions.firstWhereOrNull((opt) => opt.name == optionName);
    if (option == null) return false;
    
    if (option.type.toLowerCase() == 'uploadpicture') {
      return option.optionValues.isNotEmpty && option.optionValues[0].fileName!.isNotEmpty;
    }
    
    return option.optionValues.any((optValue) => optValue.value == optionValue && optValue.isSelected.value);
  }
  
  /// Increment Quantity
  void incrementQuantity() {
    currentQuantity++;
  }
  
  /// Decrement Quantity
  void decrementQuantity() {
    if (currentQuantity > 1) currentQuantity--;
  }
}
