import 'package:fantasize/app/data/models/ordered_option.dart';

class OrderedCustomization {
  final int orderedCustomizationId;
  final List<OrderedOption> selectedOptions;

  OrderedCustomization({
    required this.orderedCustomizationId,
    required this.selectedOptions,
  });
factory OrderedCustomization.fromJson(Map<String, dynamic> json) {
  var selectedOptionsJson = json['SelectedOptions'];
  List<OrderedOption> selectedOptionsList = [];

  if (selectedOptionsJson is List) {
    for (var option in selectedOptionsJson) {
      if (option is Map<String, dynamic>) {
        // Check if the option contains 'name', 'type', and 'optionValues'
        if (option.containsKey('name') && option.containsKey('type') && option.containsKey('optionValues')) {
          selectedOptionsList.add(OrderedOption.fromJson(option));
        }
        // Handle nested 'SelectedOptions'
        else if (option.containsKey('SelectedOptions') && option['SelectedOptions'] is List) {
          for (var innerOption in option['SelectedOptions']) {
            if (innerOption.containsKey('name') && innerOption.containsKey('type') && innerOption.containsKey('optionValues')) {
              selectedOptionsList.add(OrderedOption.fromJson(innerOption));
            }
          }
        }
      }
    }
  } else if (selectedOptionsJson is Map<String, dynamic>) {
    if (selectedOptionsJson.containsKey('name') && selectedOptionsJson.containsKey('type') && selectedOptionsJson.containsKey('optionValues')) {
      selectedOptionsList.add(OrderedOption.fromJson(selectedOptionsJson));
    }
  }

  return OrderedCustomization(
    orderedCustomizationId: json['OrderedCustomizationID'],
    selectedOptions: selectedOptionsList,
  );
}



  Map<String, dynamic> toJson() {
    return {
      'OrderedCustomizationID': orderedCustomizationId, 
      'SelectedOptions':
          selectedOptions.map((option) => option.toJson()).toList(),
    };
  }
}
