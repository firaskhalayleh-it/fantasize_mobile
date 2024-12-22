import 'package:fantasize/app/modules/user_info/views/widgets/build_gender_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/user_info_controller.dart';
import 'widgets/build_date_field.dart';
import 'widgets/build_info_field.dart';

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
      ),
      title: Image.asset(
        'assets/icons/fantasize.png',
        height: 40,
      ),
      centerTitle: true,
      actions: const [SizedBox(width: 48)],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4C5E),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            BuildInfoField(
              label: 'Username',
              textController: controller.userNameController,
              isEditing: controller.isEditingUserName,
              onEditPressed: controller.toggleEditingUserName,
              inputType: TextInputType.name,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            BuildInfoField(
              label: 'Email Address',
              textController: controller.emailController,
              isEditing: controller.isEditingEmail,
              onEditPressed: controller.toggleEditingEmail,
              inputType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            BuildInfoField(
              label: 'Phone Number',
              textController: controller.phoneController,
              isEditing: controller.isEditingPhone,
              onEditPressed: controller.toggleEditingPhone,
              inputType: TextInputType.phone,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 20),
            BuildGenderField(),
            const SizedBox(height: 20),
            BuildDateField(
              onDateSelected: () => _showDatePicker(context),
            ),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime(2003, 4, 27),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        controller.dateOfBirthController.text =
            DateFormat('dd/MM/yyyy').format(selectedDate).toString();
      }
    });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.updateUserProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4C5E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
