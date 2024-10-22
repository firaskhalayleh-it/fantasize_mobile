import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/payment_method_controller.dart';

class PaymentMethodView extends GetView<PaymentMethodController> {
  const PaymentMethodView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PaymentMethodView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PaymentMethodView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
