
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';
import 'common_text.dart';

class CommonButton extends StatelessWidget {
  Function() onPressed;
  String text;
  bool isLoading;
  bool isDisable;
  CommonButton({super.key, required this.onPressed, required this.text, this.isLoading = false, this.isDisable = false});

  @override
  Widget build(BuildContext context) {
    return isLoading ? CupertinoActivityIndicator() : ElevatedButton(
      onPressed: isDisable ? null : onPressed ,
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
        color: isDisable ? Colors.grey : Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
