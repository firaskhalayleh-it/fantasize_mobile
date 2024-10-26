import 'package:fantasize/app/data/models/ordered_option.dart';

class OrderedCustomization {
  final int orderedCustomizationId;
  final List<OrderedOption> selectedOptions;

  OrderedCustomization({
    required this.orderedCustomizationId,
    required this.selectedOptions,
  });

  factory OrderedCustomization.fromJson(Map<String, dynamic> json) {
    return OrderedCustomization(
      orderedCustomizationId: json['OrderedCustomizationID'],
      selectedOptions: (json['SelectedOptions'] as List<dynamic>)
          .map((optionJson) => OrderedOption.fromJson(optionJson))
          .toList(),
    );
  }
}