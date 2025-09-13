import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';

import '../utils/utils.dart';

class CommonTimePicker extends StatelessWidget {
  TimeOfDay? value;
  String hintText;
  VoidCallback onTap;
  bool isError;

  CommonTimePicker(
      {super.key,
      required this.value,
      required this.hintText,
      required this.onTap,
        this.isError = false
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: isError ? Colors.red : ColorConst.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(ImageConst.icTime, width: size(24),),
            const SizedBox(width: 12),
            Text(
              value != null ? value!.format(context) : hintText,
              style: TextStyle(
                  fontSize: size(16),
                  color: ColorConst.dark,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }
}
