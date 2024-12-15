// lib/app/modules/order_package_edit/views/order_package_edit_view.dart

import 'package:fantasize/app/modules/order_history/controllers/order_package_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/order_package_edit/views/widgets/customization_widget.dart';

class OrderPackageEditView extends GetView<OrderPackageEditController> {
  const OrderPackageEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is properly initialized via bindings
    final controller = Get.find<OrderPackageEditController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order Package'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.orderPackage == null) {
          return Center(child: Text('Order package data not available'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( // To handle overflow when customization options are extensive
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package Information
                  Text(
                    'Package ID: ${controller.currentPackageId}', // Replace with actual package name if available
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => controller.decrementQuantity(),
                          ),
                          Obx(() => Text(
                                controller.currentQuantity.toString(),
                                style: TextStyle(fontSize: 18),
                              )),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => controller.incrementQuantity(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Customization Section
                  if (controller.orderedCustomizations.isNotEmpty)
                    CustomizationWidget(
                      orderedCustomizations: controller.orderedCustomizations,
                    ),
                  if (controller.orderedCustomizations.isEmpty)
                    Text('No customization options available'),
                  SizedBox(height: 20),

                  // Save Changes Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateOrderPackage();
                      },
                      child: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
