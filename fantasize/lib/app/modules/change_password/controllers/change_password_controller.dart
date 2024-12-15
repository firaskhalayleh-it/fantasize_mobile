import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> changePassword() async {
    try {
      isLoading.value = true;

      final response = await http.put(
        Uri.parse(
            '${Strings().apiUrl}/reset_password/${tokenController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Password has been changed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Navigate to login route
        Get.offAllNamed('/login');
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'An error occurred';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect to the server. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tokenController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
