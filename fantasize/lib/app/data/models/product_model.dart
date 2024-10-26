import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/data/models/subcategory_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class Product {
  final int productId;
  final String name;
  final String description;
  final String price;
  final int quantity;
  final String status;
  final String material;
  final double avgRating;
  final List<Review> reviews;
  final List<ResourcesModel> resources;
  final List<Customization> customizations;
  final SubCategory? subCategory; // SubCategory is optional

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.status,
    required this.material,
    required this.avgRating,
    required this.reviews,
    required this.resources,
    required this.customizations,
    this.subCategory, // SubCategory is optional
  });

  // Factory constructor with enhanced error handling and logging
  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['ProductID'] == null || json['ProductID'] == 0) {
      debugPrint('Error: Invalid or missing ProductID in JSON: $json');
      throw Exception('Error: Product data is invalid or ProductID is missing');
    }

    try {
      debugPrint('Parsing Product JSON: ${json.toString()}');

      var resourceList = (json['Resource'] as List?)
              ?.map((resourceJson) {
                if (resourceJson is Map<String, dynamic>) {
                  return ResourcesModel.fromJson(resourceJson);
                }
                throw Exception('Error: Invalid resource data: $resourceJson');
              })
              .toList() ??
          [];

      var reviewList = (json['Review'] as List?)
              ?.map((reviewJson) {
                if (reviewJson is Map<String, dynamic>) {
                  return Review.fromJson(reviewJson);
                }
                throw Exception('Error: Invalid review data: $reviewJson');
              })
              .toList() ??
          [];

      var customizationList = (json['Customization'] as List?)
              ?.map((customizationJson) {
                if (customizationJson is Map<String, dynamic>) {
                  return Customization.fromJson(customizationJson);
                }
                throw Exception(
                    'Error: Invalid customization data: $customizationJson');
              })
              .toList() ??
          [];

      return Product(
        productId: json['ProductID'],
        name: json['Name'] ?? 'Unknown Product',
        description: json['Description'] ?? '',
        price: json['Price'] ?? '0',
        quantity: json['Quantity'] ?? 0,
        status: json['Status'] ?? 'in stock',
        material: json['Material'] ?? '',
        avgRating: (json['AvgRating'] ?? 0.0).toDouble(),
        reviews: reviewList,
        resources: resourceList,
        customizations: customizationList,
        subCategory: json['SubCategory'] != null
            ? SubCategory.fromJson(json['SubCategory'])
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing product JSON for product ${json['Name']}: $e');
      throw Exception('Failed to parse Product: ${json['Name'] ?? ''}');
    }
  }
}
class OrderedCustomization {
  int orderedCustomizationId;
  List<OrderedOption> selectedOptions;

  OrderedCustomization({
    required this.orderedCustomizationId,
    required this.selectedOptions,
  });

  factory OrderedCustomization.fromJson(Map<String, dynamic> json) {
    return OrderedCustomization(
      orderedCustomizationId: json['OrderedCustomizationID'],
      selectedOptions: (json['SelectedOptions'] as List)
          .map((optionJson) => OrderedOption.fromJson(optionJson))
          .toList(),
    );
  }
}


