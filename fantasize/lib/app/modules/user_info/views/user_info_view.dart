import 'package:fantasize/app/modules/user_info/views/widgets/build_date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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
        leading: IconButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(const EdgeInsets.all(0)),
            elevation: WidgetStatePropertyAll(2),
            shadowColor: WidgetStatePropertyAll(Colors.black),
          ),
          icon: Image(
            image: Svg('assets/icons/back_button.svg'),
            fit: BoxFit.fill,
          ),
          onPressed: () {
            Get.back();
          },
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
        child: SingleChildScrollView(
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
              BuildInfoField(
                label: 'Username',
                textController: controller.userNameController,
                isEditing: controller.isEditingUserName,
                onEditPressed: controller.toggleEditingUserName,
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              BuildInfoField(
                label: 'Email Address',
                textController: controller.emailController,
                isEditing: controller.isEditingEmail,
                onEditPressed: controller.toggleEditingEmail,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              BuildInfoField(
                label: 'Phone Number',
                textController: controller.phoneController,
                isEditing: controller.isEditingPhone,
                onEditPressed: controller.toggleEditingPhone,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              BuildInfoField(
                label: 'Gender',
                textController: controller.genderController,
                isEditing: controller.isEditingGender,
                onEditPressed: controller.toggleEditingGender,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              BuildDateField(

                
                onDateSelected: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime(2003, 4, 27),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      controller.dateOfBirthController.text =
                          DateFormat('dd/MM/yyyy')
                              .format(selectedDate)
                              .toString();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateUserProfile();
                  },
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xFFFF4C5E)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontFamily: 'Jost', color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
