import 'package:fantasize/app/data/models/address_model.dart';
import 'package:fantasize/app/data/models/notifications_model.dart';
import 'package:fantasize/app/data/models/payment_method.dart';

class User {
  String username;
  final String email;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? gender;
   String? deviceToken;
  final UserProfilePicture?
      userProfilePicture; // Use the UserProfilePicture model
  final List<PaymentMethod>? paymentMethods;
  final List<Address>? addresses;
  final List<NotificationModel>? notifications;

  // Constructor
  User({
    required this.username,
    required this.email,
    this.dateOfBirth,
    this.phoneNumber,
    this.gender,
    this.deviceToken,
    this.userProfilePicture,
    this.paymentMethods,
    this.addresses,
    this.notifications,
  });

  // Factory constructor to create User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['Username'] ?? json['username'] ?? '',
      email: json['Email'] ?? '' ?? json['email'],
      dateOfBirth: json['dateofbirth'],
      phoneNumber: json['PhoneNumber'],
      gender: json['Gender'],
      deviceToken: json['DeviceToken'],
      userProfilePicture: json['UserProfilePicture'] != null
          ? UserProfilePicture.fromJson(json['UserProfilePicture'])
          : null, // Safely parse UserProfilePicture
      paymentMethods:
          json['PaymentMethods'] != null && json['PaymentMethods'] is List
              ? (json['PaymentMethods'] as List)
                  .map((e) => PaymentMethod.fromJson(e))
                  .toList()
              : [],
      addresses: json['Addresses'] != null && json['Addresses'] is List
          ? (json['Addresses'] as List).map((e) => Address.fromJson(e)).toList()
          : [],
      notifications:
          json['notifications'] != null && json['notifications'] is List
              ? (json['notifications'] as List)
                  .map((e) => NotificationModel.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'UserProfilePicture': userProfilePicture?.toJson(),
      };
}

class UserProfilePicture {
  final int? resourceID;
  final String? entityName;
  final String? fileType;
  final String? filePath;

  UserProfilePicture({
    this.resourceID,
    this.entityName,
    this.fileType,
    this.filePath,
  });

  // Factory constructor to create UserProfilePicture instance from JSON
  factory UserProfilePicture.fromJson(Map<String, dynamic> json) {
    return UserProfilePicture(
      resourceID: json['ResourceID'] ?? 0,
      entityName: json['entityName'] ?? '',
      fileType: json['fileType'] ?? '',
      filePath: json['filePath'] ?? '',
    );
  }

  // Convert UserProfilePicture object to JSON
  Map<String, dynamic> toJson() {
    return {
      'ResourceID': resourceID,
      'entityName': entityName,
      'fileType': fileType,
      'filePath': filePath,
    };
  }
}
