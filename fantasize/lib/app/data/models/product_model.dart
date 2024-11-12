import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/offer_model.dart';
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
  final Offer? offer;
  final List<Review> reviews;
  final List<ResourcesModel> resources;
  final List<Customization> customizations;
  final SubCategory? subCategory;
  final double? discountPrice; // Add DiscountPrice as nullable

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
    this.offer,
    this.subCategory,
    this.discountPrice, // Include discountPrice in the constructor
  });

  // Factory constructor with enhanced error handling and logging
  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['ProductID'] == null || json['ProductID'] == 0) {
      debugPrint('Error: Invalid or missing ProductID in JSON: $json');
      throw Exception('Error: Product data is invalid or ProductID is missing');
    }

    try {
      debugPrint('Parsing Product JSON: ${json.toString()}');

      // Parse Resources safely
      var resourceList = (json['Resource'] as List?)?.map((resourceJson) {
            if (resourceJson is Map<String, dynamic>) {
              return ResourcesModel.fromJson(resourceJson);
            }
            throw Exception('Error: Invalid resource data: $resourceJson');
          }).toList() ??
          [];

      // Parse Reviews safely
      var reviewList = (json['Review'] as List?)?.map((reviewJson) {
            if (reviewJson is Map<String, dynamic>) {
              return Review.fromJson(reviewJson);
            }
            throw Exception('Error: Invalid review data: $reviewJson');
          }).toList() ??
          [];

      // Parse Offer safely, handling empty objects
      var offer = (json['Offer'] != null && json['Offer'].isNotEmpty)
          ? Offer.fromJson(json['Offer'])
          : null;

      // Parse Customizations safely
      var customizationList =
          (json['Customization'] as List?)?.map((customizationJson) {
                if (customizationJson is Map<String, dynamic>) {
                  return Customization.fromJson(customizationJson);
                }
                throw Exception(
                    'Error: Invalid customization data: $customizationJson');
              }).toList() ??
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
        offer: offer,
        customizations: customizationList,
        subCategory: json['SubCategory'] != null
            ? SubCategory.fromJson(json['SubCategory'])
            : null,
        discountPrice: (json['DiscountPrice'] != null)
            ? json['DiscountPrice'].toDouble()
            : null, // Handle nullable discount price
      );
    } catch (e) {
      debugPrint('Error parsing product JSON for product ${json['Name']}: $e');
      throw Exception('Failed to parse Product: ${json['Name'] ?? ''}');
    }
  }

  // Method to convert a Product instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'ProductID': productId,
      'Name': name,
      'Description': description,
      'Price': price,
      'Quantity': quantity,
      'Status': status,
      'Material': material,
      'AvgRating': avgRating,
      'Offer': offer?.toJson(),
      'Review': reviews.map((review) => review.toJson()).toList(),
      'Resource': resources.map((resource) => resource.toJson()).toList(),
      'Customization': customizations
          .map((customization) => customization.toJson())
          .toList(),
      'SubCategory': subCategory?.toJson(),
      'DiscountPrice': discountPrice, // Include discount price in the JSON output
    };
  }
}
