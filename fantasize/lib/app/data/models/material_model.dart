 import 'package:fantasize/app/data/models/material_package.dart';
import 'package:fantasize/app/data/models/matrtial_product.dart';

class MaterialModel {
  final int materialID;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MaterialProductModel>? materialProducts;
  final List<MaterialPackageModel>? materialPackages;

  MaterialModel({
    required this.materialID,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.materialProducts,
    this.materialPackages,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      materialID: json['MaterialID'] as int,
      name: json['Name'] as String,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : null,
      materialProducts: json['materialProduct'] != null
          ? (json['materialProduct'] as List)
              .map((mp) => MaterialProductModel.fromJson(mp))
              .toList()
          : null,
      materialPackages: json['materialPackage'] != null
          ? (json['materialPackage'] as List)
              .map((mp) => MaterialPackageModel.fromJson(mp))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaterialID': materialID,
      'Name': name,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
      'materialProduct': materialProducts?.map((mp) => mp.toJson()).toList(),
      'materialPackage': materialPackages?.map((mp) => mp.toJson()).toList(),
    };
  }
}
  