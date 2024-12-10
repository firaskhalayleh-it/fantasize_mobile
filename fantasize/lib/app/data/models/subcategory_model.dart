import 'package:fantasize/app/data/models/category_model.dart';
import 'package:flutter/foundation.dart';

class SubCategory {
  int? subCategoryId;
  String? name;
  bool? isActive;
  CategoryModel ? category;
  SubCategory({this.subCategoryId, this.name, this.isActive});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: json['SubCategoryID'],
      name: json['Name'],
      isActive: json['IsActive'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'SubCategoryID': subCategoryId,
      'Name': name,
      'IsActive': isActive,
    };
  }
}
