import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildInfoField extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final RxBool isEditing;
  final VoidCallback onEditPressed;
  final TextInputType inputType;

  const BuildInfoField({
    Key? key,
    required this.label,
    required this.textController,
    required this.isEditing,
    required this.onEditPressed,
    required this.inputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    enabled: isEditing.value,
                    keyboardType: inputType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isEditing.value ? Icons.check : Icons.edit),
                  onPressed: onEditPressed,
                ),
              ],
            ),
          ],
        ));
  }
}
