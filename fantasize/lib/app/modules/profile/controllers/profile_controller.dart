import 'dart:io';

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

        var cookieHeader =
            'authToken=$token'; // Name of the cookie as 'authToken'

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
          var jsonData = json.decode(response.body);
          print(response.body);

          var fetchedUser = User.fromJson(jsonData);

          user.value = fetchedUser;
          print(user.value!.paymentMethods);
        } else {
          Get.snackbar('Error', 'Failed to load user data');
        }
      } else {
        Get.snackbar('Error', 'No token found. Please login again.');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateUserProfile({String? username, File? file}) async {
    final url = Uri.parse('${Strings().apiUrl}/update_user');
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token == null) {
      Get.snackbar('Error', 'No token found. Please login again.');
      return;
    }

    var request = http.MultipartRequest('PUT', url);
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['accept'] = '*/*';
    request.headers['cookie'] = 'authToken=$token';

    if (file != null) {
      String fileExtension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar('Error', 'File type not supported.');
        return;
      }

      String? mimeType =
          lookupMimeType(file.path) ?? 'application/octet-stream';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType), // Set MIME type here
      ));
    }

    request.fields['Username'] = username ?? user.value?.username ?? '';

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseBody);
      //update home controller user value
      HomeController homeController = Get.find<HomeController>();
      homeController.user.value = User.fromJson(jsonResponse['user']);

      if (jsonResponse['user'] != null) {
        user.value = User.fromJson(jsonResponse['user']);
        user.refresh();

        // Check if the username was updated
        if (username != null && username.isNotEmpty) {
          await secureStorage.write(key: 'username', value: username);
        }

        // Check if the profile picture was updated
        if (file != null) {
          await secureStorage.write(key: 'profile_picture', value: file.path);
        }

        await secureStorage.write(
            key: 'user_data', value: json.encode(jsonResponse['user']));
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } else {
      Get.snackbar('Error', 'Failed to update profile');
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

  void updateUsername() {
    String newUsername = usernameController.text = user.value!.username;
    if (newUsername.isEmpty) {
      Get.snackbar('Error', 'Username cannot be empty');
      return;
    }
    user.value!.username = newUsername;
    updateUserProfile(username: newUsername);
  }

  NavigateToUserInfo() {
    Get.toNamed('/user-info', parameters: {
      'gender': user.value?.gender?.toString() ?? '',
      'username': user.value?.username?.toString() ?? '',
      'phonenumber': user.value?.phoneNumber?.toString() ?? '',
      'DOB': user.value?.dateOfBirth?.toString() ?? '',
      'email': user.value?.email?.toString() ?? ''
    });
    
  }

  NavigateToPaymentMethod() {
    Get.toNamed('/payment-method');
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  showResetPasswordDialog() {
    Get.defaultDialog(
      title: 'Reset Password',
      content: Column(
        children: [
          Text('Enter your email address to reset your password'),
          TextField(
            decoration: InputDecoration(hintText: 'Email'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.snackbar('Success', 'Password reset email sent');
          },
          child: Text('Reset Password'),
        ),
      ],
    );
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'user_data');
    user.value = null;
    Get.offAllNamed('/login');
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
}
