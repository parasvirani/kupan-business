import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/utils/utils.dart';

import '../../../models/restaurant_deal.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantDeal deal;

  const RestaurantCard({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size(100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: size(4),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Restaurant Image
          SizedBox(
            width: size(150),
            height: size(100),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.asset(
                deal.image,
                width: size(150),
                height: size(100),
              ),
            ),
          ),

          // Restaurant Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text : deal.title,
                    fontSize: size(12),
                    color: ColorConst.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: size(8)),
                  CommonText(
                    text : deal.offer,
                    fontSize: size(14),
                    color: ColorConst.black,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: size(8)),
                  CommonText(
                    text : deal.subtitle,
                    fontSize: size(12),
                    color: ColorConst.textGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ),

          // Edit Icon
          Padding(
            padding: EdgeInsets.only(right: size(12), bottom: size(12)),
            child: SvgPicture.asset(
              ImageConst.ic_edit,
              color: ColorConst.black,
            ),
          ),
        ],
      ),
    );
  }
}
