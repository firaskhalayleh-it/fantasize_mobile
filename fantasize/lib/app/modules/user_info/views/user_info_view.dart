import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/user_info_controller.dart';

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UserInfoView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'UserInfoView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
