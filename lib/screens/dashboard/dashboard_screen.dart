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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: Obx(
        ()=> IndexedStack(
          index: dashboardController.currentIndex.value,
          children: [
            HomeView(),
            AddKupanView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        ()=> BottomNavigationBar(
          backgroundColor: ColorConst.white,
          elevation: 5,
          type: BottomNavigationBarType.fixed,
          unselectedLabelStyle: TextStyle(
              fontSize: size(12),
              color: ColorConst.grey,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist'),
          selectedLabelStyle: TextStyle(
              fontSize: size(12),
              color: ColorConst.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist'),
          selectedItemColor: ColorConst.primary, // Default selected color (might be overridden by label style)
          unselectedItemColor: ColorConst.grey, // Default unselected color (might be overridden by label style)
          currentIndex: dashboardController.currentIndex.value, // Make sure currentIndex is bound here
          onTap: (value) {
            print('Tapped index: $value');
            dashboardController.currentIndex(value);
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                ImageConst.ic_home,
                color: dashboardController.currentIndex.value == 0 ? ColorConst.primary : ColorConst.grey,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                ImageConst.addCouple,
                color: dashboardController.currentIndex.value == 1 ? ColorConst.primary : ColorConst.grey,
              ),
              label: 'Add Kupan',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                    ImageConst.ic_profile,
                    color: dashboardController.currentIndex.value == 3 ? ColorConst.primary : ColorConst.grey,
                  ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}