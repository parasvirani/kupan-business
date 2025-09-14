import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/utils/utils.dart';

class MainDrawer extends StatefulWidget {
  Function() onTap;
  MainDrawer({super.key, required this.onTap});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {

  DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorConst.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.only(right: size(20), top: size(20)),
                  child: Container(
                      padding: EdgeInsets.all(size(8)),
                      decoration: BoxDecoration(
                          color: ColorConst.secondaryGrey,
                          shape: BoxShape.circle),
                      child: SvgPicture.asset(ImageConst.icClose)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: size(30),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20)),
            child: Stack(
              children: [
                Container(
                  width: size(100),
                  height: size(100),
                  decoration: BoxDecoration(
                    color: Color(0xFF7FB3D3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(ImageConst.ic_edit),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size(12),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20)),
            child: CommonText(
              isLoading: dashboardController.isLoading.value,
              text: dashboardController.userUpdateRes.value?.data?.name ?? "",
              fontSize: size(24),
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
            ),
          ),
          SizedBox(
            height: size(8),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20)),
            child: CommonText(
              isLoading: dashboardController.isLoading.value,
              text: dashboardController.userUpdateRes.value?.data?.contact ?? "",
              fontSize: size(16),
              fontWeight: FontWeight.w500,
              color: ColorConst.textGrey,
            ),
          ),
          SizedBox(
            height: size(20),
          ),
          Divider(
            color: ColorConst.divider,
          ),
          SizedBox(
            height: size(20),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20)),
            child: CommonText(
              text: "PREFERENCES",
              fontSize: size(12),
              fontWeight: FontWeight.w500,
              color: ColorConst.textGrey,
            ),
          ),
          _menu(text: "Invite friends", onTap: () {

          },),
          Divider(
            color: ColorConst.divider,
          ),
          _menu(text: "Help & Support", onTap: () {

          },),
          Divider(
            color: ColorConst.divider,
          ),
          _menu(text: "Logout", onTap: () {
            dashboardController.logoutUser();
          }, isLogout : true),
        ],
      ),
    );
  }

  _menu({required String text, required Function() onTap, bool isLogout = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size(20), vertical: size(15)),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                text: text,
                fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
                fontSize: size(16),
                color: isLogout ? ColorConst.primary : ColorConst.black,
              ),
            ),
            SvgPicture.asset(ImageConst.icRight)
          ],
        ),
      ),
    );
  }
}
