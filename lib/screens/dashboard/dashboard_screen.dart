import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/screens/dashboard/add_kupan_view.dart';
import 'package:kupan_business/screens/dashboard/profile_view.dart';

import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/utils.dart';
import 'home_view.dart';
import 'my_outlets_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardController dashboardController = Get.put(DashboardController());
  var args = Get.arguments;
 int currentIndex = 0;
  int previousIndex = 0;

  @override
  void initState() {
    super.initState();
    if (args != null && args['initialIndex'] != null) {
      dashboardController.currentIndex(args['initialIndex']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: Obx(
        () => IndexedStack(
          index: currentIndex,
          children: [
            HomeView(),
            MyOutletsScreen(args: args),
            AddKupanView(),
            ProfileView(),
          ],
        ),
      ),
       bottomNavigationBar: _buildBottomNavBar(),
      );
  }
Widget _buildBottomNavBar() {
    final List<Map<String, dynamic>> items = [
      {'icon': ImageConst.ic_home, 'label': 'COUPON'},
      {'icon': ImageConst.ic_category, 'label': 'CATEGORY'},
      {'icon': ImageConst.ic_hot_deal, 'label': 'HOT DEAL'},
      {'icon': ImageConst.ic_profile, 'label': 'PROFILE'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorConst.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (currentIndex != index) {
                      setState(() {
                        previousIndex = currentIndex;
                        currentIndex = index;
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConst.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border(
                            bottom: BorderSide(
                                color: ColorConst.textSubColor,
                                width: size(2)))
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            items[index]['icon'],
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              isSelected ? Colors.white : ColorConst.grey,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[index]['label'],
                            style: TextStyle(
                              fontSize: size(11),
                              color:
                              isSelected ? Colors.white : ColorConst.grey,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
  Widget _navItem(int index, String iconPath, String label) {
    final isSelected = dashboardController.currentIndex.value == index;
    final color = isSelected ? ColorConst.primary : ColorConst.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () => dashboardController.currentIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size(24),
              height: size(24),
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: size(5)),
            Text(
              label,
              style: TextStyle(
                fontSize: size(10),
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Urbanist',
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
