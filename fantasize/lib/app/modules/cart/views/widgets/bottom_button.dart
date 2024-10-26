import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
class BottomButton {
  static Widget build(BuildContext context, CartController controller) {
    return Container(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.checkout(1, 1, false, false); // Example params
        },
        child: Text('Checkout'),
      ),
    );
  }
}