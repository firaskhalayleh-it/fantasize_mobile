import 'dart:convert';
import 'dart:io';
import 'package:fantasize/app/modules/profile/controllers/profile_controller.dart';
import 'package:http/http.dart' as http;

import 'package:fantasize/app/data/models/user_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class UserInfoController extends GetxController {
  RxBool isEditingUserName = false.obs;
  RxBool isEditingEmail = false.obs;
  RxBool isEditingPhone = false.obs;
  RxBool isEditingGender = false.obs;

  Rxn<User> user = Rxn<User>();

  RxString username = ''.obs;
  RxString email = ''.obs;
  RxString phoneNumber = ''.obs;
  RxString Gender = ''.obs;
  RxString dateOfBirth = ''.obs;

  ProfileController profileController = Get.find<ProfileController>();

  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  @override
  void onInit() {
    //takes paramets from map <string,dynamic>
    var parameters = Get.parameters;
    if (parameters.isEmpty) {
      Get.snackbar('error', 'no user data found');
    }
    var userUsername = parameters['username'];
    var userEmail = parameters['email'];
    var userPhone = parameters['phonenumber'];
    var userGender = parameters['gender'];
    var userDateOfBirth = parameters['DOB'];

    userNameController.text = userUsername.toString();
    emailController.text = userEmail.toString();
    phoneController.text = userPhone?.toString() ?? '';
    genderController.text = userGender.toString();
    dateOfBirthController.text = userDateOfBirth.toString();
    dateOfBirth.value = userDateOfBirth.toString();

    print('user Date of Birth: $userDateOfBirth');

    super.onInit();
  }

  void toggleEditingUserName() {
    isEditingUserName.value = !isEditingUserName.value;
  }

  void toggleEditingEmail() {
    isEditingEmail.value = !isEditingEmail.value;
  }

  void toggleEditingPhone() {
    isEditingPhone.value = !isEditingPhone.value;
  }

  void toggleEditingGender() {
    isEditingGender.value = !isEditingGender.value;
  }

  void changeGender(String newGender) {
    if (newGender.isEmpty) {
      Get.snackbar('error', 'must be male or female');
      return;
    }
    Gender.value = newGender;
  }

  Future<void> updateUserProfile() async {
    username.value = userNameController.text;
    email.value = emailController.text;
    phoneNumber.value = phoneController.text;
    Gender.value = genderController.text;
    dateOfBirth.value = dateOfBirthController.text;
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

    print('Username: ${username.value}');
    print('Email: ${email.value}');
    print('Phone Number: ${phoneNumber.value}');
    print('dateOfBirth: ${dateOfBirth.value}');
    print('gender:${Gender.value}');
    request.fields['Username'] = username.value;
    request.fields['Email'] = email.value;
    request.fields['PhoneNumber'] = phoneNumber.value;
    request.fields['dateOfBirth'] = dateOfBirth.value;
    request.fields['Gender'] = Gender.value;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print(response.statusCode);
    print(responseBody);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseBody);
      HomeController homeController = Get.find<HomeController>();
      homeController.user.value = User.fromJson(jsonResponse['user']);

      profileController.fetchUserData();
      if (jsonResponse['user'] != null) {
        user.value = User.fromJson(jsonResponse['user']);
        user.refresh();

        if (username != null && username.isNotEmpty) {
          await secureStorage.write(key: 'username', value: username.value);
        }

        await secureStorage.write(
            key: 'user_data', value: json.encode(jsonResponse['user']));
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } else {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }
}
