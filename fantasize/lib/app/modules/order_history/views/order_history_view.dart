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
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF4C5E),
              strokeWidth: 3,
            ),
          );
        } else if (controller.orders.isEmpty) {
          return _buildEmptyState();
        }
        return _buildOrdersList();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
      ),
      title: const Text(
        "Order History",
        style: TextStyle(
          color: Color(0xFFFF4C5E),
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFFF4C5E)),
            onPressed: () => _showFilterModal(Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Color(0xFFFF4C5E).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Orders Found",
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your order history will appear here",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        return Obx(() {
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 300),
              tween: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 50),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildOrderCard(
                context,
                controller.orders[index],
                index,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, int index) {
    return Obx(() {
      bool isExpanded = controller.expandedIndices.contains(index);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF4C5E).withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              _buildOrderHeader(order, index, isExpanded),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: _buildOrderDetails(order),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              if (isExpanded) _buildOrderActions(order),
            ],
          ),
        ),
      );
    });
  }

  // Continue with the rest of the enhanced widgets...
  // I'll provide the remaining enhanced widgets in the next part due to length
  Widget _buildOrderHeader(Order order, int index, bool isExpanded) {
    return InkWell(
      onTap: () => controller.toggleExpansion(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderIdBadge(order),
                _buildExpandButton(isExpanded),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateAndPrice(order),
                _buildStatusBadge(order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderIdBadge(Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF4C5E),
            Color(0xFFFF8F9C),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            "Order #${order.orderId}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedRotation(
        turns: isExpanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 300),
        child: Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFFFF4C5E),
        ),
      ),
    );
  }

  Widget _buildDateAndPrice(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              DateFormat.yMMMd().format(order.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "\$${order.totalPrice}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4C5E),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            status.capitalizeFirst ?? status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.ordersProducts.isNotEmpty) ...[
            _buildSectionHeader('Products'),
            ...order.ordersProducts.map((product) => 
              _buildProductTile(product, order.orderId.toString())
            ),
          ],
          if (order.ordersPackages.isNotEmpty) ...[
            SizedBox(height: order.ordersProducts.isNotEmpty ? 16 : 0),
            _buildSectionHeader('Packages'),
            ...order.ordersPackages.map((package) => 
              _buildPackageTile(package, order.orderId.toString())
            ),
          ],
        ],
      ),
    );
  }

  // ... Rest of the enhanced widgets will continue in Part 3
  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4C5E),
                  Color(0xFFFF8F9C),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildProductTile(OrderProduct orderProduct, String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
              children: [
                // Product Image

                  
                // Product Details
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderProduct.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${orderProduct.quantity}x",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            Text(
                              orderProduct.product.price,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4C5E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "\$${(double.parse(orderProduct.product.price) * orderProduct.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFFFF4C5E),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Edit Button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                onPressed: () => _navigateToEditOrderProduct(orderProduct, orderId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTile(OrderPackage orderPackage, String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
              children: [
                // Package Image
              
                // Package Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderPackage.package.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${orderPackage.quantity}x",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            Text(
                              orderPackage.package.price.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4C5E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "\$${(orderPackage.package.price * orderPackage.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFFFF4C5E),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Edit Button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                onPressed: () => _navigateToEditOrderPackage(orderPackage, orderId),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  void _showFilterModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Color(0xFFFF4C5E)),
                        SizedBox(width: 12),
                        Text(
                          'Filter Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Status Dropdown
                    Text(
                      'Order Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.searchStatus.value.isNotEmpty
                            ? controller.searchStatus.value
                            : null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: InputBorder.none,
                        ),
                        hint: Text('Select status'),
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
                    ),
                    
                    const SizedBox(height: 24),
                    // Product Name Field
                    Text(
                      'Product Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilterTextField(
                      initialValue: controller.searchProductName.value,
                      onChanged: (value) {
                        controller.searchProductName.value = value;
                      },
                      hintText: 'Enter product name',
                    ),
                    
                    const SizedBox(height: 24),
                    // Package Name Field
                    Text(
                      'Package Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilterTextField(
                      initialValue: controller.searchPackageName.value,
                      onChanged: (value) {
                        controller.searchPackageName.value = value;
                      },
                      hintText: 'Enter package name',
                    ),
                    
                    const SizedBox(height: 32),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.resetSearch();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Color(0xFFFF4C5E)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: Color(0xFFFF4C5E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF4C5E),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: Text(
                              'Apply Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTextField({
    required String initialValue,
    required Function(String) onChanged,
    required String hintText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF4C5E)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    OrderStatus status = orderStatusFromString(order.status);
    List<Widget> actions = [];

    if (status == OrderStatus.rejected) {
      actions.add(_buildActionButton(
        icon: Icons.edit,
        label: 'Edit Order',
        color: Colors.blueAccent,
        onPressed: () {
          if (order.ordersPackages.isNotEmpty) {
            var package = order.ordersPackages.first;
            _navigateToEditOrderPackage(package, order.orderId.toString());
          } else if (order.ordersProducts.isNotEmpty) {
            var product = order.ordersProducts.first;
            _navigateToEditOrderProduct(product, order.orderId.toString());
          }
        },
      ));
    }

    if (status != OrderStatus.delivered &&
        status != OrderStatus.canceled &&
        status != OrderStatus.returned &&
        status != OrderStatus.completed) {
      actions.add(_buildActionButton(
        icon: Icons.cancel,
        label: 'Cancel Order',
        color: Colors.redAccent,
        onPressed: () => _showActionConfirmation(
          order,
          'Cancel Order',
          'Are you sure you want to cancel this order?',
          OrderStatus.canceled,
        ),
      ));
    }

    if (status == OrderStatus.delivered) {
      actions.add(_buildActionButton(
        icon: Icons.undo,
        label: 'Return Order',
        color: Colors.orangeAccent,
        onPressed: () => _showActionConfirmation(
          order,
          'Return Order',
          'Are you sure you want to return this order?',
          OrderStatus.returned,
        ),
      ));
    }

    if (actions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
          backgroundColor: color.withOpacity(0.05),
        ),
      ),
    );
  }

  void _showActionConfirmation(
    Order order,
    String title,
    String message,
    OrderStatus newStatus,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                newStatus == OrderStatus.canceled
                    ? Icons.cancel_outlined
                    : Icons.undo_outlined,
                size: 48,
                color: newStatus == OrderStatus.canceled
                    ? Colors.redAccent
                    : Colors.orangeAccent,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateOrderStatus(order.orderId, newStatus);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newStatus == OrderStatus.canceled
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditOrderProduct(OrderProduct orderProduct, String orderId) {
    Get.toNamed('/order-product-edit', arguments: {
      'orderId': orderId,
      'orderProductId': orderProduct.orderProductId,
      'currentProductId': orderProduct.product.productId,
      'currentQuantity': orderProduct.quantity,
      'OrderedCustomizations': orderProduct.orderedCustomization?.toJson() ?? [],
    });
  }

  void _navigateToEditOrderPackage(OrderPackage orderPackage, String orderId) {
    Get.toNamed('/order-package-edit', arguments: {
      'orderId': orderId,
      'orderPackageId': orderPackage.orderPackageId,
      'currentPackageId': orderPackage.package.packageId,
      'currentQuantity': orderPackage.quantity,
      'OrderedCustomizations': orderPackage.orderedCustomization?.toJson() ?? [],
    });
  }
  
  _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blueAccent;
      case 'purchased':
        return Colors.greenAccent;
      case 'under review':
        return Colors.orangeAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'shipped':
        return Colors.purpleAccent;
      case 'delivered':
        return Colors.greenAccent;
      case 'returned':
        return Colors.orangeAccent;
      case 'canceled':
        return Colors.redAccent;
      case 'completed':
        return Colors.greenAccent;
      default:
        return Colors.grey[600];
    }
  }

}
