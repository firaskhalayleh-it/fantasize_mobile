import 'package:flutter/material.dart';

class GeneralInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? postfixIcon;

  const GeneralInput({
    Key? key,
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
    required this.validator,
    this.postfixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      keyboardAppearance: Brightness.light,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFF7C8AA0),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        fillColor: Colors.black.withOpacity(0.04),
        filled: true,
        suffixIcon: postfixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
    );
  }
}
