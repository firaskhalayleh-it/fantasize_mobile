import 'package:flutter/material.dart';

class Devider {
  Widget build() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 10.0),
            child: Divider(
              color: Color(0xFFE0E4EB),
              height: 36,
            ),
          ),
        ),
        Text("Or",
            style: TextStyle(
                color: Color(0xFF262626),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400)),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Divider(
              color: Color(0xFFE0E4EB),
              height: 36,
            ),
          ),
        ),
      ],
    );
  }
}
