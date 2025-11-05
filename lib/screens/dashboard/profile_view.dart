import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../common_view/common_text.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'components/main_drawer.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorConst.white,
      appBar: AppBar(
        backgroundColor: ColorConst.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: SvgPicture.asset(ImageConst.ic_menu)),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonText(
              text: 'Profile',
              fontSize: size(20),
              color: ColorConst.dark,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(ImageConst.ic_notification),
            onPressed: () {
              Get.toNamed(AppRoutes.notification);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: MainDrawer(
          onTap: () {
            _scaffoldKey.currentState?.closeDrawer();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20), vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
                  width: size(80),
                  height: size(80),
                  decoration: BoxDecoration(
                    color: Color(0xFF7FB3D3),
                    shape: BoxShape.circle,
                  ),
                  child: (dashboardController.userUpdateRes.value?.data?.profilePic ?? "").isNotEmpty ? ClipOval(child: Image.network(dashboardController.userUpdateRes.value?.data?.profilePic ?? "")) : Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(
                  width: size(16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => CommonText(
                          isLoading: dashboardController.isLoading.value,
                          text: dashboardController
                                  .userUpdateRes.value?.data?.name ??
                              "",
                          color: ColorConst.black,
                          fontSize: size(18),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: size(4),
                      ),
                      Obx(
                        () => CommonText(
                          isLoading: dashboardController.isLoading.value,
                          text: dashboardController.currentAddress.value,
                          color: ColorConst.textGrey,
                          fontSize: size(14),
                          maxLines: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: size(4),
                      ),
                      Obx(
                        ()=> Row(
                          children: [
                            dashboardController.isLoading.value
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      padding: EdgeInsets.all(size(4)),
                                      decoration: BoxDecoration(
                                          color: ColorConst.primary,
                                          borderRadius:
                                              BorderRadius.circular(size(4))),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                              ImageConst.icRestaurant),
                                          SizedBox(
                                            width: size(4),
                                          ),
                                          CommonText(
                                            isLoading: dashboardController
                                                .isLoading.value,
                                            text: dashboardController
                                                    .userUpdateRes
                                                    .value
                                                    ?.data
                                                    ?.sellerInfo
                                                    ?.businessType
                                                    ?.toUpperCase() ??
                                                "",
                                            color: ColorConst.white,
                                            fontSize: size(10),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(size(4)),
                                    decoration: BoxDecoration(
                                        color: ColorConst.primary,
                                        borderRadius:
                                            BorderRadius.circular(size(4))),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(ImageConst.icRestaurant),
                                        SizedBox(
                                          width: size(4),
                                        ),
                                        CommonText(
                                          isLoading:
                                              dashboardController.isLoading.value,
                                          text: dashboardController
                                                  .userUpdateRes
                                                  .value
                                                  ?.data
                                                  ?.sellerInfo
                                                  ?.businessType
                                                  ?.toUpperCase() ??
                                              "",
                                          color: ColorConst.white,
                                          fontSize: size(10),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size(16),
                ),
                Padding(
                  padding: EdgeInsets.only(right: size(12), bottom: size(12)),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.details,
                          arguments: {"isEdit": true});
                    },
                    child: SvgPicture.asset(
                      ImageConst.ic_edit,
                    ),
                  ),
                ),
              ],
            ),
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
          _menu(
            text: "Invite friends",
            onTap: () {},
          ),
          Divider(
            color: ColorConst.divider,
          ),
          _menu(
            text: "Help & Support",
            onTap: () {},
          ),
          Divider(
            color: ColorConst.divider,
          ),
          _menu(
            text: "Terms & Condition",
            onTap: () {},
          ),
          Divider(
            color: ColorConst.divider,
          ),
          _menu(
              text: "Logout",
              onTap: () {
                dashboardController.logoutUser();
              },
              isLogout: true),
        ],
      ),
    );
  }

  _menu(
      {required String text,
      required Function() onTap,
      bool isLogout = false}) {
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
