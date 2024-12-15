// lib/app/modules/order_package_edit/controllers/order_package_edit_controller.dart

import 'package:fantasize/app/data/models/order_package_model.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class OrderPackageEditController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  var isLoading = true.obs;
  int orderId = 0;
  int orderPackageId = 0;
  int currentPackageId = 0;
  int currentQuantity = 1;
  OrderPackage? orderPackage; // To store the fetched OrderPackage

  List<OrderedCustomization> orderedCustomizations = [];

  // Maps for managing UI state
  final Map<String, RxBool> _attachMessageVisibility = {};
  final Map<String, RxString> _uploadedImages = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void onInit() {
    super.onInit();
    fetchArguments();
    fetchOrderPackageData();
  }

  /// Fetch arguments passed to this view
  void fetchArguments() {
    var args = Get.arguments;
    if (args != null) {
      orderId = int.tryParse(args['orderId'].toString()) ?? 0;
      orderPackageId = int.tryParse(args['orderPackageId'].toString()) ?? 0;
      currentPackageId = int.tryParse(args['currentPackageId'].toString()) ?? 0;
      currentQuantity = int.tryParse(args['currentQuantity'].toString()) ?? 1;
    } else {
      Get.snackbar('Error', 'No order package data provided');
    }
  }

  /// Fetch OrderPackage data from API
  Future<void> fetchOrderPackageData() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        isLoading.value = false;
        return;
      }

      var url = Uri.parse('${Strings().apiUrl}/order/$orderId/package/$orderPackageId');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Assuming the API returns a single OrderPackage object
        orderPackage = OrderPackage.fromJson(data);
        if (orderPackage?.orderedCustomization != null) {
          orderedCustomizations = [orderPackage!.orderedCustomization!];
        }
      } else {
        Get.snackbar('Error',
            'Failed to fetch order package: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch order package: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update the order package via API
  Future<void> updateOrderPackage() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      var url = Uri.parse('${Strings().apiUrl}/order/$orderId/package/$orderPackageId');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          'packageId': currentPackageId,
          'quantity': currentQuantity,
          'OrderedCustomizations': orderedCustomizations
              .map((customization) => customization.toJson())
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Order package updated successfully');
        Get.back(); // Navigate back to order history
        Get.find<OrderHistoryController>().fetchOrderHistory(); // Refresh order list
      } else {
        Get.snackbar('Error',
            'Failed to update order package: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order package: $e');
    }
  }

  /// Method to toggle Attach Message visibility
  RxBool getAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_attachMessageVisibility.containsKey(key)) {
      _attachMessageVisibility[key] = false.obs;
    }
    return _attachMessageVisibility[key]!;
  }

  /// Toggle Attach Message visibility
  void toggleAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    getAttachMessageVisibility(customizationId, optionName).toggle();
  }

  /// Get TextEditingController for Attach Message
  TextEditingController getTextController(
      int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
      // Initialize with existing value if any
      var customization = orderedCustomizations.firstWhereOrNull(
          (c) => c.orderedCustomizationId == customizationId);
      if (customization != null) {
        var existingOption = customization.selectedOptions.firstWhereOrNull(
            (opt) => opt.name == optionName);
        if (existingOption != null &&
            existingOption.optionValues.isNotEmpty &&
            existingOption.optionValues.first.value.isNotEmpty) {
          _textControllers[key]!.text = existingOption.optionValues.first.value;
        }
      }
      // Listen to changes and update the orderedCustomizations accordingly
      _textControllers[key]!.addListener(() {
        updateSelectedOption(
            customizationId, optionName, _textControllers[key]!.text);
      });
    }
    return _textControllers[key]!;
  }

  /// Get Uploaded Image Path for uploadPicture options
  RxString getUploadedImagePath(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_uploadedImages.containsKey(key)) {
      _uploadedImages[key] = ''.obs;
      // Initialize with existing fileName if any
      var customization = orderedCustomizations.firstWhereOrNull(
          (c) => c.orderedCustomizationId == customizationId);
      if (customization != null) {
        var existingOption = customization.selectedOptions.firstWhereOrNull(
            (opt) => opt.name == optionName);
        if (existingOption != null &&
            existingOption.optionValues.isNotEmpty &&
            existingOption.optionValues.first.fileName!.isNotEmpty) {
          _uploadedImages[key]!.value = existingOption.optionValues.first.fileName.toString();
        }
      }
    }
    return _uploadedImages[key]!;
  }

  /// Update Uploaded Image Path
  void updateUploadedImage(
      int customizationId, String optionName, String imagePath) {
    final key = '$customizationId-$optionName';
    getUploadedImagePath(customizationId, optionName).value = imagePath;
    // Update the corresponding option value
    updateSelectedOption(customizationId, optionName, imagePath);
  }

  /// Update selected option based on customization
  void updateSelectedOption(
      int customizationId, String optionName, String selectedValue) {
    // Find the customization
    final customization = orderedCustomizations.firstWhereOrNull(
        (c) => c.orderedCustomizationId == customizationId);

    if (customization == null) return;

    // Find the specific option
    final option = customization.selectedOptions.firstWhereOrNull(
        (opt) => opt.name == optionName);

    if (option == null) return;

    // Update the selected value based on the option type
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
      case 'attachmessage':
        // Update the comment
        if (option.optionValues.isNotEmpty) {
          option.optionValues.first.value = selectedValue;
        }
        break;
      case 'uploadpicture':
        // Update the fileName or image path
        if (option.optionValues.isNotEmpty) {
          option.optionValues.first.fileName = selectedValue;
        }
        break;
      default:
        break;
    }
  }

  /// Check if an option is selected
  bool isOptionSelected(int customizationId, String optionValue) {
    final customization = orderedCustomizations.firstWhereOrNull(
        (c) => c.orderedCustomizationId == customizationId);

    if (customization == null) return false;

    return customization.selectedOptions.any((opt) =>
        opt.optionValues.any((v) =>
            v.value == optionValue &&
            (v.isSelected.value || (v.fileName?.isNotEmpty ?? false))));
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
