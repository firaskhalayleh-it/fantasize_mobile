import 'package:fantasize/app/data/models/user_model.dart';
import 'package:get/get.dart';
// import 'orders_model.dart';

class PaymentMethod extends GetxController {
  int? paymentMethodID;
  User? user;
  // List<Orders>? orders;
  String? method;
  String? cardholderName;
  String? cardNumber;
  DateTime? expirationDate;
  int? cvv;
  String? cardType;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Constructor
  PaymentMethod({
    this.paymentMethodID,
    this.user,
    // this.orders,
    this.method,
    this.cardholderName,
    this.cardNumber,
    this.expirationDate,
    this.cvv,
    this.cardType,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create PaymentMethod object from JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodID: json['PaymentMethodID'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      // orders: json['Orders'] != null
      //     ? (json['Orders'] as List).map((i) => Orders.fromJson(i)).toList()
      //     : null,
      method: json['Method'],
      cardholderName: json['CardholderName'],
      cardNumber: json['CardNumber'],
      expirationDate: DateTime.parse(json['ExpirationDate']),
      cvv: json['CVV'],
      cardType: json['CardType'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  // Method to convert PaymentMethod object to JSON
  Map<String, dynamic> toJson() {
    return {
      'PaymentMethodID': paymentMethodID,
      'User': user?.toJson(),
      // 'Orders': orders?.map((e) => e.toJson()).toList(),
      'Method': method,
      'CardholderName': cardholderName,
      'CardNumber': cardNumber,
      'ExpirationDate': expirationDate?.toIso8601String(),
      'CVV': cvv,
      'CardType': cardType,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
