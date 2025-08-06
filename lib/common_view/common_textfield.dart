
import 'package:flutter/material.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonTextfield extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  Widget? prefixIcon;
  TextInputType? keyboardType;
  bool? readOnly;
  Function()? onTap;
  CommonTextfield({super.key, required this.controller, required this.hintText, this.prefixIcon, this.keyboardType, this.readOnly, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.none,
      readOnly: readOnly ?? false,
      onTap: onTap ?? (){},
      style: TextStyle(fontSize: size(16),
          color: ColorConst.dark,
          fontWeight: FontWeight.w500,
          fontFamily: 'Urbanist'),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
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
      ),
    );
  }
}
