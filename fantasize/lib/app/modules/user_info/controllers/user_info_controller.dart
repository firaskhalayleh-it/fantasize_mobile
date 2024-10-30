import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserInfoController extends GetxController {
  RxBool isEditingUserName = false.obs;
  RxBool isEditingEmail = false.obs;
  RxBool isEditingPhone = false.obs;
  RxBool isEditingGender = false.obs;

  RxString dateOfBirth = ''.obs;
  RxString Gender = ''.obs;

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();

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

  void changeDateOfBirth(String newDate) {
    dateOfBirth.value = newDate;
  }

  void setDateOfBirth(String newDate) {
    dateOfBirth.value = newDate;
  }

  void toggleEditingGender (){
    isEditingGender.value = !isEditingGender.value;
  }

  void changeGender(String newGender) {
    if (newGender.isEmpty) {
      Get.snackbar('error', 'must be male or female');
      return;
    }
    Gender.value = newGender;
  }
}
