
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonTextfield extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  Widget? prefixIcon;
  TextInputType? keyboardType;
  bool? readOnly;
  Function()? onTap;
  final String? Function(String?)? validator;
  bool isNumber = false;
  CommonTextfield({super.key, required this.controller, required this.hintText, this.prefixIcon, this.keyboardType, this.readOnly, this.onTap,this.validator, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.none,
      readOnly: readOnly ?? false,
      onTap: onTap ?? (){},
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
          fontFamily: 'Urbanist'),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        prefixText: isNumber ? "+91 ": null,
        prefixStyle: TextStyle(fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist'),
        prefixIconConstraints: BoxConstraints(
          maxHeight: size(24),
          maxWidth: size(50),
        ),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size(8)),
          borderSide: BorderSide(color: ColorConst.grey)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size(8)),
            borderSide: BorderSide(color: ColorConst.primary)
        ),

      ),
    );
  }
}
