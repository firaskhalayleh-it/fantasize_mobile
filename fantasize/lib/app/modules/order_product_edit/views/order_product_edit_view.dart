import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/order_product_edit/views/widgets/customization_widget.dart';

class OrderProductEditView extends GetView<OrderProductEditController> {
  const OrderProductEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the controller
    final controller = Get.put<OrderProductEditController>(OrderProductEditController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order Product'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.orderedCustomization == null) {
          return Center(child: Text('No customization data available'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Information
                  Text(
                    'Product ID: ${controller.currentProductId}', // Replace with actual product name if available
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
                  CustomizationWidget(
                    orderedCustomization: controller.orderedCustomization!,
                  ),
                  SizedBox(height: 20),

                  // Save Changes Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateOrderProduct();
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
