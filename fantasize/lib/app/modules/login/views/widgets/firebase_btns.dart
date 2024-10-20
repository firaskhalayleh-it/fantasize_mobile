import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirebaseBtns {
  Widget btn(String text, String icon, Color color, Color backgroundColor, VoidCallback onPressed,) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 163,
        height: 56,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset('${icon}', width: 24, height: 24),
            Text(
              '${text}',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
