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
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        leading: (Get.previousRoute == '/splash')
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Get.toNamed('/splash');
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Get.offAllNamed('/home');
                },
              ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.cart.value == null ||
            (controller.cart.value!.ordersProducts.isEmpty &&
                controller.cart.value!.ordersPackages.isEmpty) ||
            controller.cart.value!.status == true) {
          return Center(child: Text("Your cart is empty"));
        } else {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Product List Section
              Text("Products", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...controller.cart.value!.ordersProducts.map((orderProduct) {
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

              // Package List Section
              if (controller.cart.value!.ordersPackages.isNotEmpty) ...[
                Divider(),
                Text("Packages", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...controller.cart.value!.ordersPackages.map((orderPackage) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        ImageHandler.getImageUrl(
                            orderPackage.package.resources),
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

              Divider(),

              // Shipping Information
              _buildShippingInformationSection(),

              Divider(),

              // Order Summary
              _buildOrderSummarySection(),

              Divider(),

              // Address Selection
              _buildAddressSelectionSection(),

              Divider(),

              // Gift and Anonymous checkboxes
              _buildGiftAndAnonymousSection(),

              SizedBox(height: 20),

              // Checkout Button
              _buildCheckoutButton(),

              SizedBox(
                height: Get.size.height * 0.15,
              )
            ],
          );
        }
      }),
    );
  }

  Widget _buildShippingInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Shipping Information",
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Card(
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.selectedPaymentMethodId.value,
                onChanged: (value) {
                  controller.selectedPaymentMethodId.value = value!;
                },
                items: controller.paymentMethods.map((method) {
                  return DropdownMenuItem<int>(
                    value: method.paymentMethodID,
                    child: Row(
                      children: [
                        Image.asset(
                          method.cardType == "Visa"
                              ? 'assets/images/visa.png'
                              : 'assets/images/mastercard.png',
                          height: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "**** **** **** ${method.cardNumber?.substring(method.cardNumber!.length - 4) ?? ''}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: TextButton(
        //     onPressed: () {
        //       // Navigate to payment method management screen if needed
        //     },
        //     child: Text("Edit Card", style: TextStyle(color: Colors.blue)),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "Total (${controller.cart.value!.ordersProducts.length + controller.cart.value!.ordersPackages.length} items)"),
            Text("\$${controller.cart.value!.totalPrice}",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Shipping Fee"),
            Text("\$0.00", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sub Total"),
            Text("\$${controller.cart.value!.totalPrice}",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Address"),
        Card(
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.selectedAddressId.value,
                onChanged: (value) {
                  controller.selectedAddressId.value = value!;
                },
                items: controller.addresses.map((address) {
                  return DropdownMenuItem<int>(
                    value: address.addressID,
                    child: Text(
                      "${address.addressLine}, ${address.city}",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: TextButton(
        //     onPressed: () {
        //       // Navigate to address management screen if needed
        //     },
        //     child: Text("Edit Address", style: TextStyle(color: Colors.blue)),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildGiftAndAnonymousSection() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: controller.isGift.value,
              onChanged: (value) {
                controller.isGift.value = value!;
              },
            ),
            Text("Is Gift?"),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: controller.isAnonymous.value,
              onChanged: (value) {
                controller.isAnonymous.value = value!;
              },
            ),
            Text("Is Anonymous?"),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      onPressed: () {
        controller.checkout();
      },
      child: Text("Checkout", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
