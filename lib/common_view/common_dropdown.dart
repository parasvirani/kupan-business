import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kupan_business/const/image_const.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonDropdown extends StatefulWidget {
  String? value;
  String hintText;
  Widget? prefixIcon;
  List<String> items;
  final String? Function(String?)? validator;
  ValueChanged<String?> onChanged;

  CommonDropdown({
    super.key,
    required this.value,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator
  });

  @override
  State<CommonDropdown> createState() => _CommonDropdownState();
}

class _CommonDropdownState extends State<CommonDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.value,
      icon: SvgPicture.asset(ImageConst.icDown),
      style: TextStyle(fontSize: size(16),
          color: ColorConst.dark,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter'),
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorStyle: TextStyle(
          color: Colors.red,
          fontFamily: "Inter",
          fontWeight: FontWeight.w500,
          fontSize: size(14),
        ),
        hintStyle: TextStyle(fontSize: size(16),
            color: ColorConst.dark,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter'),
        prefixIconConstraints: BoxConstraints(
          maxHeight: size(24),
          maxWidth: size(50),
        ),
        prefixIcon: widget.prefixIcon,
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
      items: widget.items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }
}
