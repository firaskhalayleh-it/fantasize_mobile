// lib/app/modules/order_product_edit/views/widgets/customization_widget.dart

import 'dart:io';

import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class CustomizationWidget extends StatelessWidget {
  final List<OrderedCustomization> orderedCustomizations;

  const CustomizationWidget({Key? key, required this.orderedCustomizations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderProductEditController controller =
        Get.find<OrderProductEditController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderedCustomizations.map((orderedCustomization) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCustomizationName(
                  orderedCustomization.orderedCustomizationId),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            ...orderedCustomization.selectedOptions.map((option) {
              return _buildOptionWidget(controller, orderedCustomization, option);
            }).toList(),
            SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _getCustomizationName(int customizationId) {
    // Implement logic to get the customization name based on ID
    // This might require additional data or mapping
    // For demo purposes, returning a placeholder
    return 'Customization $customizationId';
  }

  Widget _buildOptionWidget(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    switch (option.type.toLowerCase()) {
      case 'button':
        return _buildButtonOptions(controller, customization, option);
      case 'color':
        return _buildColorOptions(controller, customization, option);
      case 'image':
        return _buildImageOptions(controller, customization, option);
      case 'uploadpicture':
        return _buildUploadPictureOption(controller, customization, option);
      case 'attachmessage':
        return _buildAttachMessageOption(controller, customization, option);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildButtonOptions(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: option.optionValues.map((optionValue) {
        return Obx(() {
          final isSelected = optionValue.isSelected.value;
          return ElevatedButton(
            onPressed: () {
              controller.updateSelectedOption(
                customization.orderedCustomizationId,
                option.name,
                optionValue.value,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Colors.redAccent : Colors.white,
              elevation: isSelected ? 2 : 0,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.redAccent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              optionValue.value,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildColorOptions(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: option.optionValues.map((optionValue) {
        return Obx(() {
          final isSelected = optionValue.isSelected.value;
          return GestureDetector(
            onTap: () {
              controller.updateSelectedOption(
                customization.orderedCustomizationId,
                option.name,
                optionValue.value,
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _parseColor(optionValue.value),
                border: Border.all(
                  color: isSelected ? Colors.redAccent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildImageOptions(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: option.optionValues.map((optionValue) {
          return Obx(() {
            final isSelected = optionValue.isSelected.value;
            return GestureDetector(
              onTap: () {
                controller.updateSelectedOption(
                  customization.orderedCustomizationId,
                  option.name,
                  optionValue.value,
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.redAccent : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.network(
                        '${Strings().resourceUrl}${optionValue.filePath}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildAttachMessageOption(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    final textController = controller.getTextController(
        customization.orderedCustomizationId, option.name);
    final isVisible = controller.getAttachMessageVisibility(
        customization.orderedCustomizationId, option.name);

    return Obx(() {
      final hasText = textController.text.isNotEmpty;
      final buttonText =
          isVisible.value ? 'Done' : (hasText ? 'Edit Message' : 'Add Message');

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                controller.toggleAttachMessageVisibility(
                    customization.orderedCustomizationId, option.name);
              },
              icon: Icon(
                hasText ? Icons.edit : Icons.add,
                size: 18,
              ),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (isVisible.value) ...[
              SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
            if (hasText && !isVisible.value) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  textController.text,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildUploadPictureOption(OrderProductEditController controller,
      OrderedCustomization customization, OrderedOption option) {
    final imagePathRx = controller.getUploadedImagePath(
        customization.orderedCustomizationId, option.name);

    return Obx(() {
      final imagePath = imagePathRx.value;
      final hasImage = imagePath.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    hasImage ? Icons.edit : Icons.upload_file,
                    size: 18,
                  ),
                  label:
                      Text(hasImage ? 'Change Picture' : 'Upload Picture'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Validate mime type
                      String? mimeType = lookupMimeType(image.path);
                      if (mimeType != null &&
                          (mimeType == 'image/jpeg' ||
                              mimeType == 'image/jpg' ||
                              mimeType == 'image/png')) {
                        controller.updateUploadedImage(
                          customization.orderedCustomizationId,
                          option.name,
                          image.path,
                        );
                      } else {
                        Get.snackbar('Error', 'Unsupported file type: $mimeType');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (hasImage) ...[
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      controller.updateUploadedImage(
                        customization.orderedCustomizationId,
                        option.name,
                        '',
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.red[300],
                    ),
                  ),
                ],
              ],
            ),
            if (hasImage) ...[
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Enhanced color parsing to handle various formats
  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.trim();

      if (hexColor.startsWith('0x')) {
        hexColor = hexColor.substring(2);
      } else if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }

      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // Add alpha if missing
      } else if (hexColor.length == 8) {
        // Already has alpha
      } else {
        throw FormatException('Invalid color format');
      }

      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      return Colors.grey;
    }
  }
}
