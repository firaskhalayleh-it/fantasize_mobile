import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_info_controller.dart';

class BuildDateField extends StatelessWidget {
  final UserInfoController controller = Get.find<UserInfoController>();
  final VoidCallback onDateSelected;

  BuildDateField({
    Key? key,
    required this.onDateSelected,
  }) : super(key: key);

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
                  Icons.calendar_today,
                  color: Color(0xFFFF4C5E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Date Of Birth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onDateSelected,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.dateOfBirth.value.isEmpty
                          ? 'Select date'
                          : controller.dateOfBirth.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.dateOfBirth.value.isEmpty
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
