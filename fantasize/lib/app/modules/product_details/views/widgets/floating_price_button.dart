// lib/app/modules/product_details/views/widgets/floating_price_button.dart

import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloatingPriceButton extends StatelessWidget {
  final String price;
  final VoidCallback onAddToCart;


  const FloatingPriceButton({
    Key? key,
    required this.price,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  ProductDetailsController controller = Get.find<ProductDetailsController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius:80,
            blurRadius:60,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Total: \$${controller.calcTotalPrice()}',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Jost',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onAddToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: Get.width*0.08 , vertical: Get.height*0.015),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add to Cart',
              style: TextStyle(fontSize: 16,fontFamily: 'Jost', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
