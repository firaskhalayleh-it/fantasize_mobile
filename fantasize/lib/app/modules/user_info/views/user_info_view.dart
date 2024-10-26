import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/user_info_controller.dart';
import '../views/widgets/build_info_field.dart' show BuildInfoField;

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        title: Center(
          child: Image.asset(
            'assets/icons/fantasize.png',
            height: 40,
          ),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4C5E),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => BuildInfoField().buildinfofield(
                  label: 'User Name',
                  controller: controller.userNameController,
                  isEditing: controller.isEditingUserName.value,
                  onEditPressed: controller.toggleEditingUserName,
                )),
            const SizedBox(height: 16),
            Obx(() => BuildInfoField().buildinfofield(
                  label: 'Email Address',
                  controller: controller.emailController,
                  isEditing: controller.isEditingEmail.value,
                  onEditPressed: controller.toggleEditingEmail,
                )),
            const SizedBox(height: 16),
            Obx(() => BuildInfoField().buildinfofield(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  isEditing: controller.isEditingPhone.value,
                  onEditPressed: controller.toggleEditingPhone,
                )),
            const SizedBox(height: 16),
            Obx(() => BuildInfoField().buildDateField(context)),
          ],
        ),
      ),
    );
  }
}
