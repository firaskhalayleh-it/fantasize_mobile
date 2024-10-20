import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

 Widget loadIcon(String assetPath, double height) {
    if (assetPath.endsWith('.svg')) {
      return Image(
        height: height,
        image: Svg(assetPath), // For SVGs
      );
    } else {
      return Image(
        height: height,
        image: AssetImage(assetPath), // For normal images like PNG
      );
    }
  }

