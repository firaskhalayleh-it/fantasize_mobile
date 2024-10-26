import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserInfoController extends GetxController {
 RxBool isEditingUserName = false.obs;
  RxBool isEditingEmail = false.obs;
  RxBool isEditingPhone = false.obs;
  RxString dateOfBirth = ''.obs;


  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();






  @override
  void onInit() {
    super.onInit();
  }

  void toggleEditingUserName() {
    isEditingUserName.value = !isEditingUserName.value;
    update();
  }

  void toggleEditingEmail() {
    isEditingEmail.value = !isEditingEmail.value;
    update();
  }

  void toggleEditingPhone() {
    isEditingPhone.value = !isEditingPhone.value;
    update();
  }

  void changeDateOfBirth(String newDate) {
    dateOfBirth.value = newDate;
    update();
  }

  void setDateOfBirth(String newDate) {
    dateOfBirth.value = newDate;
    update();
  }


}
