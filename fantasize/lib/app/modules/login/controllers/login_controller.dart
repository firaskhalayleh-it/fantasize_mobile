import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/user_model.dart' as userModel;
import 'package:fantasize/app/global/strings.dart';

class LoginController extends GetxController {
  var loginFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var forgotPassword = false.obs;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var errorMessage = ''.obs;

  var obscureText = true.obs;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var user = Rxn<userModel.User>();
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

        userModel.UserProfilePicture? userProfilePicture;

        if (payload['userProfilePicture'] != null) {
          var profilePicData = payload['userProfilePicture'];

          userProfilePicture = userModel.UserProfilePicture(
            resourceID: profilePicData['resourceID'],
            entityName: profilePicData['entityName'],
            filePath: profilePicData['filePath'],
            fileType: profilePicData['fileType'],
          );
        }

        user.value = userModel.User(
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

  Future<void> loginWithFacebook() async {
    try {
      // Initialize Facebook Login
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Obtain the access token
        final AccessToken accessToken = result.accessToken!;
        final userData = await FacebookAuth.instance.getUserData();

        final String email = userData['email'] ?? '';
        final String name = userData['name'] ?? '';
        final String facebookId = userData['id'] ?? '';
        final String? photoUrl = userData['picture']?['data']?['url'];

        // Retrieve DeviceToken from secure storage
        deviceToken = await secureStorage.read(key: 'DeviceToken');
        if (deviceToken == null) {
          Get.snackbar('Error', 'Device Token not found.');
          return;
        }

        // Prepare the request
        final uri = Uri.parse("${Strings().apiUrl}/login_with_facebook");
        final request = http.MultipartRequest("POST", uri)
          ..fields['email'] = email
          ..fields['facebookId'] = facebookId
          ..fields['DeviceToken'] = deviceToken ?? ''
          ..fields['name'] = name;

        // Attach profile picture if available
        if (photoUrl != null) {
          final photoResponse = await http.get(Uri.parse(photoUrl));
          if (photoResponse.statusCode == 200) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              photoResponse.bodyBytes,
              filename: 'profile_picture.png',
            ));
          }
        }

        // Send the request
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final jwtToken =
              responseBody; // Assuming the API response is the JWT token

          // Decode the JWT token to extract the payload
          Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
          Map<String, dynamic> payload = decodedToken['payload'];

          // Initialize userProfilePicture as null
          userModel.UserProfilePicture? userProfilePicture;

          // Check if userProfilePicture exists in the payload
          if (payload['userProfilePicture'] != null) {
            var profilePicData = payload['userProfilePicture'];

            // Create a UserProfilePicture instance
            userProfilePicture = userModel.UserProfilePicture(
              resourceID: profilePicData['resourceID'],
              entityName: profilePicData['entityName'],
              filePath: profilePicData['filePath'],
              fileType: profilePicData['fileType'],
            );
          }

          // Create a User instance from the decoded token
          user.value = userModel.User(
            username: payload['userName'],
            email: payload['email'],
            userProfilePicture: userProfilePicture,
            deviceToken: deviceToken ?? '',
          );

          // Save JWT token and user data to secure storage
          await secureStorage.write(key: 'jwt_token', value: jwtToken);
          await secureStorage.write(
              key: 'user_data', value: jsonEncode(user.value));

