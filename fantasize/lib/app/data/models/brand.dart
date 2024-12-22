import 'package:fantasize/app/data/models/product_model.dart';


class Brand {
  final int brandId;
  final String name;

  Brand({
    required this.brandId,
    required this.name,
  });

  // Factory constructor to create a Brand object from JSON
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['BrandID'] as int,
      name: json['Name'] as String,
      
    );
  }

  // Method to convert a Brand object to JSON
  Map<String, dynamic> toJson() {
    return {
      'BrandID': brandId,
      'Name': name,
    };
  }
}
