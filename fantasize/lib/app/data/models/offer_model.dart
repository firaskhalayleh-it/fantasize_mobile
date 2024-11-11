import 'package:fantasize/app/data/models/package_model.dart';

import 'product_model.dart';

class Offer {
  final int offerID;
  final String discount;
  final bool isActive;
  final String validFrom;
  final String validTo;
  final List<Product> products;
  final List<Package> packages;

  Offer({
    required this.offerID,
    required this.discount,
    required this.isActive,
    required this.validFrom,
    required this.validTo,
    required this.products,
    required this.packages,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerID: json['OfferID'],
      discount: json['Discount'],
      isActive: json['IsActive'],
      validFrom: json['ValidFrom'],
      validTo: json['ValidTo'],
      products: (json['Products'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      packages: (json['Packages'] as List)
          .map((package) => Package.fromJson(package))
          .toList(),
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'OfferID': offerID,
      'Discount': discount,
      'IsActive': isActive,
      'ValidFrom': validFrom,
      'ValidTo': validTo,
    };
  }
}
