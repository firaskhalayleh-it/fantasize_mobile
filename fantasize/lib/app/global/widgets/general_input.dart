import 'package:flutter/material.dart';

class GeneralInput {
  Widget build({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    bool obscureText = false,
    required String? Function(String?)? validator,
    Widget? PostfixIcon,
  }) {
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
        fillColor: Colors.black.withOpacity(0.03999999910593033),
        filled: true,
        suffixIcon: PostfixIcon ?? null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
    );
  }
}
