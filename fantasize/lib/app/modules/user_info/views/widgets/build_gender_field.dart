import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_info_controller.dart';

class BuildGenderField extends StatelessWidget {
  final UserInfoController controller = Get.find<UserInfoController>();

  BuildGenderField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4C5E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFFF4C5E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.Gender.value.isEmpty ? null : controller.Gender.value.toLowerCase(),
                hint: const Text('Select gender'),
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.Gender.value = newValue;
                    controller.genderController.text = newValue;
                  }
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
                elevation: 2,
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }
}