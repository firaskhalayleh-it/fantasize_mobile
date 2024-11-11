import 'package:fantasize/app/data/models/package_model.dart';

import 'product_model.dart';

class Offer {
  final int offerID;
  final String discount;
  final bool isActive;
  final String validFrom;
  final String validTo;

  Offer({
    required this.offerID,
    required this.discount,
    required this.isActive,
    required this.validFrom,
    required this.validTo,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerID: json['OfferID'],
      discount: json['Discount'],
      isActive: json['IsActive'],
      validFrom: json['ValidFrom'],
      validTo: json['ValidTo'],
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
