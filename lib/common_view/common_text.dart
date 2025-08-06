import 'package:flutter/material.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonText extends StatelessWidget {
  String text;
  Color? color;
  String? fontFamily;
  FontWeight? fontWeight;
  double? fontSize;
  TextAlign? textAlign;

  CommonText(
      {super.key,
      required this.text,
      this.color,
      this.fontFamily,
      this.fontWeight,
      this.fontSize,
      this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? ColorConst.white,
        fontFamily: fontFamily ?? "Urbanist",
        fontWeight: fontWeight ?? FontWeight.w500,
        fontSize: fontSize ?? size(14),
      ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
