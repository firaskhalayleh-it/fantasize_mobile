// lib/app/data/models/ordered_customization.dart

import 'package:fantasize/app/data/models/customization_model.dart';

class OrderedCustomizationModel {
  final int orderedCustomizationId;
  final List<Option> selectedOptions;

  OrderedCustomizationModel({
    required this.orderedCustomizationId,
    required this.selectedOptions,
  });

  factory OrderedCustomizationModel.fromJson(Map<String, dynamic> json) {
    var selectedOptionsJson = json['SelectedOptions'];
    List<Option> selectedOptionsList = [];

    if (selectedOptionsJson is List) {
      for (var option in selectedOptionsJson) {
        if (option is Map<String, dynamic>) {
          if (option.containsKey('name') &&
              option.containsKey('type') &&
              option.containsKey('optionValues')) {
            selectedOptionsList.add(Option.fromJson(option));
          }
        }
      }
    } else if (selectedOptionsJson is Map<String, dynamic>) {
      if (selectedOptionsJson.containsKey('name') &&
          selectedOptionsJson.containsKey('type') &&
          selectedOptionsJson.containsKey('optionValues')) {
        selectedOptionsList.add(Option.fromJson(selectedOptionsJson));
      }
    }

    return OrderedCustomizationModel(
      orderedCustomizationId: json['OrderedCustomizationID'],
      selectedOptions: selectedOptionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderedCustomizationID': orderedCustomizationId,
      'orderedOptions': selectedOptions.map((option) => option.toJson()).toList(),
    };
  }

  static fromOrderedCustomization(customization) {
    return OrderedCustomizationModel(
      orderedCustomizationId: customization.orderedCustomizationId,
      selectedOptions: customization.selectedOptions,
    );
  }
}
