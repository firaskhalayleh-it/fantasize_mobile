// lib/app/modules/signup/controllers/signup_controller.dart
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/models/user_model.dart';

class SignupController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final errorMessage = ''.obs;
  final isLoading = false.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isConfirmPasswordValid = true.obs;

  // Password visibility controls
  final obscureText = true.obs;
  final confirmPasswordObscureText = true.obs;

  // Instance of secure storage to store JWT
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // User object to store the signed-up user data
  final user = Rxn<User>();

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void toggleConfirmPasswordObscureText() {
    confirmPasswordObscureText.value = !confirmPasswordObscureText.value;
  }

  // Email validation
  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    
    if (email.isEmpty) {
      isEmailValid.value = false;
      return 'Email is required';
    }
    
    if (!GetUtils.isEmail(email)) {
      isEmailValid.value = false;
      return 'Please enter a valid email address';
    }
    
    isEmailValid.value = true;
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    final password = value?.trim() ?? '';
    
    if (password.isEmpty) {
      isPasswordValid.value = false;
      return 'Password is required';
    }
    
    if (password.length < 8) {
      isPasswordValid.value = false;
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      isPasswordValid.value = false;
      return 'Password must contain uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      isPasswordValid.value = false;
      return 'Password must contain lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      isPasswordValid.value = false;
      return 'Password must contain number';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      isPasswordValid.value = false;
      return 'Password must contain special character';
    }
    
    isPasswordValid.value = true;
    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    
    if (confirmPassword.isEmpty) {
      isConfirmPasswordValid.value = false;
      return 'Please confirm your password';
    }
    
    if (confirmPassword != passwordController.text.trim()) {
      isConfirmPasswordValid.value = false;
      return 'Passwords do not match';
    }
    
    isConfirmPasswordValid.value = true;
    return null;
  }

  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    return isValid && isEmailValid.value && isPasswordValid.value && isConfirmPasswordValid.value;
  }

  // Signup API call logic
  Future<void> signup() async {
    if (!validateForm()) {
      Get.snackbar(
        'Validation Error',
        'Please check all fields and try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      var url = Uri.parse('${Strings().apiUrl}/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        String jwtToken = responseData['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
        user.value = User.fromJson(decodedToken);
        
        await secureStorage.write(key: 'jwt_token', value: jwtToken);
        
        Get.snackbar(
          'Success',
          'Registration successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        Get.offNamed('/home');
      } else {
        errorMessage.value = responseData['message'] ?? 'Registration failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.offNamed('/login');
  }

  Future<String?> getStoredToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  Future<void> getUserFromStoredToken() async {
    try {
      final token = await getStoredToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        user.value = User.fromJson(decodedToken);
      }
    } catch (e) {
      await deleteStoredToken();
      Get.offNamed('/login');
    }
  }

  Future<void> deleteStoredToken() async {
    await secureStorage.delete(key: 'jwt_token');
    user.value = null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}