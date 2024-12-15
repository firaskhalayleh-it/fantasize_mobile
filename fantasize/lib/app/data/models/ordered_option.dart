import 'package:get/get_rx/src/rx_types/rx_types.dart';

class OrderedOption {
  String name;
  String type;
   List<OrderedOptionValue> optionValues;

  OrderedOption({
    required this.name,
    required this.type,
    required this.optionValues,
  });

 factory OrderedOption.fromJson(Map<String, dynamic> json) {
  return OrderedOption(
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    optionValues: json['optionValues'] != null
        ? (json['optionValues'] as List<dynamic>)
            .map((valueJson) => OrderedOptionValue.fromJson(valueJson))
            .toList()
        : [],
  );
}


  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "optionValues": optionValues.map((value) => value.toJson()).toList(),
    };
  }
}

class OrderedOptionValue {
  final String name;
   String value;
   RxBool isSelected;
  String? fileName;

  OrderedOptionValue({
    required this.name,
    required this.value,
    bool isSelected = false,
    this.fileName = '',
  }) : isSelected = RxBool(isSelected);
  factory OrderedOptionValue.fromJson(Map<String, dynamic> json) {
    return OrderedOptionValue(
      name: json['name'],
      value: json['value'],
      isSelected: json['isSelected'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "value": value,
      "isSelected": isSelected.value,
      "fileName": fileName ?? '',
    };
  }
}
