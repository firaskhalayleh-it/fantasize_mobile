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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressID: json['AddressID'] as int?,
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      addressLine: json['AddressLine'] as String?,
      city: json['City'] as String?,
      state: json['State'] as String?,
      country: json['Country'] as String?,
      postalCode: json['PostalCode'] as String?,
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
    );
  }

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
