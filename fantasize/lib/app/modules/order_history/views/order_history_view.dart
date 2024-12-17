// lib/app/modules/order_history/views/order_history_view.dart

// [No changes required based on the current requirements. Ensure that navigation to edit views passes the necessary arguments, especially for `uploadPicture` options.]

import 'package:fantasize/app/data/models/order_model.dart';
import 'package:fantasize/app/data/models/order_package_model.dart';
import 'package:fantasize/app/data/models/order_product_model.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderHistoryController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Color(0xFFFF4C5E),
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.redAccent),
            onPressed: () {
              _showFilterModal(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF4C5E)),
          );
        } else if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No orders found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: controller.orders.asMap().entries.map((entry) {
            return _buildOrderCard(context, entry.value, entry.key);
          }).toList(),
        );
      }),
    );
  }

  /// Show filter modal
  void _showFilterModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Filter Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: controller.searchStatus.value.isNotEmpty
                    ? controller.searchStatus.value
                    : null,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['pending', 'purchased', 'under review', 'rejected',
                  'shipped', 'delivered', 'returned', 'canceled','completed']
                    .map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.capitalizeFirst ?? status),
                  );
                }).toList(),
                onChanged: (String? newStatus) {
                  controller.searchStatus.value = newStatus ?? '';
                },
              ),
              SizedBox(height: 16),
              // Product Name TextField
              TextFormField(
                initialValue: controller.searchProductName.value,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  controller.searchProductName.value = value;
                },
              ),
              SizedBox(height: 16),
              // Package Name TextField
              TextFormField(
                initialValue: controller.searchPackageName.value,
                decoration: InputDecoration(
                  labelText: 'Package Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  controller.searchPackageName.value = value;
                },
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetSearch();
                        Get.back();
                      },
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.searchOrders(
                          status: controller.searchStatus.value.isNotEmpty
                              ? controller.searchStatus.value
                              : null,
                          productName: controller.searchProductName.value.isNotEmpty
                              ? controller.searchProductName.value
                              : null,
                          packageName: controller.searchPackageName.value.isNotEmpty
                              ? controller.searchPackageName.value
                              : null,
                        );
                        Get.back();
                      },
                      child: Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF4C5E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, int index) {
    return Obx(() {
      bool isExpanded = controller.expandedIndices.contains(index);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildOrderHeader(order, index, isExpanded),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: _buildOrderDetails(order),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            _buildOrderActions(order),
          ],
        ),
      );
    });
  }

  Widget _buildOrderHeader(Order order, int index, bool isExpanded) {
    return InkWell(
      onTap: () => controller.toggleExpansion(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order ID
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4C5E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Order #${order.orderId}",
                    style: const TextStyle(
                      color: Color(0xFFFF4C5E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Expand Icon
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date and Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMd().format(order.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${order.totalPrice}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4C5E),
                      ),
                    ),
                  ],
                ),
                // Order Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.capitalizeFirst ?? order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'purchased':
        return Colors.blue;
      case 'under review':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'returned':
        return Colors.teal;
      case 'canceled':
        return Colors.grey;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.ordersProducts.isNotEmpty) ...[
            _buildSectionHeader('Products'),
            ...order.ordersProducts
                .map((orderProduct) => _buildProductTile(orderProduct,order.orderId.toString()))
                .toList(),
          ],
          if (order.ordersPackages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader('Packages'),
            ...order.ordersPackages
                .map((orderPackage) => _buildPackageTile(orderPackage,order.orderId.toString()))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4C5E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(OrderProduct orderProduct,String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ImageHandler.getImageUrl(orderProduct.product.resources),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderProduct.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${orderProduct.product.price} × ${orderProduct.quantity}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${(double.parse(orderProduct.product.price) * orderProduct.quantity).toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () {
              // Navigate to edit product screen or open a dialog
              _navigateToEditOrderProduct(orderProduct,orderId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTile(OrderPackage orderPackage,String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ImageHandler.getImageUrl(orderPackage.package.resources),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderPackage.package.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${orderPackage.package.price} × ${orderPackage.quantity}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${(double.parse(orderPackage.package.price.toString()) * orderPackage.quantity).toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () {
              // Navigate to edit package screen or open a dialog
              _navigateToEditOrderPackage(orderPackage,orderId);
            },
          ),
        ],
      ),
    );
  }

  /// Navigate to edit order product
  void _navigateToEditOrderProduct(OrderProduct orderProduct,String orderId) {
    Get.toNamed('/order-product-edit', arguments: {
      'orderId': orderId,
      'orderProductId': orderProduct.orderProductId,
      'currentProductId': orderProduct.product.productId,
      'currentQuantity': orderProduct.quantity,
      'OrderedCustomizations': orderProduct.orderedCustomization?.toJson() ?? [],
    });
  }

  /// Navigate to edit order package
  void _navigateToEditOrderPackage(OrderPackage orderPackage,orderId) {
    Get.toNamed('/order-package-edit', arguments: {
      'orderId':orderId,
      'orderPackageId': orderPackage.orderPackageId,
      'currentPackageId': orderPackage.package.packageId,
      'currentQuantity': orderPackage.quantity,
      'OrderedCustomizations': orderPackage.orderedCustomization?.toJson() ?? [],
    });
  }

  /// Build actions based on order status
  Widget _buildOrderActions(Order order) {
    OrderStatus status = orderStatusFromString(order.status);

    List<Widget> actions = [];

    // If order is rejected, allow editing
    if (status == OrderStatus.rejected) {
      actions.add(
        TextButton.icon(
          onPressed: () {
            // Navigate to product/package details for editing
            // Example for package editing
            // Replace with actual logic based on order content
            if (order.ordersPackages.isNotEmpty) {
              var package = order.ordersPackages.first;
              _navigateToEditOrderPackage(package, order.orderId.toString());
            } else if (order.ordersProducts.isNotEmpty) {
              var product = order.ordersProducts.first;
              _navigateToEditOrderProduct(product, order.orderId.toString());
            }
          },
          icon: Icon(Icons.edit, color: Colors.blueAccent),
          label: Text(
            'Edit Order',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      );
    }

    // If order is not delivered, allow cancellation
    if (status != OrderStatus.delivered &&
        status != OrderStatus.canceled &&
        status != OrderStatus.returned &&
        status != OrderStatus.completed) {
      actions.add(
        TextButton.icon(
          onPressed: () {
            _showCancelConfirmation(order);
          },
          icon: Icon(Icons.cancel, color: Colors.redAccent),
          label: Text(
            'Cancel Order',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    // If order is delivered, allow return
    if (status == OrderStatus.delivered) {
      actions.add(
        TextButton.icon(
          onPressed: () {
            _showReturnConfirmation(order);
          },
          icon: Icon(Icons.undo, color: Colors.orangeAccent),
          label: Text(
            'Return Order',
            style: TextStyle(color: Colors.orangeAccent),
          ),
        ),
      );
    }

    // If no actions, return empty container
    if (actions.isEmpty) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  /// Show confirmation dialog for canceling an order
  void _showCancelConfirmation(Order order) {
    Get.defaultDialog(
      title: 'Cancel Order',
      middleText: 'Are you sure you want to cancel this order?',
      textCancel: 'No',
      textConfirm: 'Yes',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.updateOrderStatus(order.orderId, OrderStatus.canceled);
        Get.back();
      },
    );
  }

  /// Show confirmation dialog for returning an order
  void _showReturnConfirmation(Order order) {
    Get.defaultDialog(
      title: 'Return Order',
      middleText: 'Are you sure you want to return this order?',
      textCancel: 'No',
      textConfirm: 'Yes',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.updateOrderStatus(order.orderId, OrderStatus.returned);
        Get.back();
      },
    );
  }
}
