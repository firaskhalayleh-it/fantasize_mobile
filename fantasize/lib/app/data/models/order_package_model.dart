import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';

class OrderPackage {
  final int orderPackageId;
  final int quantity;
  final double totalPrice;
  final Package package;
  final OrderedCustomization? orderedCustomization;

  OrderPackage({
    required this.orderPackageId,
    required this.quantity,
    required this.totalPrice,
    required this.package,
    this.orderedCustomization,
  });

  factory OrderPackage.fromJson(Map<String, dynamic> json) {
    return OrderPackage(
      orderPackageId: json['OrderPackageID'],
      quantity: json['quantity'],
      totalPrice: double.parse(json['TotalPrice']),
      package: Package.fromJson(json['Package']),
      orderedCustomization: json['OrderedCustomization'] != null
          ? OrderedCustomization.fromJson(json['OrderedCustomization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderPackageID': orderPackageId,
      'quantity': quantity,
      'TotalPrice': totalPrice.toString(),
      'Package': package.toJson(),
      'OrderedCustomization': orderedCustomization?.toJson(),
    };
  }
}
