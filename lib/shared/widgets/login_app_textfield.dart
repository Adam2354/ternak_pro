import 'package:flutter/material.dart';

import '../theme.dart';

class LoginAppTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool error;
  final TextInputType? keyboardType;
  final void Function(bool)? onFocusChange;

  const LoginAppTextfield({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.error = false,
    this.keyboardType,
    this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: AppTextStyle.regular.copyWith(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFD0D0D0),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: error ? AppColors.primaryRed : const Color(0xFFD0D0D0),
              width: error ? 2 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: error ? AppColors.primaryRed : AppColors.primaryBlue,
              width: 2.5,
            ),
          ),
        ),
        style: AppTextStyle.regular.copyWith(
          fontSize: 14,
          color: AppColors.black100,
        ),
      ),
    );
  }
}
