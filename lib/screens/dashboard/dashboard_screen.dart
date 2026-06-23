import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/screens/dashboard/my_kupan_view.dart';
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

  @override
  void initState() {
    super.initState();
    if (args != null && args['initialIndex'] != null) {
      setState(() {
        currentIndex = args['initialIndex'] as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeView(),
          MyOutletsScreen(args: args),
          MyKupanView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final List<Map<String, dynamic>> items = [
      {'icon': ImageConst.bnvHome, 'label': 'HOME'},
      {'icon': ImageConst.bnvMyOutlet, 'label': 'MY OUTLETS'},
      {'icon': ImageConst.bnvMyKupan, 'label': 'MY KUPAN'},
      {'icon': ImageConst.bnvProfile, 'label': 'PROFILE'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorConst.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (currentIndex != index) {
                      setState(() => currentIndex = index);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: size(10),
                        vertical: size(7),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? ColorConst.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(size(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            items[index]['icon'] as String,
                            width: size(22),
                            height: size(22),
                            colorFilter: ColorFilter.mode(
                              isSelected ? Colors.white : ColorConst.grey,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[index]['label'] as String,
                            style: TextStyle(
                              fontSize: size(9),
                              color: isSelected ? Colors.white : ColorConst.grey,
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
}
