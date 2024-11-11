import 'package:fantasize/app/data/models/payment_method.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentMethodController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProfileController profileController = Get.find();
  // Observables for form data
  var paymentMethod = PaymentMethod().obs;
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController cardholderNameController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Observables for checkbox states
  var agreeToTerms = false.obs;
  var saveCardDetails = false.obs;

  // Base API URL
  final String baseUrl = Strings().apiUrl;

  @override
  void onInit() {
    super.onInit();
    paymentMethod.value = PaymentMethod();

    if (Get.arguments != null && Get.arguments['paymentMethod'] != null) {
      paymentMethod.value = Get.arguments['paymentMethod'];
      cardNumberController.text = paymentMethod.value.cardNumber ?? '';
      cardholderNameController.text = paymentMethod.value.cardholderName ?? '';
      if (paymentMethod.value.expirationDate != null) {
        expirationDateController.text =
            '${paymentMethod.value.expirationDate!.month.toString().padLeft(2, '0')}/${paymentMethod.value.expirationDate!.year.toString().substring(2)}';
      }
      cvvController.text = paymentMethod.value.cvv?.toString() ?? '';
    }
  }

  // Method to validate form, update model, and call API
  Future<void> savePaymentMethod() async {
    if (formKey.currentState!.validate() && agreeToTerms.value) {
      // Update the PaymentMethod model with form data
      paymentMethod.update((method) {
        method?.cardNumber = cardNumberController.text;
        method?.cardholderName = cardholderNameController.text;
        method?.cvv = int.tryParse(cvvController.text);
        method?.method = 'Credit Card';
        method?.cardType = determineCardType(cardNumberController.text);
        updateExpirationDate(expirationDateController.text);
      });

      // If "saveCardDetails" is checked, call the API to save the payment
      if (saveCardDetails.value) {
        if (paymentMethod.value.paymentMethodID == null) {
          await postPaymentMethod();
          profileController.fetchUserData();
        } else {
          await updatePaymentMethod();
          profileController.fetchUserData();
        }
      } else {
        Get.snackbar('Info', 'Card details not saved as per your preference.');
      }
    } else {
      Get.snackbar('Error', 'Please complete all fields and agree to terms');
    }
  }

  // API POST request function using PaymentMethod model
  Future<void> postPaymentMethod() async {
    try {
      // Retrieve JWT token
      var jwtToken = await _storage.read(key: 'jwt_token');

      // Convert the PaymentMethod model to JSON
      final payload = paymentMethod.value.toJson();

      // API endpoint for creating payment method
      final apiUrl = '$baseUrl/user/create_payment_method_user';

      // Make the POST request
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
        body: json.encode(payload),
      );

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Success', 'Payment method saved successfully');
      } else {
        Get.snackbar(
            'Error', 'Failed to save payment method: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while saving payment method');
    }
  }

  // Updated API PUT request function for updating payment method
  Future<void> updatePaymentMethod() async {
    try {
      // Retrieve JWT token
      var jwtToken = await _storage.read(key: 'jwt_token');

      // Ensure paymentMethodID is available
      if (paymentMethod.value.paymentMethodID == null) {
        Get.snackbar('Error', 'No PaymentMethodID to update');
        return;
      }

      // Convert the PaymentMethod model to JSON
      final payload = paymentMethod.value.toJson();

      // API endpoint for updating payment method
      final apiUrl = '$baseUrl/user/update_payment_method_user';

      // Make the PUT request
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
        body: json.encode(payload),
      );

      // Handle response
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Payment method updated successfully');
      } else {
        Get.snackbar(
            'Error', 'Failed to update payment method: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while updating payment method');
    }
  }

  // New function to delete payment method
  Future<void> deletePaymentMethod() async {
    if (paymentMethod.value.paymentMethodID == null) {
      Get.snackbar('Error', 'No PaymentMethodID to delete');
      return;
    }

    try {
      // Retrieve JWT token
      var jwtToken = await _storage.read(key: 'jwt_token');

      // API endpoint for deleting payment method
      final apiUrl = '$baseUrl/user/delete_payment_method_user';

      // Prepare the payload
      final payload = {
        'PaymentMethodID': paymentMethod.value.paymentMethodID,
      };

      // Make the DELETE request
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
          'cookie': 'authToken=$jwtToken',
        },
        body: json.encode(payload),
      );

      // Handle response
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Payment method deleted successfully');

        profileController.fetchUserData();
      } else {
        Get.snackbar(
            'Error', 'Failed to delete payment method: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while deleting payment method');
    }
  }

  // Helper function to determine card type
  String determineCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'MasterCard';
    if (cardNumber.startsWith('3')) return 'American Express';
    return 'Unknown';
  }

  void updateExpirationDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length == 2 && parts[0].length == 2) {
        final month = int.tryParse(parts[0]);
        final yearPart = parts[1];
        final year = yearPart.length == 2
            ? (int.tryParse(yearPart) != null
                ? int.parse(yearPart) + 2000
                : null)
            : int.tryParse(yearPart);

        if (month != null && month >= 1 && month <= 12 && year != null) {
          paymentMethod.update((val) {
            val?.expirationDate = DateTime(year, month);
          });
        } else {
          throw FormatException('Invalid month or year');
        }
      } else {
        throw FormatException('Invalid format');
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid date format. Please use MM/YY or MM/YYYY');
    }
  }

  // Clean up resources
  @override
  void onClose() {
    cardNumberController.dispose();
    expirationDateController.dispose();
    cardholderNameController.dispose();
    cvvController.dispose();
    super.onClose();
  }
}
