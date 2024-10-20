import 'package:fantasize/app/data/models/user_model.dart';
import 'package:get/get.dart';
// import 'orders_model.dart';

class Address extends GetxController {
  int? addressID;
  User? user;
  // List<Orders>? orders;
  String? addressLine;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Constructor
  Address({
    this.addressID,
    this.user,
    // this.orders,
    this.addressLine,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create Address object from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressID: json['AddressID'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      // orders: json['Orders'] != null
      //     ? (json['Orders'] as List).map((i) => Orders.fromJson(i)).toList()
      //     : null,
      addressLine: json['AddressLine'],
      city: json['City'],
      state: json['State'],
      country: json['Country'],
      postalCode: json['PostalCode'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  // Method to convert Address object to JSON
  Map<String, dynamic> toJson() {
    return {
      'AddressID': addressID,
      'User': user?.toJson(),
      // 'Orders': orders?.map((e) => e.toJson()).toList(),
      'AddressLine': addressLine,
      'City': city,
      'State': state,
      'Country': country,
      'PostalCode': postalCode,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