          // Navigate to the home page
          print('Going to home');
          Get.offNamed('/home');
        } else {
          // Handle non-200 responses
          errorMessage.value = 'Login failed. Please try again.';
          Get.snackbar('Login Failed',
              'Server responded with status: ${response.statusCode}');
        }
      } else {
        Get.snackbar('Error', 'Facebook login failed: ${result.message}');
      }
    } catch (e) {
      // Handle any other errors
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar('Error', 'An error occurred: $e');
      print('Error: $e');
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      // Ensure no existing Google user is signed in
      await _googleSignIn.signOut();

      // Start Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        print("Google sign-in was canceled by the user.");
        return;
      }

      // Show loading dialog
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Obtain Google Auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Fetch user data
        final String email = firebaseUser.email ?? '';
        final String name = firebaseUser.displayName ?? '';
        final String googleId = firebaseUser.uid;
        final String? photoUrl = firebaseUser.photoURL;

        print(
            "User Data: Email: $email, Name: $name, Google ID: $googleId, Photo URL: $photoUrl");

        // Retrieve DeviceToken from secure storage
        deviceToken = await secureStorage.read(key: 'DeviceToken');
        if (deviceToken == null) {
          Get.back(); // Close dialog
          Get.snackbar('Error', 'Device Token not found.');
          return;
        }

        // Prepare the request
        final uri = Uri.parse("${Strings().apiUrl}/login_with_google");
        final request = http.MultipartRequest("POST", uri)
          ..fields['email'] = email
          ..fields['googleId'] = googleId
          ..fields['DeviceToken'] = deviceToken ?? ''
          ..fields['name'] = name;

        // Attach profile picture if available
        if (photoUrl != null && photoUrl.isNotEmpty) {
          print("Downloading user photo from: $photoUrl");

          try {
            // Fetch the image
            final photoResponse = await http.get(Uri.parse(photoUrl));
            if (photoResponse.statusCode == 200) {
              // Generate a unique filename using the Google ID or another unique identifier
              final tempDir = await getTemporaryDirectory();
              final uniqueFileName = '$googleId-profile-picture.jpg';
              final filePath = '${tempDir.path}/$uniqueFileName';
              final file = File(filePath);

              // Save the image locally
              await file.writeAsBytes(photoResponse.bodyBytes);

              print("Photo downloaded and saved to: $filePath");

              // Add the file to the request with MIME type
              final mimeType = 'image/jpeg'; // Set based on file type
              request.files.add(await http.MultipartFile.fromPath(
                'file',
                filePath,
                filename: uniqueFileName,
                contentType: DioMediaType.parse(mimeType),
              ));
            } else {
              print(
                  "Failed to download photo. Status code: ${photoResponse.statusCode}");
            }
          } catch (error) {
            print("Error downloading photo: $error");
          }
        } else {
          print("No photo URL available for the user.");
        }

        // Send the request
        final response = await request.send();
        Get.back(); // Close dialog

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final jwtToken =
              responseBody; // Assuming the API response is the JWT token

          // Decode the JWT token to extract the payload
          Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
          Map<String, dynamic> payload = decodedToken['payload'];

          // Initialize userProfilePicture as null
          userModel.UserProfilePicture? userProfilePicture;

          // Check if userProfilePicture exists in the payload
          if (payload['userProfilePicture'] != null) {
            var profilePicData = payload['userProfilePicture'];

            // Create a UserProfilePicture instance
            userProfilePicture = userModel.UserProfilePicture(
              resourceID: profilePicData['resourceID'],
              entityName: profilePicData['entityName'],
              filePath: profilePicData['filePath'],
              fileType: profilePicData['fileType'],
            );
          }

          print('userProfilePicture: $userProfilePicture');

          // Update the user model in GetX state
          user.value = userModel.User(
            username: payload['userName'],
            email: payload['email'],
            userProfilePicture: userProfilePicture,
            deviceToken: deviceToken ?? '',
          );

          // Save JWT token and user data to secure storage
          await secureStorage.write(key: 'jwt_token', value: jwtToken);
          await secureStorage.write(
              key: 'user_data', value: jsonEncode(user.value));

          // Navigate to the home page
          Get.toNamed('/home');
          Get.snackbar('Login Successful', 'You have logged in successfully.');
        } else {
          // Handle non-200 responses
          print("Server responded with status: ${response.statusCode}");
          Get.snackbar('Login Failed',
              'Server responded with status: ${response.statusCode}');
        }
      } else {
        print("Firebase user is null.");
      }
    } catch (e) {
      // Handle any other errors
      Get.back(); // Close dialog
      print("Error during login with Google: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  // Login API call logic
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Retrieve DeviceToken from secure storage using await
    var deviceToken = await secureStorage.read(key: 'DeviceToken');
    print('Device Token from secureStorage: $deviceToken');

    if (email.isEmpty || password.isEmpty) {
      loginFormKey.currentState!.validate();
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
        userModel.UserProfilePicture? userProfilePicture;

        // Check if userProfilePicture exists in the payload
        if (payload['userProfilePicture'] != null) {
          var profilePicData = payload['userProfilePicture'];

          // Create a UserProfilePicture instance
          userProfilePicture = userModel.UserProfilePicture(
            resourceID: profilePicData['resourceID'],
            entityName: profilePicData['entityName'],
            filePath: profilePicData['filePath'],
            fileType: profilePicData['fileType'],
          );
        }

        // Create a User instance from the decoded token
        user.value = userModel.User(
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
        if (response.statusCode == 401) {
          forgotPassword.value = true;
          Get.snackbar('Login Failed1', response.body);
        }
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      Get.snackbar('Error', 'An error occurred. Please try again later: $e');
    }
  }

  void goToResetPassword() {
    Get.toNamed('/reset-password');
  }
}
