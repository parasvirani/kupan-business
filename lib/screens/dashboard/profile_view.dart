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

  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'What is a Kupan?',
      'a': 'A Kupan is a digital coupon or offer that you create for your customers. Customers can browse and redeem Kupans through the Kupan app.',
    },
    {
      'q': 'How do I create a Kupan?',
      'a': 'Go to "My Kupans" from the bottom navigation, then tap the + button. Fill in the offer details, set daily limits, and publish your Kupan.',
    },
    {
      'q': 'How do customers redeem Kupans?',
      'a': 'Customers redeem Kupans by showing the redemption code at your outlet. You can verify redemptions through the Kupan Business app.',
    },
    {
      'q': 'Can I pause or cancel a Kupan?',
      'a': "Yes, you can pause or cancel any active Kupan from the \"My Kupans\" section. Paused Kupans won't be visible to customers.",
    },
    {
      'q': 'How do I manage my outlets?',
      'a': 'Navigate to "My Outlets" from the bottom navigation to add, edit, or remove outlet locations associated with your business.',
    },
  ];

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
      body: SingleChildScrollView(
        child: Column(
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
                      color: Colors.white.withValues(alpha: 0.8),
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
                            text: dashboardController
                                    .userUpdateRes.value?.data?.contact ??
                                "",
                            color: ColorConst.textGrey,
                            fontSize: size(14),
                            maxLines: 1,
                            fontWeight: FontWeight.w500,
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
            // FAQ section
            SizedBox(height: size(20)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: CommonText(
                text: "FAQ",
                fontSize: size(12),
                fontWeight: FontWeight.w500,
                color: ColorConst.textGrey,
              ),
            ),
            ...List.generate(_faqItems.length, (i) => _faqItem(i)),
            Divider(
              color: ColorConst.divider,
            ),
            _menu(
                text: "Logout",
                onTap: () {
                  dashboardController.logoutUser();
                },
                isLogout: true),
            SizedBox(height: size(20)),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(int index) {
    final item = _faqItems[index];
    final isExpanded = _expandedFaqIndex == index;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedFaqIndex = isExpanded ? null : index;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size(20), vertical: size(15)),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    text: item['q']!,
                    fontWeight: FontWeight.w500,
                    fontSize: size(16),
                    color: ColorConst.black,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(ImageConst.icRight),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            color: const Color(0xFFF9F9F9),
            padding: EdgeInsets.fromLTRB(
                size(20), size(4), size(20), size(16)),
            child: Text(
              item['a']!,
              style: TextStyle(
                fontSize: size(14),
                fontWeight: FontWeight.w400,
                color: ColorConst.textGrey,
                fontFamily: 'Urbanist',
                height: 1.5,
              ),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(color: ColorConst.divider),
      ],
    );
  }

  Widget _menu(
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
