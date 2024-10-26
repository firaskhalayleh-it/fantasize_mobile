import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if the cart is empty or if `cart.value` is null
      if (controller.cart.value == null ||
          controller.cart.value!.ordersProducts.isEmpty ||
          controller.cart.value!.status == true) {
        // Show an empty cart message if no products or the cart has been checked out
        return Center(child: Text("Your cart is empty"));
      } else {
        // Display the cart products in a ListView
        return ListView(
          children: [
            // Loop through the order products in the cart and display each item
            for (var orderProduct in controller.cart.value!.ordersProducts)
              ListTile(
                leading: Image.network(
                 '${Strings().resourceUrl}/${orderProduct.product.resources.first.entityName}',
                  width: 50,
                  height: 50,
                ),
                
                title: Text(orderProduct.product!.name),
                subtitle: Text(
                  "${orderProduct.product!.price} x ${orderProduct.quantity}",
                ),
                trailing: Text(
                  "\$${(double.parse(orderProduct.product!.price) * orderProduct.quantity).toStringAsFixed(2)}",
                ),
              ),
            
            // Checkout button
            ElevatedButton(
              onPressed: () {
                controller.checkout(1, 1, false, false); // Replace with actual params if needed
              },
              child: Text("Checkout"),
            ),
          ],
        );
      }
    });
  }
}
