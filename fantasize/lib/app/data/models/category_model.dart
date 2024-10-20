import 'package:fantasize/app/data/models/subcategory_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryModel {
  int? categoryId;
  String? name;
  bool? isActive;
  List<SubCategory>? subCategories;
  String? imageUrl;

  CategoryModel({this.categoryId, this.name, this.isActive, this.subCategories, this.imageUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['CategoryID'],
      name: json['Name'],
      isActive: json['IsActive'],
      subCategories: (json['SubCategory'] as List)
          .map((subCategory) => SubCategory.fromJson(subCategory))
          .toList(),
      imageUrl: Uri.encodeFull( json['Image']['entityName']), // Correctly formatted URL
    );
  }
}
