import 'package:fantasize/app/data/models/material_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';

class MaterialProductModel {
  final int materialProductID;
  final MaterialModel material;
  final Product? product;    // Assuming you have a ProductsModel
  final int percentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaterialProductModel({
    required this.materialProductID,
    required this.material,
    this.product,
    required this.percentage,
    this.createdAt,
    this.updatedAt,
  });

  factory MaterialProductModel.fromJson(Map<String, dynamic> json) {
    return MaterialProductModel(
      materialProductID: json['MaterialProductID'] as int,
      material: MaterialModel.fromJson(json['Material']),
      product: json['Product'] != null
          ? Product.fromJson(json['Product'])
          : null,
      percentage: json['percentage'] as int,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaterialProductID': materialProductID,
      'Material': material?.toJson(),
      'Product': product?.toJson(),
      'percentage': percentage,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
