// lib/app/modules/splash/controllers/splash_controller.dart
import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashController extends GetxController with SingleGetTickerProviderMixin {
  var verticalOffset = 0.0.obs; // This will track the vertical offset of the widget
  void updateOffset(double offset) {
  verticalOffset.value = (offset - 400);
}

  void resetPosition() {
    verticalOffset.value = 0.0; // Reset position when the user lifts the finger
  }

  void navigateToHome() {
    VideoPlayerWebOptionsControls.disabled();
    
    Get.offAllNamed('/login');
  }
}
