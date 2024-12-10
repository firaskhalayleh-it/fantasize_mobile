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
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.redAccent),
          onPressed: () {
            if (Get.previousRoute == '/splash') {
              Get.toNamed('/splash');
            } else {
              Get.offAllNamed('/home');
            }
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          );
        }

        if (controller.cart.value == null ||
            (controller.cart.value!.ordersProducts.isEmpty &&
                controller.cart.value!.ordersPackages.isEmpty) ||
            controller.cart.value!.status == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.redAccent.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  "Your cart is empty",
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

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.redAccent.withOpacity(0.05),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSectionTitle("Products"),
              SizedBox(height: 12),
              ..._buildProductsList(),
              if (controller.cart.value!.ordersPackages.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildSectionTitle("Packages"),
                SizedBox(height: 12),
                ..._buildPackagesList(),
              ],
              SizedBox(height: 24),
              _buildShippingInformationSection(),
              SizedBox(height: 24),
              _buildOrderSummarySection(),
              SizedBox(height: 24),
              _buildAddressSelectionSection(),
              SizedBox(height: 24),
              _buildGiftAndAnonymousSection(),
              SizedBox(height: 24),
              _buildCheckoutButton(),
              SizedBox(height: Get.size.height * 0.15),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  List<Widget> _buildProductsList() {
    return controller.cart.value!.ordersProducts.map((orderProduct) {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              ImageHandler.getImageUrl(orderProduct.product.resources),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            orderProduct.product.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            "\$${orderProduct.product.price} × ${orderProduct.quantity}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Text(
            "\$${(double.parse(orderProduct.product.price) * orderProduct.quantity).toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPackagesList() {
    return controller.cart.value!.ordersPackages.map((orderPackage) {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              ImageHandler.getImageUrl(orderPackage.package.resources),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            orderPackage.package.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            "\$${orderPackage.package.price} × ${orderPackage.quantity}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Text(
            "\$${(double.parse(orderPackage.package.price.toString()) * orderPackage.quantity).toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildShippingInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Payment Method"),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Theme(
            data: Theme.of(Get.context!).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Obx(() {
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
                  height: 32,
                );
              }),
              title: Obx(() {
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
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
              subtitle: Text(
                "Tap to change payment method",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: controller.paymentMethods.map((method) {
                      bool isSelected = method.paymentMethodID ==
                          controller.selectedPaymentMethodId.value;
                      return InkWell(
                        onTap: () {
                          controller.selectedPaymentMethodId.value =
                              method.paymentMethodID;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.redAccent.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "**** **** **** ${method.cardNumber?.substring(method.cardNumber!.length - 4) ?? ''}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Expires ${method.expirationDate}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Order Summary"),
          SizedBox(height: 16),
          _buildSummaryRow(
            "Total Items",
            "${controller.cart.value!.ordersProducts.length + controller.cart.value!.ordersPackages.length}",
          ),
          SizedBox(height: 8),
          _buildSummaryRow("Shipping Fee", "\$0.00"),
          SizedBox(height: 8),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 8),
          _buildSummaryRow(
            "Total Amount",
            "\$${controller.cart.value!.totalPrice}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey[600],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.redAccent : Colors.black87,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Delivery Address"),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Theme(
            data: Theme.of(Get.context!).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Icon(
                Icons.location_on_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              title: Obx(() {
                final selectedAddress = controller.addresses.firstWhere(
                  (address) =>
                      address.addressID == controller.selectedAddressId.value,
                  orElse: () => controller.addresses.first,
                );
                return Text(
                  "${selectedAddress.addressLine}",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
              subtitle: Text(
                "Tap to change delivery address",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: controller.addresses.map((address) {
                      bool isSelected = address.addressID ==
                          controller.selectedAddressId.value;
                      return InkWell(
                        onTap: () {
                          controller.selectedAddressId.value =
                              address.addressID;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.redAccent.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.location_on_rounded
                                    : Icons.location_on_outlined,
                                color: isSelected
                                    ? Colors.redAccent
                                    : Colors.grey[600],
                                size: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${address.addressLine}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
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
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftAndAnonymousSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckboxRow(
            "Gift Order",
            controller.isGift.value,
            (value) => controller.isGift.value = value!,
          ),
          SizedBox(height: 8),
          _buildCheckboxRow(
            "Anonymous Order",
            controller.isAnonymous.value,
            (value) => controller.isAnonymous.value = value!,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(
    String label,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => controller.checkout(),
        child: Text(
          "Proceed to Checkout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.redAccent.withOpacity(0.3),
        ),
      ),
    );
  }
}
