import 'package:flutter/material.dart';

class PaymentMethod {
  int? paymentMethodID;
  String? method;
  String? cardholderName;
  String? cardNumber;
  DateTime? expirationDate;
  int? cvv;
  String? cardType;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentMethod({
    this.paymentMethodID,
    this.method,
    this.cardholderName,
    this.cardNumber,
    this.expirationDate,
    this.cvv,
    this.cardType,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentMethod(
        paymentMethodID: json['PaymentMethodID'] as int?,
        method: json['Method'] as String?,
        cardholderName: json['CardholderName'] as String?,
        cardNumber: json['CardNumber'] as String?,
        expirationDate: json['ExpirationDate'] != null
            ? DateTime.parse(json['ExpirationDate'])
            : null,
        cvv: json['CVV'] as int?,
        cardType: json['CardType'] as String?,
        createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
        updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      );
    } catch (e) {
      debugPrint('Error parsing PaymentMethod: $e');
      throw Exception('Failed to parse PaymentMethod');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'PaymentMethodID': paymentMethodID,
      'Method': method,
      'CardholderName': cardholderName,
      'CardNumber': cardNumber,
      'ExpiryDate': expirationDate?.toIso8601String(),
      'CVV': cvv,
      'CardType': cardType,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
