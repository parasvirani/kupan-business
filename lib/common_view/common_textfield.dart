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
  CommonTextfield({super.key, required this.controller, required this.hintText, this.prefixIcon, this.keyboardType, this.readOnly, this.onTap,this.validator, this.isNumber = false, this.suffixIcon, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.none,
      readOnly: readOnly ?? false,
      onTap: onTap ?? (){},
      onChanged: onChanged ?? (value) {},
      validator: validator,
      inputFormatters: isNumber
          ? [
        FilteringTextInputFormatter.digitsOnly, // only digits
        LengthLimitingTextInputFormatter(10), // max 10 digits
      ]
          : [],
      style: TextStyle(fontSize: size(16),
          color: ColorConst.dark,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter'),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: size(10),),
        errorStyle: TextStyle(
          color: Colors.red,
          fontFamily: "Inter",
          fontWeight: FontWeight.w500,
          fontSize: size(14),
        ),
        prefixText: isNumber ? "+91 ": '',
        prefixStyle: TextStyle(fontSize: size(16),
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
        hintStyle: TextStyle(fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter'),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
          borderSide: BorderSide(color: Colors.red)
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
          borderSide: BorderSide(color: ColorConst.border)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size(8)),
            borderSide: BorderSide(color: ColorConst.primary)
        ),

      ),
    );
  }
}
