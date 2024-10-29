// lib/app/data/models/package_product_model.dart

import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';

class PackageProduct {
  final int packageProductId;
  final String productName;
  final int quantity;
  final Package package;
  final Product product;

  PackageProduct({
    required this.packageProductId,
    required this.productName,
    required this.quantity,
    required this.package,
    required this.product,
  });

  // Factory constructor to create a PackageProduct instance from JSON
  factory PackageProduct.fromJson(Map<String, dynamic> json) {
    return PackageProduct(
      packageProductId: json['PackageProductId'],
      productName: json['ProductName'],
      quantity: json['Quantity'],
      package: Package.fromJson(json['Package']),
      product: Product.fromJson(json['Product']),
    );
  }

  // Method to convert a PackageProduct instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'PackageProductId': packageProductId,
      'ProductName': productName,
      'Quantity': quantity,
      'Package': package.toJson(),
      'Product': product.toJson(),
    };
  }
}
