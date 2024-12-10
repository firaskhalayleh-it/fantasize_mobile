import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildInfoField extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final RxBool isEditing;
  final VoidCallback onEditPressed;
  final TextInputType inputType;
  final IconData icon;

  const BuildInfoField({
    Key? key,
    required this.label,
    required this.textController,
    required this.isEditing,
    required this.onEditPressed,
    required this.inputType,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
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
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF4C5E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textController,
                  enabled: isEditing.value,
                  keyboardType: inputType,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF4C5E)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isEditing.value
                            ? const Color(0xFFFF4C5E).withOpacity(0.1)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEditing.value ? Icons.check : Icons.edit,
                        size: 20,
                        color: isEditing.value
                            ? const Color(0xFFFF4C5E)
                            : Colors.grey[600],
                      ),
                    ),
                    onPressed: onEditPressed,
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}