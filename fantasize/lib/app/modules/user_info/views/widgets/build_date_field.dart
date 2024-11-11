import 'package:fantasize/app/modules/user_info/controllers/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildDateField extends StatelessWidget {
  final UserInfoController controller = Get.find<UserInfoController>();
  final VoidCallback onDateSelected;

  BuildDateField({
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Of Birth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      TextEditingController(text: controller.dateOfBirth.value),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: onDateSelected,
              ),
            ],
          ),
        ],
      );
    });
  }
}
