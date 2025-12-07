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
import 'components/action_button.dart';
import 'components/recent_coupon_card.dart';
import 'components/stats_card.dart';

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

              // Statistics Section
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      count: dashboardController.outletsList.length.toString(),
                      label: 'Total Outlets',
                      backgroundColor1: Color(0xFFFFFFFF),
                      backgroundColor2: Color(0xFFFFF4E8),
                    ),
                  ),
                  SizedBox(width: size(12)),
                  Expanded(
                    child: StatsCard(
                      count: dashboardController.kupanList.length.toString(),
                      label: 'Total Coupons',
                      backgroundColor1: Color(0xFFFFFFFF),
                      backgroundColor2: Color(0xFFEAEEFF),
                    ),
                  ),
                  SizedBox(width: size(12)),
                  Expanded(
                    child: StatsCard(
                      count: '24',
                      label: 'Today Redemption',
                      backgroundColor1: Color(0xFFFFFFFF),
                      backgroundColor2: Color(0xFFFFEAF9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size(20)),

              // Recent Coupons Section
              CommonText(
                text: 'Recent Coupons',
                fontSize: size(16),
                color: ColorConst.dark,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: size(12)),

              // Recent Coupons Grid
              Obx(
                () => dashboardController.isLoadingGetKupan.value
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: size(12),
                            mainAxisSpacing: size(12),
                            childAspectRatio: 0.75,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.circular(size(8)),
                              ),
                            );
                          },
                        ),
                      )
                    : dashboardController
                            .errorMessageGetKupan.value.isNotEmpty
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
                        : dashboardController.kupanList.isEmpty
                            ? Container(
                                height: size(200),
                                alignment: Alignment.center,
                                child: CommonText(
                                  text: 'No coupons available',
                                  color: ColorConst.grey,
                                  fontSize: size(14),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: size(12),
                                  mainAxisSpacing: size(12),
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: dashboardController
                                    .kupanList.length,
                                itemBuilder: (context, index) {
                                  final coupon =
                                      dashboardController.kupanList[index];
                                  return RecentCouponCard(
                                    imageUrl: coupon.kupanImages!.isNotEmpty
                                        ? coupon.kupanImages![0]
                                        : '',
                                    title: coupon.title ?? 'Coupon',
                                    subtitle: 'Limited time deals',
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
