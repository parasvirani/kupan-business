import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kupan_business/common_view/common_text.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonTextfield extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  Widget? prefixIcon;
  Widget? suffixIcon;
  TextInputType? keyboardType;
  bool? readOnly;
  Function()? onTap;
  Function(String value)? onChanged;
  final String? Function(String?)? validator;
  bool isNumber = false;
  bool isUpperCase = false; // New parameter
  int minLines;
  int maxLines;

  CommonTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.readOnly,
    this.onTap,
    this.validator,
    this.isNumber = false,
    this.isUpperCase = false, // New parameter
    this.suffixIcon,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.none,
      readOnly: readOnly ?? false,
      onTap: onTap ?? () {},
      onChanged: onChanged ?? (value) {},
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: isUpperCase
          ? TextCapitalization.characters
          : TextCapitalization.none,
      inputFormatters: [
        if (isNumber) ...[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        if (isUpperCase) UpperCaseTextFormatter(), // Custom formatter
      ],
      style: TextStyle(
          fontSize: size(16),
          color: ColorConst.dark,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter'),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: size(10),
          vertical: size(5),
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontFamily: "Inter",
          fontWeight: FontWeight.w500,
          fontSize: size(14),
        ),
        prefixText: isNumber ? "+91 " : '',
        prefixStyle: TextStyle(
            fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter'),
        prefixIconConstraints: BoxConstraints(
          maxHeight: size(24),
          maxWidth: size(50),
        ),
        suffixIconConstraints: BoxConstraints(
          maxHeight: size(24),
          maxWidth: size(50),
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
            fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter'),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size(8)),
            borderSide: BorderSide(color: Colors.red)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size(8)),
            borderSide: BorderSide(color: ColorConst.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size(8)),
            borderSide: BorderSide(color: ColorConst.primary)),
      ),
    );
  }
}

// Custom TextInputFormatter for uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}