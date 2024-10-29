// lib/app/modules/package_details/views/widgets/package_customization_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';
import 'package:fantasize/app/global/strings.dart';

class PackageCustomizationWidget extends StatelessWidget {
  final List<Customization> customizations;

  PackageCustomizationWidget({required this.customizations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: customizations
          .expand((customization) => customization.options.map((option) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        option.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Switch between option types
                    _buildOptionTypeWidget(option),
                  ],
                );
              }))
          .toList(),
    );
  }

  Widget _buildOptionTypeWidget(Option option) {
    switch (option.type) {
      case 'button':
        return _buildButtonOptions(option);
      case 'color':
        return _buildColorOptions(option);
      case 'image':
        return _buildImageOptions(option);
      case 'text':
        return _buildTextOption(option);
      default:
        return Container();
    }
  }

  // Button customization
  Widget _buildButtonOptions(Option option) {
    return Wrap(
      spacing: 8.0,
      children: option.optionValues.map((optionValue) {
        return ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: optionValue.isSelected ? Colors.red : Colors.grey,
          ),
          child: Text(optionValue.value),
        );
      }).toList(),
    );
  }

  // Color picker customization
  Widget _buildColorOptions(Option option) {
    return Wrap(
      spacing: 8.0,
      children: option.optionValues.map((optionValue) {
        return GestureDetector(
          onTap: () {
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(int.parse(optionValue.value)),
              border: Border.all(
                color: optionValue.isSelected ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Image options customization
  Widget _buildImageOptions(Option option) {
    return Wrap(
      spacing: 8.0,
      children: option.optionValues.map((optionValue) {
        return GestureDetector(
          onTap: () {
          },
          child: Image.network(
            '${Strings().resourceUrl}/${optionValue.value}',
            width: 80,
            height: 80,
          ),
        );
      }).toList(),
    );
  }

  // Text field customization
  Widget _buildTextOption(Option option) {
    return TextField(
      onChanged: (text) {
      },
      decoration: InputDecoration(
        labelText: option.name,
        border: OutlineInputBorder(),
      ),
    );
  }
}
