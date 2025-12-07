import 'package:flutter/material.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/utils/utils.dart';

class RecentCouponCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;

  const RecentCouponCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size(8)),
        border: Border.all(
          color: ColorConst.secondary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size(6)),
              topRight: Radius.circular(size(6)),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: size(100),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: size(100),
                  color: Colors.grey.shade300,
                  child: Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          // Text Content
          Padding(
            padding: EdgeInsets.all(size(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: title,
                  fontSize: size(12),
                  color: ColorConst.dark,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: size(4)),
                  CommonText(
                    text: subtitle!,
                    fontSize: size(10),
                    color: ColorConst.grey,
                    fontWeight: FontWeight.w400,
                    maxLines: 1,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
