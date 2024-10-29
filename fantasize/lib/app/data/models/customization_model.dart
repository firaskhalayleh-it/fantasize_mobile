class Customization {
  final int customizationId;
  final List<Option> options;

  Customization({
    required this.customizationId,
    required this.options,
  });

  factory Customization.fromJson(Map<String, dynamic> json) {
    var optionList = (json['option'] as List)
        .map((optionJson) => Option.fromJson(optionJson))
        .toList();

    return Customization(
      customizationId: json['CustomizationID'],
      options: optionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomizationID': customizationId,
      'option': options.map((option) => option.toJson()).toList(),
    };
  }
}

class Option {
  final String name;
  final String type;
  final List<OptionValue> optionValues;

  Option({
    required this.name,
    required this.type,
    required this.optionValues,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    var valueList = (json['optionValues'] as List)
        .map((valueJson) => OptionValue.fromJson(valueJson))
        .toList();

    return Option(
      name: json['name'],
      type: json['type'],
      optionValues: valueList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'optionValues': optionValues.map((value) => value.toJson()).toList(),
    };
  }
}

class OptionValue {
  final String value;
  late final bool isSelected;

  OptionValue({
    required this.value,
    required this.isSelected,
  });

  factory OptionValue.fromJson(Map<String, dynamic> json) {
    return OptionValue(
      value: json['value'],
      isSelected: json['isSelected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'isSelected': isSelected,
    };
  }
}