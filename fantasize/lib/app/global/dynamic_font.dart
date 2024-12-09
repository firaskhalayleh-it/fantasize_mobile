import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicFont {
  static final DynamicFont _instance = DynamicFont._internal();

  factory DynamicFont() => _instance;

  DynamicFont._internal();

  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  double getSmallFont() {
    return _getFontSize(12, 14, 16);
  }

  double getMediumFont() {
    return _getFontSize(16, 18, 20);
  }

  double getLargeFont() {
    return _getFontSize(40, 44, 48);
  }

  double _getFontSize(double phoneSize, double tabletSize, double largeSize) {
    double width = Get.width;

    if (width <= phoneMaxWidth) {
      return phoneSize;
    } else if (width <= tabletMaxWidth) {
      return tabletSize;
    } else {
      return largeSize;
    }
  }
}
