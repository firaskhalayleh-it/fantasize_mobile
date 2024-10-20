// lib/app/modules/splash/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Use Obx to reactively update the image's position
        return Transform.translate(
          offset: Offset(0, controller.verticalOffset.value),
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              controller.updateOffset(details.localPosition.dy);
            },
            onVerticalDragEnd: (details) {
              // When the user lifts their finger, navigate to the next screen
              if (details.primaryVelocity! > 0) {
                controller.navigateToHome();
              } else {
                // Reset the position if no navigation is needed
                controller.resetPosition();
              }
            },
            child:
                Center(child: Image.asset('assets/icons/fantasize_logo.png')),
          ),
        );
      }),
    );
  }
}
