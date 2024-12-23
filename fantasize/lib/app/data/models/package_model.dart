import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/material_package.dart';
import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/package_product_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/data/models/subcategory_model.dart';

class Package {
  final int packageId;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String status;
  final double avgRating;
  Offer? offer;
  
  final SubCategory? subCategory;
  final List<PackageProduct> packageProducts;
  final List<ResourcesModel> resources;
  final List<Customization> customizations;
  final List<Review> reviews;
  final List<MaterialPackageModel>? materialPackages;

  Package({
    required this.packageId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.status,
    required this.avgRating,
    this.subCategory,
    this.offer,
    this.packageProducts = const [],
    this.resources = const [],
    this.customizations = const [],
    this.reviews = const [],
    this.materialPackages ,
  });

  // JSON deserialization
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['PackageID'] ?? 0,
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      price: (json['Price'] != null) ? double.parse(json['Price']) : 0.0,
      quantity: json['Quantity'] ?? 0,
      status: json['Status'] ?? 'unknown',
      avgRating: (json['AvgRating'] ?? 0).toDouble(),
      subCategory: json['SubCategory'] != null
          ? SubCategory.fromJson(json['SubCategory'])
          : null,
      packageProducts: (json['PackageProduct'] as List?)
              ?.map((e) => PackageProduct.fromJson(e))
              .toList() ??
          [],
      offer: json['Offer'] != null ? Offer.fromJson(json['Offer']) : null,
      resources: (json['Resource'] as List?)
              ?.map((e) => ResourcesModel.fromJson(e))
              .toList() ??
          [],
      customizations: (json['Customization'] as List?)
              ?.map((e) => Customization.fromJson(e))
              .toList() ??
          [],
      reviews:
          (json['Reviews'] as List?)?.map((e) => Review.fromJson(e)).toList() ??
              [],

      materialPackages: (json['MaterialPackage'] as List?)
              ?.map((e) => MaterialPackageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'PackageID': packageId,
      'Name': name,
      'Description': description,
      'Price': price.toString(),
      'Quantity': quantity,
      'Status': status,
      'AvgRating': avgRating,
      'SubCategory': subCategory?.toJson(),
      'Offer': offer?.toJson(),
      'PackageProduct': packageProducts.map((e) => e.toJson()).toList(),
      'Resource': resources.map((e) => e.toJson()).toList(),
      'Customization': customizations.map((e) => e.toJson()).toList(),
      'Reviews': reviews.map((e) => e.toJson()).toList(),
      'MaterialPackage': materialPackages?.map((e) => e.toJson()).toList(),
    };
  }

  static defaultPackage() {
    return Package(
      packageId: 0,
      name: '',
      description: '',
      price: 0.0,
      quantity: 0,
      status: 'unknown',
      avgRating: 0.0, 
    );
  }
}
