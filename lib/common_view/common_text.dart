import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../const/color_const.dart';
import '../utils/utils.dart';

class CommonText extends StatefulWidget {
  String text;
  Color? color;
  String? fontFamily;
  FontWeight? fontWeight;
  double? fontSize;
  TextAlign? textAlign;
  bool isLoading;
  int? maxLines;

  CommonText(
      {super.key,
      required this.text,
      this.color,
      this.fontFamily,
      this.fontWeight,
      this.fontSize,
      this.textAlign,
        this.isLoading = false,
        this.maxLines
      });

  @override
  State<CommonText> createState() => _CommonTextState();
}

class _CommonTextState extends State<CommonText> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading ? Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.color ?? ColorConst.white,
            fontFamily: widget.fontFamily ?? "Inter",
            fontWeight: widget.fontWeight ?? FontWeight.w500,
            fontSize: widget.fontSize ?? size(14),
          ),

          maxLines: widget.maxLines,
          textAlign: widget.textAlign ?? TextAlign.start,
        ),
      ),
    ) : Text(
      widget.text,
      style: TextStyle(
        color: widget.color ?? ColorConst.white,
        fontFamily: widget.fontFamily ?? "Inter",
        fontWeight: widget.fontWeight ?? FontWeight.w500,
        fontSize: widget.fontSize ?? size(14),
        overflow: TextOverflow.ellipsis
      ),
      maxLines: widget.maxLines,
      textAlign: widget.textAlign ?? TextAlign.start,
    );
  }
}
