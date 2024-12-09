import 'dart:io';

import 'package:fantasize/app/global/widgets/general_input.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/models/user_model.dart';
import '../../../global/strings.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ProfileController extends GetxController {
  var user = Rxn<User>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();
  var newpassword = ''.obs;

  var confirmpassword = ''.obs;

  var isObscureNewPassword = true.obs;
  var isObscureConfirmPassword = true.obs;

  var isLoading = true.obs;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  File? selectedFile;
  var isEditing = false.obs;
  final allowedExtensions = ['jpg', 'jpeg', 'png', 'mp4'];
  Future<void> fetchUserData() async {
    try {
      isLoading(true);

      String? token = await secureStorage.read(key: 'jwt_token');

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['payload']['userId'];

        var cookieHeader = 'authToken=$token'; // Cookie header

        // Fetch user data from the API
        final response = await http.get(
          Uri.parse('${Strings().apiUrl}/get_user_detail/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
            'Cookie': cookieHeader,
          },
        );

        if (response.statusCode == 200) {
          // Decode response body to JSON
          var jsonData = json.decode(response.body);

          // Ensure jsonData is a Map (not a String)
          if (jsonData is Map<String, dynamic>) {
            print("JSON Data fetched: $jsonData");

            // Parse the JSON data into User object
            var fetchedUser = User.fromJson(jsonData);
            user.value = fetchedUser;
            print("User payment methods: ${user.value?.paymentMethods}");
          } else {
            print("Error: Expected a JSON object but received: $jsonData");
            Get.snackbar('Error', 'Unexpected data format');
          }
        } else {
          Get.snackbar('Error', 'Failed to load user data');
        }
      } else {
        Get.snackbar('Error', 'No token found. Please login again.');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print("Exception caught: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateUserProfile({String? password, File? file}) async {
    final url = Uri.parse('${Strings().apiUrl}/update_user');
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token == null) {
      Get.snackbar('Error', 'No token found. Please login again.');
      return;
    }

    var request = http.MultipartRequest('PUT', url);
    request.headers['accept'] = '*/*';
    request.headers['cookie'] = 'authToken=$token';

    // Add fields to the request
    if (password != null && password.isNotEmpty) {
      request.fields['Password'] = password;
    } else {
      request.fields['Password'] =
          ''; // Add an empty field if no password is provided
    }

    // Add file if available
    if (file != null) {
      String fileExtension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar('Error', 'File type not supported.');
        return;
      }

      String? mimeType =
          lookupMimeType(file.path) ?? 'application/octet-stream';
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Ensure this matches the server's expected field name for the file
        file.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    // Send the request
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseBody);
      print('Response: $jsonResponse');

      HomeController homeController = Get.find<HomeController>();
      homeController.user.value = User.fromJson(jsonResponse['user']);

      user.value = User.fromJson(jsonResponse['user']);
      user.refresh();

      Get.snackbar('Success', 'Profile updated successfully');
    } else {
      Get.snackbar('Error', 'Failed to update profile');
      print('Failed to update profile: ${response.statusCode}');
      print('Response: $responseBody');
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedFile = File(pickedFile.path);
      updateUserProfile(file: selectedFile);
    }
  }

  NavigateToUserInfo() {
    print(
        'sended data:${user.value!.gender},${user.value!.username},${user.value!.phoneNumber},${user.value!.dateOfBirth},${user.value!.email}');

    Get.toNamed('/user-info', parameters: {
      'gender': user.value?.gender?.toString() ?? '',
      'username': user.value?.username?.toString() ?? '',
      'phonenumber': user.value?.phoneNumber?.toString() ?? '',
      'DOB': user.value?.dateOfBirth?.toString() ?? '',
      'email': user.value?.email.toString() ?? ''
    });
  }

  NavigateToPaymentMethod() {
    Get.toNamed('/payment-method');
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  void showResetPasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(() => GeneralInput(
                      key: const ValueKey('newpassword'),
                      label: 'New Password',
                      controller: newpasswordController,
                      obscureText: isObscureNewPassword.value,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      postfixIcon: IconButton(
                        icon: Icon(
                          isObscureNewPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          isObscureNewPassword.value =
                              !isObscureNewPassword.value;
                        },
                      ),
                    )),
                const SizedBox(height: 16),
                Obx(() => GeneralInput(
                      key: const ValueKey('confirmpassword'),
                      label: 'Confirm Password',
                      controller: confirmpasswordController,
                      obscureText: isObscureConfirmPassword.value,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != newpasswordController.text) {
                          return 'Passwords do not match';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      postfixIcon: IconButton(
                        icon: Icon(
                          isObscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          isObscureConfirmPassword.value =
                              !isObscureConfirmPassword.value;
                        },
                      ),
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        title: 'Cancel',
                        onPressed: () => Get.back(),
                        backgroundColor: Colors.grey[100]!,
                        textColor: Colors.grey[800]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        title: 'Reset Password',
                        onPressed: () {
                          if ((formKey.currentState as FormState).validate()) {
                            newpassword.value = newpasswordController.text;
                            confirmpassword.value =
                                confirmpasswordController.text;
                            updateUserProfile(password: newpassword.value);
                            Get.back();
                          }
                        },
                        backgroundColor: const Color(0xFFFF4C5E),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      // Retrieve all keys from secure storage
      List<String> allKeys =
          await secureStorage.readAll().then((map) => map.keys.toList());

      // Define the keys you want to retain
      List<String> keysToKeep = ['DeviceToken'];

      // Filter out the keys to delete
      List<String> keysToDelete =
          allKeys.where((key) => !keysToKeep.contains(key)).toList();

      // Delete the unwanted keys
      for (String key in keysToDelete) {
        await secureStorage.delete(key: key);
        print('Deleted key: $key');
      }

      Get.offAllNamed('/login');
    } catch (e) {
      print('Error deleting keys except DeviceToken: $e');
    }
  }

  Widget getCardIcon(String? CardNumber) {
    if (CardNumber != null) {
      if (CardNumber.startsWith('4')) {
        return Image.asset(
          'assets/images/visa.png',
          height: 40,
        );
      } else if (CardNumber.startsWith('5')) {
        return Image.asset(
          'assets/images/mastercard.png',
          height: 40,
        );
      }
    }
    return Icon(Icons.credit_card);
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void navigateToPaymentMethod() {
    Get.toNamed('/payment-method');
  }

  void navigateToUserInfo() {
    Get.toNamed('/user-info');
  }
}
