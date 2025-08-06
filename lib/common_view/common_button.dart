
import 'package:flutter/material.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';
import 'common_text.dart';

class CommonButton extends StatelessWidget {
  Function() onPressed;
  String text;
  CommonButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConst.primary,
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: CommonText(
        text: text,
        fontSize: size(14),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
