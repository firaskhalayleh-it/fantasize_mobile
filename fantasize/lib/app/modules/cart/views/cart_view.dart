import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.cart.value == null ||
            (controller.cart.value!.ordersProducts.isEmpty &&
                controller.cart.value!.ordersPackages.isEmpty) ||
            controller.cart.value!.status == true) {
          return _buildEmptyState();
        }

        return _buildCartContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Colors.redAccent,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Cart',
            style: TextStyle(
              color: Colors.redAccent,
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4C5E).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFF4C5E)),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            "Loading your cart...",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4C5E).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Color(0xFFFF4C5E),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            "Your cart is empty",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Add items to your cart and they will appear here",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4C5E).withOpacity(0.05),
            Colors.white.withOpacity(0.95),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(16),
        physics: BouncingScrollPhysics(),
        children: [
          _buildProductsSection(),
          if (controller.cart.value!.ordersPackages.isNotEmpty) ...[
            SizedBox(height: 24),
            _buildPackagesSection(),
          ],
          SizedBox(height: 24),
          _buildPaymentMethodSection(),
          SizedBox(height: 24),
          _buildShippingInformationSection(),
          SizedBox(height: 24),
          _buildOrderSummaryCard(),
          SizedBox(height: 24),
          _buildAddressSelectionCard(),
          SizedBox(height: 24),
          _buildGiftAndAnonymousCard(),
          SizedBox(height: 24),
          _buildCheckoutButton(),
          SizedBox(height: Get.size.height * 0.15),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return _buildSection(
      title: "Products",
      children: controller.cart.value!.ordersProducts.map((orderProduct) {
        return TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4C5E).withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Product Image
                        Hero(
                          tag: 'product-${orderProduct.orderProductId}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ImageHandler.getImageUrl(
                                    orderProduct.product.resources),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderProduct.product.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xFFFF4C5E).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${orderProduct.quantity}x",
                                      style: TextStyle(
                                        color: Color(0xFFFF4C5E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "\$${orderProduct.product.price}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Total Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF4C5E),
                                Color(0xFFFF8F9C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "\$${(double.parse(orderProduct.product.price) * orderProduct.quantity).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPackagesSection() {
    return _buildSection(
      title: "Packages",
      children: controller.cart.value!.ordersPackages.map((orderPackage) {
        return TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4C5E).withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Package Image
                        Hero(
                          tag: 'package-${orderPackage.orderPackageId}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ImageHandler.getImageUrl(
                                    orderPackage.package.resources),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Package Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xFFFF4C5E).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "PACKAGE",
                                      style: TextStyle(
                                        color: Color(0xFFFF4C5E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                orderPackage.package.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xFFFF4C5E).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${orderPackage.quantity}x",
                                      style: TextStyle(
                                        color: Color(0xFFFF4C5E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "\$${orderPackage.package.price}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Total Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF4C5E),
                                Color(0xFFFF8F9C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "\$${(orderPackage.package.price * orderPackage.quantity).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 4, bottom: 16),
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
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    if (controller.paymentMethods.isEmpty) {
      return _buildPromptCard(
        icon: Icons.payment_outlined,
        title: "No Payment Methods",
        subtitle: "Please add a payment method in your profile.",
        buttonText: "Add Payment Method",
        onPressed: () {
          Get.toNamed('/payment-method'); // Adjust the route as necessary
        },
      );
    }

    return _buildSection(
      title: "Payment Method",
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF4C5E).withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(Get.context!)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.all(16),
              childrenPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.transparent,
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFF4C5E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Obx(() {
                  if (controller.paymentMethods.isEmpty) {
                    return Icon(
                      Icons.payment_outlined,
                      color: Colors.redAccent,
                      size: 24,
                    );
                  }
                  final selectedMethod = controller.paymentMethods.firstWhere(
                    (method) =>
                        method.paymentMethodID ==
                        controller.selectedPaymentMethodId.value,
                    orElse: () => controller.paymentMethods.first,
                  );
                  return Image.asset(
                    selectedMethod.cardType == "Visa"
                        ? 'assets/images/visa.png'
                        : 'assets/images/mastercard.png',
                    height: 24,
                  );
                }),
              ),
              title: Obx(() {
                if (controller.paymentMethods.isEmpty) {
                  return Text(
                    "No Payment Methods",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  );
                }
                final selectedMethod = controller.paymentMethods.firstWhere(
                  (method) =>
                      method.paymentMethodID ==
                      controller.selectedPaymentMethodId.value,
                  orElse: () => controller.paymentMethods.first,
                );
                return Text(
                  "**** ${selectedMethod.cardNumber?.substring(selectedMethod.cardNumber!.length - 4) ?? ''}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                );
              }),
              subtitle: Text(
                controller.paymentMethods.isEmpty
                    ? "Add a payment method to proceed"
                    : "Tap to change payment method",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              children: controller.paymentMethods.isEmpty
                  ? []
                  : [
                      ...controller.paymentMethods.map((method) {
                        bool isSelected = method.paymentMethodID ==
                            controller.selectedPaymentMethodId.value;
                        return InkWell(
                          onTap: () => controller.selectedPaymentMethodId.value =
                              method.paymentMethodID,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFFF4C5E).withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFFF4C5E)
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  method.cardType == "Visa"
                                      ? 'assets/images/visa.png'
                                      : 'assets/images/mastercard.png',
                                  height: 32,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "**** **** **** ${method.cardNumber?.substring(method.cardNumber!.length - 4) ?? ''}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Expires ${method.expirationDate}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xFFFF4C5E).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFFFF4C5E),
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInformationSection() {
    if (controller.paymentMethods.isEmpty) {
      return SizedBox.shrink(); // Hide the shipping information if no payment methods
    }

    return _buildSection(
      title: "Payment Method",
      children: [
        // Existing payment method selection or prompt
        // Already handled in _buildPaymentMethodSection
      ],
    );
  }

  Widget _buildAddressSelectionCard() {
    if (controller.addresses.isEmpty) {
      return _buildPromptCard(
        icon: Icons.location_on_outlined,
        title: "No Delivery Addresses",
        subtitle: "Please add a delivery address in your profile.",
        buttonText: "Add Address",
        onPressed: () {
          Get.toNamed('/address'); // Adjust the route as necessary
        },
      );
    }

    return _buildSection(
      title: "Delivery Address",
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF4C5E).withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(Get.context!)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.all(16),
              childrenPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.transparent,
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFF4C5E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFFF4C5E),
                  size: 24,
                ),
              ),
              title: Obx(() {
                if (controller.addresses.isEmpty) {
                  return Text(
                    "No Delivery Addresses",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  );
                }
                final selectedAddress = controller.addresses.firstWhere(
                  (address) =>
                      address.addressID == controller.selectedAddressId.value,
                  orElse: () => controller.addresses.first,
                );
                return Text(
                  "${selectedAddress.addressLine}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
              subtitle: Text(
                controller.addresses.isEmpty
                    ? "Add a delivery address to proceed"
                    : "Tap to change delivery address",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              children: controller.addresses.isEmpty
                  ? []
                  : [
                      ...controller.addresses.map((address) {
                        bool isSelected =
                            address.addressID == controller.selectedAddressId.value;
                        return InkWell(
                          onTap: () =>
                              controller.selectedAddressId.value = address.addressID,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFFF4C5E).withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFFF4C5E)
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFFFF4C5E).withOpacity(0.1)
                                        : Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.location_on_rounded
                                        : Icons.location_on_outlined,
                                    color: isSelected
                                        ? Color(0xFFFF4C5E)
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${address.addressLine}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${address.city}, ${address.postalCode}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xFFFF4C5E).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFFFF4C5E),
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryItem(
            "Total Items",
            "${controller.cart.value!.ordersProducts.length + controller.cart.value!.ordersPackages.length}",
          ),
          SizedBox(height: 12),
          _buildSummaryItem("Shipping Fee", "\$0.00"),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey[200]),
          ),
          _buildSummaryItem(
            "Total Amount",
            "\$${controller.cart.value!.totalPrice}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey[600],
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        Container(
          padding: isTotal
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : null,
          decoration: isTotal
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF4C5E),
                      Color(0xFFFF8F9C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.black87,
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF4C5E),
            Color(0xFFFF8F9C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleCheckout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_checkout, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Proceed to Checkout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout() {
    if (controller.paymentMethods.isEmpty || controller.addresses.isEmpty) {
      String missing = '';
      if (controller.paymentMethods.isEmpty) {
        missing += 'payment method';
      }
      if (controller.addresses.isEmpty) {
        if (missing.isNotEmpty) {
          missing += ' and ';
        }
        missing += 'delivery address';
      }

      Get.defaultDialog(
        title: "Missing Information",
        middleText:
            "Please add ${missing} in your profile before proceeding to checkout.",
        textCancel: "Cancel",
        textConfirm: "Go to Profile",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close the dialog
          Get.toNamed('/profile'); // Navigate to profile page
        },
      );
    } else {
      controller.checkout();
    }
  }

  Widget _buildAddressSelectionCardOriginal() {
    // Original address selection card, now handled differently
    // Kept for reference; not used in the modified code
    return SizedBox.shrink();
  }

  Widget _buildGiftAndAnonymousCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Options",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          _buildOptionTile(
            title: "Gift Order",
            subtitle: "Mark this order as a gift",
            icon: Icons.card_giftcard_rounded,
            value: controller.isGift,
          ),
          SizedBox(height: 12),
          _buildOptionTile(
            title: "Anonymous Order",
            subtitle: "Hide your identity from the seller",
            icon: Icons.person_outline_rounded,
            value: controller.isAnonymous,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required RxBool value,
  }) {
    return InkWell(
      onTap: () => value.toggle(),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFF4C5E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF4C5E).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Color(0xFFFF4C5E),
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Obx(() => Switch(
                  value: value.value,
                  onChanged: (newValue) => value.value = newValue,
                  activeColor: Color(0xFFFF4C5E),
                  activeTrackColor: Color(0xFFFF4C5E).withOpacity(0.2),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4C5E).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Color(0xFFFF4C5E),
            size: 40,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4C5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
