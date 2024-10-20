import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';

class CustomizationWidget extends StatelessWidget {
  final Option option;

  CustomizationWidget({required this.option});

  @override
  Widget build(BuildContext context) {
    switch (option.type) {
      case 'button':
        print('Button');
        return _buildButtonOptions();
      case 'color':
        print('Color'); 
        return _buildColorOptions();
      case 'image':
        print('Image');
        return _buildImageOptions();
      case 'message':
        print('Message');
        return _buildMessageOption();
      case 'options':
        print('Options');
        return _buildRadioOptions();
      case 'text':
        print('Text');
        return _buildTextOption();
      default:
        return Container();
    }
  }

  // Button options
  Widget _buildButtonOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: option.optionValues.map((optionValue) {
        return Container(
          margin: EdgeInsets.only(
              right: 8.0), // Adds a margin of 8.0 on the left side
          child: ElevatedButton(
            onPressed: () {
              // Handle button selection
            },
            child: Text(
              optionValue.value,
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor:
                  optionValue.isSelected ? Colors.red : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Color Options
 Widget _buildColorOptions() {
  return Wrap(
    spacing: 8,
    children: option.optionValues.map((optionValue) {
      return GestureDetector(
        onTap: () {
          // Set the selected color to the option's value (assumed to be the color or identifier)
          Get.find<ProductDetailsController>().isSelectedColor.value = optionValue.value;
        },
        child: Obx(() {
          return Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              
              color: Color(_getColorFromHex(optionValue.value)),
              border: Border.all(
                color: Get.find<ProductDetailsController>().isSelectedColor.value == optionValue.value
                    ? Colors.green
                    : Colors.transparent,
                width: 2,
              ),
            ),
          );
        }),
      );
    }).toList(),
  );
}


  // Image Options
  Widget _buildImageOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: option.optionValues.map((optionValue) {
        return GestureDetector(
          onTap: () {
            // Handle image selection
          },
          child: Image.network(
            '${Strings().resourceUrl}/${optionValue.value}',
            width: 100,
            height: 100,
          ),
        );
      }).toList(),
    );
  }

  // Message option
  Widget _buildMessageOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Attach a Message?"),
        Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Yes")),
            ElevatedButton(onPressed: () {}, child: Text("No")),
          ],
        ),
      ],
    );
  }

  // Radio Button Options
  Widget _buildRadioOptions() {
    return GroupButton(
      isRadio: true,
      buttons: option.optionValues.map((value) => value.value).toList(),
    );
  }

  // Text Option (for entering text)
  Widget _buildTextOption() {
    return TextField(
      decoration: InputDecoration(
        labelText: option.name,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Helper function to convert color string to hex color
  int _getColorFromHex(String colorStr) {
    return int.parse(colorStr.replaceAll("#", "0xFF"));
  }
}
