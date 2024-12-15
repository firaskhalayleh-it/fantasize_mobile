// lib/app/data/models/order_model.dart

import 'package:fantasize/app/data/models/order_product_model.dart';
import 'package:fantasize/app/data/models/order_package_model.dart';

class Order {
  final int orderId;
  final String status;
  final bool isGift;
  final String? giftMessage;
  final bool isAnonymous;
  final String totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderProduct> ordersProducts;
  final List<OrderPackage> ordersPackages; 

  Order({
    required this.orderId,
    required this.status,
    required this.isGift,
    this.giftMessage,
    required this.isAnonymous,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.ordersProducts,
    required this.ordersPackages,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['OrderID'],
      status: json['Status'],
      isGift: json['IsGift'],
      giftMessage: json['GiftMessage'],
      isAnonymous: json['IsAnonymous'],
      totalPrice: json['TotalPrice'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      ordersProducts: (json['OrdersProducts'] as List)
          .map((e) => OrderProduct.fromJson(e))
          .toList(),
      ordersPackages: (json['OrdersPackages'] as List)
          .map((e) => OrderPackage.fromJson(e))
          .toList(),
    );
  }
  
}
// lib/app/data/models/order_model.dart

enum OrderStatus {
  pending,
  purchased,
  underReview,
  rejected,
  shipped,
  delivered,
  returned,
  canceled,
  completed,
}

OrderStatus orderStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'purchased':
      return OrderStatus.purchased;
    case 'under review':
      return OrderStatus.underReview;
    case 'rejected':
      return OrderStatus.rejected;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'returned':
      return OrderStatus.returned;
    case 'canceled':
      return OrderStatus.canceled;
    case 'completed':
      return OrderStatus.completed;
    default:
      return OrderStatus.pending;
  }
}

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'pending';
    case OrderStatus.purchased:
      return 'purchased';
    case OrderStatus.underReview:
      return 'under review';
    case OrderStatus.rejected:
      return 'rejected';
    case OrderStatus.shipped:
      return 'shipped';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.returned:
      return 'returned';
    case OrderStatus.canceled:
      return 'canceled';
    case OrderStatus.completed:
      return 'completed';
    default:
      return 'pending';
  }
}

