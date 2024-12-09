import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicSize {
  // Singleton pattern to ensure consistent dynamic sizes across the app
  static final DynamicSize _instance = DynamicSize._internal();

  factory DynamicSize() => _instance;

  DynamicSize._internal();

  // Screen thresholds for different device types
  static const double phoneMaxWidth = 600; // Max width for phones
  static const double tabletMaxWidth = 1200; // Max width for tablets

  // Helper to get dynamic width based on screen size
  double dynamicWidth(double fraction) {
    return Get.width * fraction;
  }

  // Helper to get dynamic height based on screen size
  double dynamicHeight(double fraction) {
    return Get.height * fraction;
  }

  // Helper for padding and margins
  double dynamicPadding(double fraction) {
    return Get.width * fraction;
  }

  // Helper for radius (e.g., for rounded corners)
  double dynamicRadius(double baseRadius) {
    if (Get.width <= phoneMaxWidth) {
      return baseRadius; // For phones
    } else if (Get.width <= tabletMaxWidth) {
      return baseRadius * 1.5; // For tablets
    } else {
      return baseRadius * 2; // For large screens
    }
  }

  // Helper to scale font sizes dynamically (optional)
  double dynamicFont(double baseSize) {
    if (Get.width <= phoneMaxWidth) {
      return baseSize; // For phones
    } else if (Get.width <= tabletMaxWidth) {
      return baseSize * 1.2; // For tablets
    } else {
      return baseSize * 1.5; // For large screens
    }
  }
}
