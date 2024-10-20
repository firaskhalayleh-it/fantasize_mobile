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
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var errorMessage = ''.obs;
  // handle the obscure text for password

  var obscureText = true.obs;
  var confirmPasswordObscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void toggleConfirmPasswordObscureText() {
    confirmPasswordObscureText.value = !confirmPasswordObscureText.value;
  }

  // Instance of secure storage to store JWT
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // User object to store the signed-up user data
  var user = Rxn<User>();

  // Signup API call logic
  void signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate form fields
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = 'Please fill out all fields.';
      return;
    }

    // Validate password confirmation
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }
    var url = Uri.parse('${Strings().apiUrl}/register');

    // Send POST request to signup endpoint
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    try {
      // Define the signup API endpoint

      print(response.body);
      print(response.statusCode);

      // Check for successful signup (status code 200 or 201)
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Decode the response body to get the JWT token
        var responseData = jsonDecode(response.body);
        String jwtToken =
            responseData['token']; // Assuming token is returned on signup

        // Decode the JWT token to get user details
        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);

        // Create a User instance from the decoded token
        user.value = User.fromJson(decodedToken);

        // Store the JWT token securely
        await secureStorage.write(key: 'jwt_token', value: jwtToken);

        // Navigate to the home screen after successful signup
        Get.offNamed('/home');
      } else {
        // Display an error message if the signup failed
        Get.snackbar('Error', response.body);
      }
    } catch (e) {
      // Handle error cases such as network issues
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar('Error', ' ${response.body}');
    }
  }

  void goToLogin() {
    Get.offNamed('/login');
  }

  // Function to retrieve the stored token
  Future<String?> getStoredToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  // Function to retrieve the logged-in user from the stored token
  Future<void> getUserFromStoredToken() async {
    String? token = await getStoredToken();
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      user.value = User.fromJson(decodedToken);
    }
  }

  // Function to delete the stored token (for logout or token expiration)
  Future<void> deleteStoredToken() async {
    await secureStorage.delete(key: 'jwt_token');
    user.value = null;
  }
}
