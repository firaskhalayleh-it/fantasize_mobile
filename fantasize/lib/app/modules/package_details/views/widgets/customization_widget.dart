// lib/app/modules/package_details/views/widgets/package_customization_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import for File

class PackageCustomizationWidget extends StatelessWidget {
  final List<Customization> customizations;

  PackageCustomizationWidget({required this.customizations});

  @override
  Widget build(BuildContext context) {
    // Ensure customizations are not null
    final uniqueCustomizations = {
      for (var customization in customizations ?? [])
        customization.customizationId: customization
    }.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: uniqueCustomizations.expand<Widget>((customization) {
        // Ensure options are not null
        return (customization.options ?? []).map<Widget>((option) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (option.name != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jost',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              _buildOptionTypeWidget(customization.customizationId, option),
            ],
          );
        }).toList();
      }).toList(),
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
      children: (option.optionValues ?? []).map((optionValue) {
        return Obx(() => ElevatedButton(
              onPressed: () {
                controller.updateSelectedOption(
                  customizationId,
                  option.name,
                  optionValue.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isOptionSelected(
                  customizationId,
                  optionValue.value,
                )
                    ? Colors.redAccent
                    : Colors.grey,
              ),
              child: Text(
                optionValue.value,
                style: Theme.of(Get.context!).textTheme.bodyMedium,
              ),
            ));
      }).toList(),
    );
  }

  Widget _buildColorOptions(int customizationId, Option option) {
    final PackageDetailsController controller = Get.find();

    return Wrap(
      spacing: 8.0,
      children: (option.optionValues ?? []).map((optionValue) {
        return Obx(() => GestureDetector(
              onTap: () {
                controller.updateSelectedOption(
                  customizationId,
                  option.name,
                  optionValue.value,
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Ensure optionValue.value is a valid color string
                  color: _parseColor(optionValue.value),
                  border: Border.all(
                    color: controller.isOptionSelected(
                      customizationId,
                      optionValue.value,
                    )
                        ? Colors.green
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ));
      }).toList(),
    );
  }

  Widget _buildImageOptions(int customizationId, Option option) {
    final PackageDetailsController controller = Get.find();

    return Wrap(
      spacing: 8.0,
      children: (option.optionValues ?? []).map((optionValue) {
        return Obx(() => GestureDetector(
              onTap: () {
                controller.updateSelectedOption(
                  customizationId,
                  option.name,
                  optionValue.value,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.isOptionSelected(
                      customizationId,
                      optionValue.value,
                    )
                        ? Colors.green
                        : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    '${Strings().resourceUrl}/${optionValue.fileName}',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported);
                    },
                  ),
                ),
              ),
            ));
      }).toList(),
    );
  }

  // New method for 'attachMessage'

  Widget _buildAttachMessageOption(int customizationId, Option option) {
    final controller = Get.find<PackageDetailsController>();
    final textController =
        controller.getTextController(customizationId, option.name);
    final isVisible =
        controller.getAttachMessageVisibility(customizationId, option.name);

    return Obx(() {
      final hasText = textController.text.isNotEmpty;
      final buttonText = isVisible.value ? 'Done' : (hasText ? 'Edit' : 'Yes');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              // Toggle visibility
              controller.toggleAttachMessageVisibility(
                  customizationId, option.name);
            },
            child: Text(
              buttonText,
              style: TextStyle(fontFamily: 'Jost', color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
          ),
          if (isVisible.value)
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: textController,
                maxLines: 3, // Limit to 3 lines
                decoration: InputDecoration(
                  labelText: option.name,
                  focusColor: Colors.redAccent,
                  hoverColor: Colors.redAccent,
                  alignLabelWithHint: true, // Align label for multiline
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                      color: Colors.redAccent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  // New method for 'uploadPicture'
  Widget _buildUploadPictureOption(int customizationId, Option option) {
    final controller = Get.find<PackageDetailsController>();
    final imagePathRx =
        controller.getUploadedImagePath(customizationId, option.name);

    return Obx(() {
      final imagePath = imagePathRx.value;
      final hasImage = imagePath.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Upload/Change Picture Icon Button
              IconButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                ),
                icon: Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                ),
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
              ),
              SizedBox(width: 8.0),
              Text(
                hasImage ? 'Change Picture' : 'Upload Picture',
                style: TextStyle(fontFamily: 'Jost', color: Colors.black),
              ),
              // Delete Picture Icon Button (appears only if an image is uploaded)
              if (hasImage)
                IconButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                  ),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Clear the uploaded image
                    controller.updateUploadedImage(
                      customizationId,
                      option.name,
                      '',
                    );
                  },
                ),
            ],
          ),
          // Display the uploaded image if available
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.file(
                File(imagePath),
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported);
                },
              ),
            ),
        ],
      );
    });
  }

  // Helper method to parse color strings safely
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      // Return a default color if parsing fails
      return Colors.grey;
    }
  }
}
