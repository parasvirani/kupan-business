import 'package:flutter/material.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';
import 'common_text.dart';

class CommonOutlineButton extends StatelessWidget {
  Function() onPressed;
  String text;

  CommonOutlineButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size(10), vertical: size(5)),
        decoration: BoxDecoration(
          color: ColorConst.white,
          borderRadius: BorderRadius.circular(
            size(8),
          ),
          border: Border.all(
            color: ColorConst.grey.withAlpha(30),
            width: size(1),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorConst.black.withAlpha(5),
              offset: Offset(0, 4),
              blurRadius: size(4),
              spreadRadius: size(0)
            )
          ]
        ),
        child: CommonText(
          text: text,
          color: Colors.grey,
          fontSize: size(16),
        ),
      ),
    );
  }
}
