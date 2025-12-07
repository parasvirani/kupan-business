import 'package:flutter/material.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/utils/utils.dart';

class StatsCard extends StatelessWidget {
  final String count;
  final String label;
  final Color backgroundColor1;
  final Color backgroundColor2;

  const StatsCard({
    Key? key,
    required this.count,
    required this.label,
    required this.backgroundColor1,
    required this.backgroundColor2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: size(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
          backgroundColor1,
          backgroundColor2
        ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        ),
        borderRadius: BorderRadius.circular(size(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            text: count,
            fontSize: size(28),
            color: ColorConst.dark,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: size(4)),
          CommonText(
            text: label,
            fontSize: size(12),
            color: ColorConst.grey,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
