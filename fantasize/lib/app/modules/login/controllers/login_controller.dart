import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/models/user_model.dart';
import 'package:fantasize/app/global/strings.dart' ;

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var errorMessage = ''.obs;
  var obscureText = true.obs;
  // Instance of secure storage to store JWT
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // User object to store the logged-in user data
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    checkForToken(); // Check token when the app initializes
  }

  
  // Function to toggle the visibility of the password field
  void toggleObscureText() {
    obscureText.value = !obscureText.value; 
  }


  // Method to check for stored JWT token and navigate accordingly
  Future<void> checkForToken() async {
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token != null) {
      // Token exists, check if it's valid
      bool isTokenExpired = JwtDecoder.isExpired(token);

      if (!isTokenExpired) {
        // Decode the token to get user details
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print(
            'Decoded Token: $decodedToken'); // Debugging: Print the decoded token
        bool isTokenExpired = JwtDecoder.isExpired(token);
        print('Is token expired? $isTokenExpired');

        Map<String, dynamic> payload = decodedToken['payload'];

        // Create a User instance from the decoded token
        user.value = User(
            username: payload['userName'], // Correct case
            email: payload['email'], // Correct case
            userProfilePicture: UserProfilePicture(
              resourceID: payload['userProfilePicture']
                  ['resourceID'], // Lowercase 'u'
              entityName: payload['userProfilePicture']
                  ['entityName'], // Lowercase 'u'
              filePath: payload['userProfilePicture']
                  ['filePath'], // Lowercase 'u'
              fileType: payload['userProfilePicture']
                  ['fileType'], // Lowercase 'u'
            ));

        // Navigate to home page since the token is valid
        Get.offNamed('/home');
      } else {
        // Token is expired, navigate to login
        await secureStorage.delete(key: 'jwt_token'); // Remove expired token
        Get.offNamed('/login'); // Go to sign-in page
      }
    } else {
      // No token found, navigate to login page
      Get.offNamed('/login');
    }
  }

  void goToSignup() {
    Get.offNamed('/signup');
  }

  // Login API call logic
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill out all fields.';
      Get.snackbar('Error', 'Please fill out all fields.');
      return;
    }

    try {
      var url = Uri.parse('${Strings().apiUrl}/login');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      
      if (response.statusCode == 200) {
        String jwtToken = response.body;

        // Decode the JWT token to get the payload
        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
        Map<String, dynamic> payload = decodedToken['payload'];

        // Create a User instance from the decoded token
        user.value = User(
          username: payload['userName'],
          email: payload['email'],
          userProfilePicture: UserProfilePicture(
            resourceID: payload['userProfilePicture']['resourceID'],
            entityName: payload['userProfilePicture']['entityName'],
            filePath: payload['userProfilePicture']['filePath'],
            fileType: payload['userProfilePicture']['fileType'],
          ),
        );

        await secureStorage.write(key: 'jwt_token', value: jwtToken);
        await secureStorage.write(key: 'user_data', value: jsonEncode(user.value));

        Get.offNamed('/home');
      } else {
        errorMessage.value = 'Login failed. Please check your credentials.';
        Get.snackbar('Login Failed', 'Please check your credentials.');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar('Error', 'An error occurred. Please try again later: $e');
    }
  }

  // Function to log out the user by deleting the stored token
  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    user.value = null;
    Get.offNamed('/login');
  }
}
