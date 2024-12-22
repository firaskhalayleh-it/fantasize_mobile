import 'package:fantasize/app/data/models/brand.dart';
import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/matrtial_product.dart';
import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/data/models/subcategory_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For debugPrint

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Product {
  final int productId;
  final String name;
  final String description;
  final String price;
  final int quantity;
  final String status;
  final double avgRating;
  final double? discountPrice;
  final String? createdAt;
  final String? updatedAt;
  final Offer? offer;
  final Brand? brand;
  final SubCategory? subCategory;
  final List<Review> reviews;
  final List<ResourcesModel> resources;
  final List<Customization> customizations;
  final List<MaterialProductModel> materialProducts;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.status,
    required this.avgRating,
    this.discountPrice,
    this.createdAt,
    this.updatedAt,
    this.offer,
    this.brand,
    this.subCategory,
    required this.reviews,
    required this.resources,
    required this.customizations,
    required this.materialProducts,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint('Error: Product JSON is null');
      throw Exception('Product JSON cannot be null');
    }

    if (json['ProductID'] == null) {
      debugPrint('Error: Missing ProductID in JSON: $json');
      throw Exception('ProductID is required');
    }

    try {
      // Safely parse resources as a list
      final List<dynamic> resourceListJson =
          (json['Resource'] is List) ? json['Resource'] as List : <dynamic>[];
      final resources = resourceListJson.map((res) {
        return ResourcesModel.fromJson(res as Map<String, dynamic>);
      }).toList();

      // Safely parse reviews as a list
      final List<dynamic> reviewListJson =
          (json['Review'] is List) ? json['Review'] as List : <dynamic>[];
      final reviews = reviewListJson.map((rev) {
        return Review.fromJson(rev as Map<String, dynamic>);
      }).toList();

      // Safely parse customizations as a list
      final List<dynamic> customizationListJson =
          (json['Customization'] is List)
              ? json['Customization'] as List
              : <dynamic>[];
      final customizations = customizationListJson.map((cust) {
        return Customization.fromJson(cust as Map<String, dynamic>);
      }).toList();

      // Safely parse material products as a list
      final List<dynamic> materialProductListJson =
          (json['MaterialProduct'] is List)
              ? json['MaterialProduct'] as List
              : <dynamic>[];
      final materialProducts = materialProductListJson.map((mp) {
        return MaterialProductModel.fromJson(mp as Map<String, dynamic>);
      }).toList();

      // Parse offer if present
      final Offer? offer = (json['Offer'] is Map && json['Offer'].isNotEmpty)
          ? Offer.fromJson(json['Offer'])
          : null;

      // Parse brand if present
      final Brand? brand = (json['Brand'] is Map && json['Brand'].isNotEmpty)
          ? Brand.fromJson(json['Brand'] as Map<String, dynamic>)
          : null;

      // Parse subcategory if present
      final SubCategory? subCategory = (json['SubCategory'] is Map &&
              json['SubCategory'].isNotEmpty)
          ? SubCategory.fromJson(json['SubCategory'] as Map<String, dynamic>)
          : null;

      return Product(
        productId: json['ProductID'] as int,
        name: json['Name'] ?? 'Unknown Product',
        description: json['Description'] ?? '',
        price: json['Price'] ?? '0',
        quantity: json['Quantity'] ?? 0,
        status: json['Status'] ?? 'in stock',
        avgRating: (json['AvgRating'] ?? 0).toDouble(),
        discountPrice: json['DiscountPrice'] != null
            ? (json['DiscountPrice'] as num).toDouble()
            : null,
        createdAt: json['CreatedAt'] as String?,
        updatedAt: json['UpdatedAt'] as String?,
        offer: offer,
        brand: brand,
        subCategory: subCategory,
        reviews: reviews,
        resources: resources,
        customizations: customizations,
        materialProducts: materialProducts,
      );
    } catch (e) {
      debugPrint('Error parsing product JSON: $e');
      throw Exception('Failed to parse Product: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductID': productId,
      'Name': name,
      'Description': description,
      'Price': price,
      'Quantity': quantity,
      'Status': status,
      'AvgRating': avgRating,
      'DiscountPrice': discountPrice,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
      'Offer': offer?.toJson(),
      'Brand': brand?.toJson(),
      'SubCategory': subCategory?.toJson(),
      'Review': reviews.map((r) => r.toJson()).toList(),
      'Resource': resources.map((res) => res.toJson()).toList(),
      'Customization': customizations.map((c) => c.toJson()).toList(),
      'MaterialProduct': materialProducts.map((mp) => mp.toJson()).toList(),
    };
  }

  static defaultProduct() {
    return Product(
      productId: 0,
      name: 'Unknown Product',
      description: '',
      price: '0',
      quantity: 0,
      status: 'in stock',
      avgRating: 0.0,
      discountPrice: 0.0,
      createdAt: '',
      updatedAt: '',
      offer: null,
      brand: null,
      subCategory: null,
      reviews: [],
      resources: [],
      customizations: [],
      materialProducts: [],
    );
  }
}
