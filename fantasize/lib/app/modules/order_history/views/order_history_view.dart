// lib/app/modules/order_history/views/order_history_view.dart

import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import '../controllers/order_history_controller.dart';
import 'package:intl/intl.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderHistoryController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(const EdgeInsets.all(0)),
            elevation: WidgetStatePropertyAll(2),
            shadowColor: WidgetStatePropertyAll(Colors.black),
          ),
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: 'Poppins',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.orders.isEmpty) {
          return const Center(child: Text("No orders found"));
        } else {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: controller.orders.asMap().entries.map((entry) {
              int index = entry.key;
              var order = entry.value;
              return _buildOrderCard(context, order, index);
            }).toList(),
          );
        }
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, int index) {
    return Obx(() {
      bool isExpanded = controller.expandedIndices.contains(index);
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                "Order #${order.orderId}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Total: \$${order.totalPrice}\nDate: ${DateFormat.yMMMd().format(order.createdAt)}",
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () {
                controller.toggleExpansion(index);
              },
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: _buildOrderDetails(order),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (order.ordersProducts.isNotEmpty) ...[
            const Text(
              'Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...order.ordersProducts.map((orderProduct) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    ImageHandler.getImageUrl(orderProduct.product.resources),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(orderProduct.product.name),
                subtitle: Text(
                  "\$${orderProduct.product.price} x ${orderProduct.quantity}",
                ),
                trailing: Text(
                  "\$${(double.parse(orderProduct.product.price) * orderProduct.quantity).toStringAsFixed(2)}",
                ),
              );
            }).toList(),
          ],
          if (order.ordersPackages.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Packages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...order.ordersPackages.map((orderPackage) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    ImageHandler.getImageUrl(orderPackage.package.resources),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(orderPackage.package.name),
                subtitle: Text(
                  "\$${orderPackage.package.price} x ${orderPackage.quantity}",
                ),
                trailing: Text(
                  "\$${(double.parse(orderPackage.package.price.toString()) * orderPackage.quantity).toStringAsFixed(2)}",
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
