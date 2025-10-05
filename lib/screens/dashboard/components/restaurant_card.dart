import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/utils/utils.dart';

import '../../../models/kupans_list_res.dart';


class RestaurantCard extends StatelessWidget {
  final KupanData deal;
  RestaurantCard({Key? key, required this.deal}) : super(key: key);

  DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size(100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: size(4),
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
              child: Image.network(
                deal.kupanImages![0],
                width: size(150),
                height: size(100),
                fit: BoxFit.cover,
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
                    text : dashboardController.userUpdateRes.value?.data?.sellerInfo?.businessName ?? "",
                    fontSize: size(12),
                    color: ColorConst.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: size(8)),
                  CommonText(
                    text : deal.title ?? "",
                    fontSize: size(14),
                    maxLines: 2,
                    color: ColorConst.black,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: size(8)),
                  CommonText(
                    text : "Limited time deals",
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
