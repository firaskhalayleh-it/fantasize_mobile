import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/models/user_model.dart';
import 'package:fantasize/app/global/strings.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var errorMessage = ''.obs;
  var obscureText = true.obs;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var user = Rxn<User>();
  String? deviceToken;

  @override
  void onInit() {
    super.onInit();

    checkForToken(); // Moved after setting deviceToken
  }

  // Function to toggle the visibility of the password field
  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  // Method to check for stored JWT token and navigate accordingly
  Future<void> checkForToken() async {
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token != null) {
      bool isTokenExpired = JwtDecoder.isExpired(token);

      if (!isTokenExpired) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        Map<String, dynamic> payload = decodedToken['payload'];

        print('Decoded Token: $decodedToken');
        print('Is token expired? $isTokenExpired');

        UserProfilePicture? userProfilePicture;

        if (payload['userProfilePicture'] != null) {
          var profilePicData = payload['userProfilePicture'];

          userProfilePicture = UserProfilePicture(
            resourceID: profilePicData['resourceID'],
            entityName: profilePicData['entityName'],
            filePath: profilePicData['filePath'],
            fileType: profilePicData['fileType'],
          );
        }

        user.value = User(
          username: payload['userName'],
          email: payload['email'],
          userProfilePicture: userProfilePicture,
          deviceToken: deviceToken ?? '',
        );

        await secureStorage.write(
          key: 'user_data',
          value: jsonEncode(user.value),
        );
        print('going to home');
        Get.offNamed('/home');
      } else {
        await secureStorage.deleteAll();
        Get.deleteAll();
        Get.offNamed('/login');
      }
    } else {
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

    // Retrieve DeviceToken from secure storage using await
    var deviceToken = await secureStorage.read(key: 'DeviceToken');
    print('Device Token from secureStorage: $deviceToken');

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill out all fields.';
      Get.snackbar('Error', 'Please fill out all fields.');
      return;
    }
    if (deviceToken == null) {
      errorMessage.value = 'Device Token not found.';
      Get.snackbar('Error', 'Device Token not found.');
      return;
    }

    try {
      var url = Uri.parse('${Strings().apiUrl}/login');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'DeviceToken': deviceToken,
          }));

      if (response.statusCode == 200) {
        String jwtToken = response.body;

        // Decode the JWT token to get the payload
        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
        Map<String, dynamic> payload = decodedToken['payload'];

        // Initialize userProfilePicture as null
        UserProfilePicture? userProfilePicture;

        // Check if userProfilePicture exists in the payload
        if (payload['userProfilePicture'] != null) {
          var profilePicData = payload['userProfilePicture'];

          // Create a UserProfilePicture instance
          userProfilePicture = UserProfilePicture(
            resourceID: profilePicData['resourceID'],
            entityName: profilePicData['entityName'],
            filePath: profilePicData['filePath'],
            fileType: profilePicData['fileType'],
          );
        }

        // Create a User instance from the decoded token
        user.value = User(
          username: payload['userName'],
          email: payload['email'],
          userProfilePicture: userProfilePicture,
        );

        await secureStorage.write(key: 'jwt_token', value: jwtToken);
        await secureStorage.write(
            key: 'user_data', value: jsonEncode(user.value));
        print('going to home');
        Get.offNamed('/home');
      } else {
        errorMessage.value = 'Login failed. Please check your credentials.';
        Get.snackbar('Login Failed', '${response.body}');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar('Error', 'An error occurred. Please try again later: $e');
    }
  }
}
