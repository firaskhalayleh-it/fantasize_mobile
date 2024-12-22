import 'package:fantasize/app/data/models/material_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';

class MaterialPackageModel {
  final int materialPackageID;
  final MaterialModel material;
  final Package? package;    // Assuming you have a Package
  final int percentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaterialPackageModel({
    required this.materialPackageID,
    required this.material,
    this.package,
    required this.percentage,
    this.createdAt,
    this.updatedAt,
  });

  factory MaterialPackageModel.fromJson(Map<String, dynamic> json) {
    return MaterialPackageModel(
      materialPackageID: json['MaterialPackageID'] as int,
      material: MaterialModel.fromJson(json['Material'] ?? {}),
      package: json['Package'] != null
          ? Package.fromJson(json['Package'])
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
      'MaterialPackageID': materialPackageID,
      'Material': material?.toJson(),
      'Package': package?.toJson(),
      'percentage': percentage,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
