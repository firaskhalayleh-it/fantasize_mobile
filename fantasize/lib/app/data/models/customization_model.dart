import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:get/get.dart';

class Customization {
  final int customizationId;
  final List<Option> options;

  Customization({
    required this.customizationId,
    required this.options,
  });

  factory Customization.fromJson(Map<String, dynamic> json) {
    var optionsJson = json['option'];
    List<Option> optionsList;

    if (optionsJson is List) {
      optionsList =
          optionsJson.map((optionJson) => Option.fromJson(optionJson)).toList();
    } else if (optionsJson is Map<String, dynamic>) {
      optionsList = [Option.fromJson(optionsJson)];
    } else {
      optionsList = [];
    }

    return Customization(
      customizationId: json['CustomizationID'],
      options: optionsList,
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
    var optionValuesJson = json['optionValues'];
    List<OptionValue> optionValuesList;

    if (optionValuesJson is List) {
      optionValuesList = optionValuesJson
          .map((valueJson) => OptionValue.fromJson(valueJson))
          .toList();
    } else if (optionValuesJson is Map<String, dynamic>) {
      optionValuesList = [OptionValue.fromJson(optionValuesJson)];
    } else {
      optionValuesList = [];
    }

    return Option(
      name: json['name'],
      type: json['type'],
      optionValues: optionValuesList,
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
  final String name;
  RxBool isSelected;
  String filePath;

  OptionValue({
    required this.value,
    required this.name,
    required this.isSelected,
    this.filePath = '',
  });

  factory OptionValue.fromJson(Map<String, dynamic> json) {
    return OptionValue(
      name: json['name'],
      value: json['value'],
      isSelected: RxBool(json['isSelected'] ?? false),
      filePath: json['filePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'isSelected': isSelected,
      'filePath': filePath,
    };
  }
}
