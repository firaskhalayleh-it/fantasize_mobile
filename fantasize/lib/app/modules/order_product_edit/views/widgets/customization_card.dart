// lib/app/modules/order_product_edit/views/widgets/customization_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'shared_widgets.dart';

class CustomizationCard extends StatelessWidget {
  final OrderProductEditController controller;

  const CustomizationCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20, color: Colors.redAccent),
                const SizedBox(width: 8),
                const Text(
                  'Customizations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                InfoButton(
                  onTap: () => _showCustomizationInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.orderedCustomizations.isEmpty) {
                return const ErrorState(
                  message: 'No customization options available',
                  icon: Icons.brush_outlined,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.orderedCustomizations.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final customization = controller.orderedCustomizations[index];
                  return _CustomizationSection(
                    customization: customization,
                    controller: controller,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCustomizationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customization Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'Customize your order with various options like size, color, or special instructions. '
            'Each customization may affect the final price of your order.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _CustomizationSection extends StatelessWidget {
  final OrderedCustomization customization;
  final OrderProductEditController controller;

  const _CustomizationSection({
    Key? key,
    required this.customization,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: customization.selectedOptions.map((option) {
        switch (option.type.toLowerCase()) {
          case 'button':
            return _ButtonOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          case 'color':
            return _ColorOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          case 'attachmessage':
            return _MessageOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          case 'uploadpicture':
            return _ImageUploadOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          default:
            return const SizedBox();
        }
      }).toList(),
    );
  }
}

class _ButtonOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _ButtonOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: option.optionValues.map((value) {
            return Obx(() => ChoiceChip(
                  label: Text(value.value),
                  selected: value.isSelected.value,
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    controller.updateSelectedOption(
                      customizationId,
                      option.name,
                      value.value,
                    );
                  },
                  selectedColor: Colors.redAccent.withOpacity(0.2),
                ));
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _ColorOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: option.optionValues.map((value) {
            return Obx(() {
              final isSelected = value.isSelected.value;
              final color = _parseColor(value.value);
              
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.updateSelectedOption(
                        customizationId,
                        option.name,
                        value.value,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.redAccent : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: isSelected
                            ? Center(
                                child: Icon(
                                  Icons.check,
                                  color: _shouldUseWhiteText(color) 
                                      ? Colors.white 
                                      : Colors.black,
                                  size: 24,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedValue = option.optionValues
              .firstWhereOrNull((opt) => opt.isSelected.value)
              ?.value;
          if (selectedValue != null) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Selected: ${selectedValue.toUpperCase()}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.trim().toUpperCase();
      if (hexColor.startsWith('0X')) {
        hexColor = hexColor.substring(2);
      } else if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }

      if (!RegExp(r'^[A-F0-9]{6}([A-F0-9]{2})?$').hasMatch(hexColor)) {
        throw FormatException('Invalid color format');
      }

      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      debugPrint('Error parsing color: $colorString - ${e.toString()}');
      return Colors.grey[300]!;
    }
  }

  bool _shouldUseWhiteText(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;
  }
}

class _MessageOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _MessageOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = controller.getTextController(
      customizationId,
      option.name,
    );
    final isVisible = controller.getAttachMessageVisibility(
      customizationId,
      option.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            option.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Obx(() => Icon(
              isVisible.value ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            )),
            onPressed: () => controller.toggleAttachMessageVisibility(
              customizationId,
              option.name,
            ),
          ),
        ),
        Obx(() {
          if (!isVisible.value) return const SizedBox();
          return TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter your message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 3,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ImageUploadOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _ImageUploadOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = controller.getUploadedImagePath(
      customizationId,
      option.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (imagePath.value.isEmpty) {
              return Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, 
                    size: 48, 
                    color: Colors.grey[400]
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload an image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath.value),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Change'),
                      onPressed: () => _pickImage(controller, customizationId, option.name),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Remove'),
                      onPressed: () {
                        controller.updateUploadedImage(
                          customizationId,
                          option.name,
                          '',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[200]!),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _pickImage(
    OrderProductEditController controller,
    int customizationId,
    String optionName,
  ) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        final mimeType = lookupMimeType(image.path);
        if (mimeType != null &&
            (mimeType == 'image/jpeg' ||
             mimeType == 'image/jpg' ||
             mimeType == 'image/png')) {
          controller.updateUploadedImage(
            customizationId,
            optionName,
            image.path,
          );
        } else {
          Get.snackbar(
            'Error',
            'Please select a JPEG or PNG image',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            margin: const EdgeInsets.all(8),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(8),
      );
    }
  }
}