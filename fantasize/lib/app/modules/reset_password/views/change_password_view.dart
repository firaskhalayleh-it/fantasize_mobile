import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ChangePasswordView extends GetView {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChangePasswordView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ChangePasswordView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
