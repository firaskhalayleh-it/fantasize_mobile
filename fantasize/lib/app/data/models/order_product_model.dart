import 'package:fantasize/app/data/models/product_model.dart';

class OrderProduct {
  final int orderProductId;
  final int quantity;
  final double totalPrice;
  final Product product;
  final OrderedCustomization? orderedCustomization; // Make nullable

  OrderProduct({
    required this.orderProductId,
    required this.quantity,
    required this.totalPrice,
    required this.product,
    this.orderedCustomization, // Nullable field
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      orderProductId: json['OrderProductID'],
      quantity: json['Quantity'],
      totalPrice: double.parse(json['TotalPrice']),
      product: Product.fromJson(json['Product']),
      orderedCustomization: json['OrderedCustomization'] != null
          ? OrderedCustomization.fromJson(json['OrderedCustomization'])
          : null, // Only parse if not null
    );
  }
}