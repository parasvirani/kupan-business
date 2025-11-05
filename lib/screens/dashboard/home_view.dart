import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/screens/dashboard/components/main_drawer.dart';
import 'package:shimmer/shimmer.dart';

import '../../common_view/common_text.dart';
import '../../common_view/common_textfield.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../models/restaurant_deal.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'components/restaurant_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardController dashboardController = Get.find();

  final List<RestaurantDeal> deals = [
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: ImageConst.image1,
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
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
              text: 'Current address',
              fontSize: size(12),
              color: ColorConst.grey,
            ),
            Obx(
              () => CommonText(
                isLoading: dashboardController.isLoading.value,
                text: dashboardController.currentAddress.value,
                fontSize: size(16),
                color: ColorConst.dark,
                fontWeight: FontWeight.w600,
              ),
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
        child: Padding(
          padding: EdgeInsets.all(size(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextfield(
                hintText: 'Search for "restaurant"',
                readOnly: true,
                onTap: () {
                  Get.toNamed(AppRoutes.search);
                },
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size(10)),
                  child: SvgPicture.asset(ImageConst.ic_search),
                ),
                controller: TextEditingController(),
              ),
              SizedBox(height: size(16)),
              Obx(
                () => dashboardController.isLoadingGetKupan.value
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: deals.length,
                          itemBuilder: (context, index) {
                            return Container();
                          },
                          separatorBuilder: (context, index) => SizedBox(
                            height: size(16),
                          ),
                        ),
                      )
                    : dashboardController.errorMessageGetKupan.value.isNotEmpty
                        ? Container(
                            height: Get.width,
                            alignment: Alignment.center,
                            child: CommonText(
                              text: dashboardController
                                  .errorMessageGetKupan.value,
                              color: Colors.red,
                              fontSize: size(14),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: dashboardController.kupanList.length,
                            itemBuilder: (context, index) {
                              return RestaurantCard(
                                  deal: dashboardController.kupanList[index]);
                            },
                            separatorBuilder: (context, index) => SizedBox(
                              height: size(16),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
