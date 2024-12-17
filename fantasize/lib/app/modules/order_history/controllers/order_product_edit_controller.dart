// lib/app/modules/order_product_edit/controllers/order_product_edit_controller.dart

import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/order_product_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:mime/mime.dart'; // For mime type checking
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as path;

class OrderProductEditController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  var isLoading = true.obs;
  var orderId = 0.obs;
  var orderProductId = 0.obs;
  var currentProductId = 0.obs; // Observable
  var currentQuantity = 1.obs; // Observable
  OrderProduct? orderProduct; // To store the fetched OrderProduct

  RxList<OrderedCustomization> orderedCustomizations =
      <OrderedCustomization>[].obs;

  // Maps for managing UI state
  final Map<String, RxBool> _attachMessageVisibility = {};
  final Map<String, RxString> _uploadedImages = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void onInit() {
    super.onInit();
    fetchArguments();
    fetchOrderProductData();
  }

  /// Fetch arguments passed to this view
  void fetchArguments() {
    var args = Get.arguments;
    if (args != null) {
      orderId.value = int.tryParse(args['orderId'].toString()) ?? 0;
      orderProductId.value =
          int.tryParse(args['orderProductId'].toString()) ?? 0;
      currentProductId.value =
          int.tryParse(args['currentProductId'].toString()) ?? 0;
      currentQuantity.value =
          int.tryParse(args['currentQuantity'].toString()) ?? 1;
    } else {
      Get.snackbar('Error', 'No order product data provided');
    }
  }

  /// Fetch OrderProduct data from API
  Future<void> fetchOrderProductData() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        isLoading.value = false;
        return;
      }

      var url =
          Uri.parse('${Strings().apiUrl}/orderproduct/${orderProductId.value}');
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
        // Assuming the API returns a single OrderProduct object
        orderProduct = OrderProduct.fromJson(data);
        if (orderProduct?.orderedCustomization != null) {
          orderedCustomizations.value = [orderProduct!.orderedCustomization!];
        }
      } else {
        Get.snackbar('Error',
            'Failed to fetch order product: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch order product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update the order product via API
  Future<void> updateOrderProduct() async {
    try {
      isLoading.value = true; // Show loading indicator

      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        isLoading.value = false;
        return;
      }

      // Flatten orderedOptions from orderedCustomizations
      List<OrderedOption> flattenedOptions = orderedCustomizations
          .map((customization) => customization.selectedOptions)
          .expand((options) => options)
          .toList();

      // Check if there are any uploadPicture options
      bool hasUploadPicture = flattenedOptions.any((option) =>
          option.type.toLowerCase() == 'uploadpicture' &&
          option.optionValues.any((val) => val.filePath != null && val.filePath!.isNotEmpty));

      if (hasUploadPicture) {
        // Use MultipartRequest
        var uri = Uri.parse(
            '${Strings().apiUrl}/orderproduct/${orderId.value}/${orderProductId.value}');
        var request = http.MultipartRequest('PUT', uri);
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        });

        // Prepare orderedOptions JSON
        List<Map<String, dynamic>> orderedOptionsJson = [];
        for (var option in flattenedOptions) {
          Map<String, dynamic> optionJson = {
            'name': option.name,
            'type': option.type,
            'optionValues': option.optionValues.map((val) {
              Map<String, dynamic> valJson = {
                'name': val.name,
                'value': val.value,
                'isSelected': val.isSelected.value,
              };
              // Include filePath if present and relevant
              if (option.type.toLowerCase() == 'uploadpicture') {
                valJson['filePath'] = val.filePath ?? '';
              } else if (option.type.toLowerCase() == 'image') {
                valJson['filePath'] = val.filePath ?? '';
              }
              return valJson;
            }).toList(),
          };
          orderedOptionsJson.add(optionJson);
        }

        // Add JSON as a field
        Map<String, dynamic> jsonFields = {
          'quantity': currentQuantity.value,
          'orderedOptions': orderedOptionsJson,
        };

        request.fields['data'] = json.encode(jsonFields);

        // Attach files
        for (var option in flattenedOptions) {
          if (option.type.toLowerCase() == 'uploadpicture') {
            for (var optionValue in option.optionValues) {
              if (optionValue.filePath != null && optionValue.filePath!.isNotEmpty) {
                File file = File(optionValue.filePath!);
                if (await file.exists()) {
                  // Validate mime type
                  String? mimeType = lookupMimeType(file.path);
                  if (mimeType != null &&
                      (mimeType == 'image/jpeg' ||
                          mimeType == 'image/jpg' ||
                          mimeType == 'image/png')) {
                    request.files.add(await http.MultipartFile.fromPath(
                      'file', // Adjust field name as per API
                      file.path,
                      filename: path.basename(file.path),
                      contentType: MediaType.parse(mimeType),
                    ));
                  } else {
                    Get.snackbar('Error', 'Unsupported file type: $mimeType');
                    isLoading.value = false;
                    return;
                  }
                }
              }
            }
          }
        }

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          Get.snackbar('Success', 'Order product updated successfully');
          Get.back(); // Navigate back to order history
          Get.find<OrderHistoryController>()
              .fetchOrderHistory(); // Refresh order list
        } else {
          Get.snackbar('Error',
              'Failed to update order product: ${response.statusCode} ${response.body}');
        }
      } else {
        // No uploadPicture options, proceed with standard PUT request
        // Prepare orderedOptions JSON
        List<Map<String, dynamic>> orderedOptionsJson = [];
        for (var option in flattenedOptions) {
          Map<String, dynamic> optionJson = {
            'name': option.name,
            'type': option.type,
            'optionValues': option.optionValues.map((val) {
              Map<String, dynamic> valJson = {
                'name': val.name,
                'value': val.value,
                'isSelected': val.isSelected.value,
              };
              // For 'image' type options, include filePath
              if (option.type.toLowerCase() == 'image') {
                valJson['filePath'] = val.filePath ?? '';
              }
              return valJson;
            }).toList(),
          };
          orderedOptionsJson.add(optionJson);
        }

        var url = Uri.parse(
            '${Strings().apiUrl}/orderproduct/${orderProductId.value}');
        var response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
          body: json.encode({
            'quantity': currentQuantity.value,
            'orderedOptions': orderedOptionsJson,
          }),
        );

        if (response.statusCode == 200) {
          Get.snackbar('Success', 'Order product updated successfully');
          Get.back(); // Navigate back to order history
          Get.find<OrderHistoryController>()
              .fetchOrderHistory(); // Refresh order list
        } else {
          Get.snackbar('Error',
              'Failed to update order product: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order product: $e');
    } finally {
      isLoading.value = false; // Hide loading indicator
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
      var customization = orderedCustomizations
          .firstWhereOrNull((c) => c.orderedCustomizationId == customizationId);
      if (customization != null) {
        var existingOption = customization.selectedOptions
            .firstWhereOrNull((opt) => opt.name == optionName);
        if (existingOption != null &&
            existingOption.optionValues.isNotEmpty &&
            existingOption.optionValues.first.value.isNotEmpty) {
          _textControllers[key]!.text =
              existingOption.optionValues.first.value;
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
      // Initialize with existing filePath if any
      var customization = orderedCustomizations
          .firstWhereOrNull((c) => c.orderedCustomizationId == customizationId);
      if (customization != null) {
        var existingOption = customization.selectedOptions
            .firstWhereOrNull((opt) => opt.name == optionName);
        if (existingOption != null &&
            existingOption.optionValues.isNotEmpty &&
            existingOption.optionValues.first.filePath != null &&
            existingOption.optionValues.first.filePath!.isNotEmpty) {
          _uploadedImages[key]!.value =
              existingOption.optionValues.first.filePath!;
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
    final customization = orderedCustomizations
        .firstWhereOrNull((c) => c.orderedCustomizationId == customizationId);

    if (customization == null) return;

    // Find the specific option
    final option = customization.selectedOptions
        .firstWhereOrNull((opt) => opt.name == optionName);

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
        // Update the filePath
        if (option.optionValues.isNotEmpty) {
          option.optionValues.first.filePath = selectedValue;
        }
        break;
      default:
        break;
    }
  }

  /// Check if an option is selected
  bool isOptionSelected(int customizationId, String optionValue) {
    final customization = orderedCustomizations
        .firstWhereOrNull((c) => c.orderedCustomizationId == customizationId);

    if (customization == null) return false;

    return customization.selectedOptions.any((opt) => opt.optionValues.any(
        (v) =>
            v.value == optionValue &&
            (v.isSelected.value || v.filePath?.isNotEmpty == true)));
  }

  /// Increment Quantity
  void incrementQuantity() {
    currentQuantity.value++;
  }

  /// Decrement Quantity
  void decrementQuantity() {
    if (currentQuantity.value > 1) currentQuantity.value--;
  }

  void saveChanges() {
    updateOrderProduct();
  }
}
