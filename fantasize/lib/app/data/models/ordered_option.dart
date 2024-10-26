class OrderedOption {
  final String name;
  final String type;
  final List<OrderedOptionValue> optionValues;

  OrderedOption({
    required this.name,
    required this.type,
    required this.optionValues,
  });

      factory OrderedOption.fromJson(Map<String, dynamic> json) {
    return OrderedOption(
      name: json['name'],
      type: json['type'],
      optionValues: (json['optionValues'] as List<dynamic>)
          .map((valueJson) => OrderedOptionValue.fromJson(valueJson))
          .toList(),
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
  final String value;
  final bool isSelected;

  OrderedOptionValue({
    required this.name,
    required this.value,
    required this.isSelected,
  });

    factory OrderedOptionValue.fromJson(Map<String, dynamic> json) {
    return OrderedOptionValue(
      name: json['name'],
      value: json['value'],
      isSelected: json['isSelected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "value": value,
      "isSelected": isSelected,
    };
  }
}
