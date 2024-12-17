import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PackageCustomizationWidget extends StatelessWidget {
  final List<Customization> customizations;

  const PackageCustomizationWidget({super.key, required this.customizations});

  @override
  Widget build(BuildContext context) {
    final uniqueCustomizations = {
      for (var customization in customizations)
        customization.customizationId: customization
    }.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...uniqueCustomizations.expand<Widget>((customization) {
          return (customization.options).map<Widget>((option) {
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOptionTypeWidget(customization.customizationId, option),
                ],
              ),
            );
          }).toList();
        }).toList(),
      ],
    );
  }

  Widget _buildOptionTypeWidget(int customizationId, Option option) {
    switch (option.type) {
      case 'button':
        return _buildButtonOptions(customizationId, option);
      case 'color':
        return _buildColorOptions(customizationId, option);
      case 'image':
        return _buildImageOptions(customizationId, option);
      case 'uploadPicture':
        return _buildUploadPictureOption(customizationId, option);
      case 'attachMessage':
        return _buildAttachMessageOption(customizationId, option);
      default:
        return Container();
    }
  }

  Widget _buildButtonOptions(int customizationId, Option option) {
    final PackageDetailsController controller = Get.find();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: (option.optionValues).map((optionValue) {
        return Obx(() {
          final isSelected = controller.isOptionSelected(
            customizationId,
            optionValue.value,
          );
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: () {
                controller.updateSelectedOption(
                  customizationId,
                  option.name,
                  optionValue.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.redAccent : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.grey[800],
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildColorOptions(int customizationId, Option option) {
    final PackageDetailsController controller = Get.find();

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: (option.optionValues).map((optionValue) {
        return Obx(() {
          final isSelected = controller.isOptionSelected(
            customizationId,
            optionValue.value,
          );
          return GestureDetector(
            onTap: () {
              controller.updateSelectedOption(
                customizationId,
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

  Widget _buildImageOptions(int customizationId, Option option) {
    final PackageDetailsController controller = Get.find();

    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: (option.optionValues).map((optionValue) {
          return Obx(() {
            final isSelected = controller.isOptionSelected(
              customizationId,
              optionValue.value,
            );
            return GestureDetector(
              onTap: () {
                controller.updateSelectedOption(
                  customizationId,
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
                        '${Strings().resourceUrl}/${optionValue.filePath}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
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

  Widget _buildAttachMessageOption(int customizationId, Option option) {
    final controller = Get.find<PackageDetailsController>();
    final textController =
        controller.getTextController(customizationId, option.name);
    final isVisible =
        controller.getAttachMessageVisibility(customizationId, option.name);

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
                  customizationId,
                  option.name,
                );
              },
              icon: Icon(
                hasText ? Icons.edit : Icons.add,
                size: 18,
              ),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
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

  Widget _buildUploadPictureOption(int customizationId, Option option) {
    final controller = Get.find<PackageDetailsController>();
    final imagePathRx =
        controller.getUploadedImagePath(customizationId, option.name);

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
                  label: Text(hasImage ? 'Change Picture' : 'Upload Picture'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      controller.updateUploadedImage(
                        customizationId,
                        option.name,
                        image.path,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        customizationId,
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return Colors.grey;
    }
  }
}
