// lib/app/modules/order_product_edit/views/widgets/quantity_card.dart

import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared_widgets.dart';

class QuantityCard extends StatelessWidget {
  final OrderProductEditController controller;

  const QuantityCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                InfoButton(
                  onTap: () => Get.snackbar(
                    'Quantity',
                    'Adjust the quantity of your order',
                    snackPosition: SnackPosition.TOP,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  onPressed: controller.decrementQuantity,
                ),
                Obx(() => _QuantityDisplay(
                  value: controller.currentQuantity.value,
                )),
                _QuantityButton(
                  icon: Icons.add,
                  onPressed: controller.incrementQuantity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _QuantityDisplay extends StatelessWidget {
  final int value;

  const _QuantityDisplay({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}