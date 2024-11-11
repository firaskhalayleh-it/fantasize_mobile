import 'package:fantasize/app/data/models/user_model.dart';

class Address {
  int? addressID;
  User? user;
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
      addressLine: json['AddressLine'],
      city: json['City'],
      state: json['State'],
      country: json['Country'],
      postalCode: json['PostalCode'],
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
    );
  }

  // Method to convert Address object to JSON
  Map<String, dynamic> toJson() {
    return {
      'AddressID': addressID,
      'User': user?.toJson(),
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
