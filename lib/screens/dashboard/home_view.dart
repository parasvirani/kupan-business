import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/my_outlets_controller.dart';
import 'package:kupan_business/screens/dashboard/add_kupan_view.dart';
import 'package:kupan_business/screens/dashboard/components/main_drawer.dart';
import 'package:kupan_business/screens/dashboard/redemptions_detail_screen.dart';

import '../../common_view/common_text.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../const/string_const.dart';
import '../../models/restaurant_deal.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'components/stats_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardController dashboardController = Get.find();
  final MyOutletsController myOutletsController = Get.put(MyOutletsController());

  @override
  void initState() {
    super.initState();
    // Fetch kupans with filters when page loads
    _loadKupans();
  }

  void _loadKupans() {
    // Get vendor ID from storage
    String vendorId = dashboardController.box.read(StringConst.USER_ID) ?? '';

    // Fetch all kupans for this vendor
    if (vendorId.isNotEmpty) {
      dashboardController.getKupanByVendor(
        vendorId: vendorId,
        limit: 10,
      );
    }
  }

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
                  Obx(
                    ()=> Expanded(
                      child: StatsCard(
                        count: myOutletsController.outletsList.length.toString(),
                        label: 'Total Outlets',
                        backgroundColor1: Color(0xFFFFFFFF),
                        backgroundColor2: Color(0xFFFFF4E8),
                      ),
                    ),
                  ),
                  SizedBox(width: size(12)),
                  Obx(
                    ()=> Expanded(
                      child: StatsCard(
                        count: dashboardController.kupanList.length.toString(),
                        label: 'Total Coupons',
                        backgroundColor1: Color(0xFFFFFFFF),
                        backgroundColor2: Color(0xFFEAEEFF),
                      ),
                    ),
                  ),
                  SizedBox(width: size(12)),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () {
                          Get.to(() => const RedemptionsDetailScreen());
                        },
                        child: StatsCard(
                          count: dashboardController.todayRedemptionCount.value.toString(),
                          label: 'Today Redemption',
                          backgroundColor1: Color(0xFFFFFFFF),
                          backgroundColor2: Color(0xFFFFEAF9),
                        ),
                      ),
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

              // Showing Total Kupans from API
              Obx(
                () => dashboardController.kupanList.isEmpty
                    ? Container(
                        height: size(150),
                        alignment: Alignment.center,
                        child: CommonText(
                          text: 'No coupons available',
                          color: ColorConst.grey,
                          fontSize: size(14),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: dashboardController.kupanList.length,
                        itemBuilder: (context, index) {
                          final coupon = dashboardController.kupanList[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: size(12)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(size(12)),
                              border:
                                  Border.all(color: Colors.grey.shade200, width: 1),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(size(12)),
                                  child: Row(
                                children: [
                                  // Image
                                  if (coupon.kupanImages != null &&
                                      coupon.kupanImages!.isNotEmpty)
                                    Container(
                                      width: size(80),
                                      height: size(80),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(size(8)),
                                        color: Colors.grey[200],
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.network(
                                        coupon.kupanImages![0],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                              Icons.image_not_supported);
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: size(80),
                                      height: size(80),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(size(8)),
                                        color: Colors.grey[300],
                                      ),
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  SizedBox(width: size(12)),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coupon.title ?? 'Coupon',
                                          style: TextStyle(
                                            fontSize: size(13),
                                            fontWeight: FontWeight.w600,
                                            color: ColorConst.dark,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: size(4)),
                                        Text(
                                          coupon.getOutletName() ?? 'Outlet',
                                          style: TextStyle(
                                            fontSize: size(11),
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: size(6)),
                                        if (coupon.kupanDays != null &&
                                            coupon.kupanDays!.isNotEmpty)
                                          Wrap(
                                            spacing: size(4),
                                            children: coupon.kupanDays!
                                                .take(2)
                                                .map((day) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: size(6),
                                                  vertical: size(2),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size(3)),
                                                ),
                                                child: Text(
                                                  day,
                                                  style: TextStyle(
                                                    fontSize: size(9),
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                                ),
                                // Edit Button
                                Positioned(
                                  top: size(8),
                                  right: size(8),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Get.to(
                                        () => AddKupanView(kupanToEdit: coupon),
                                      );
                                      if (result == true) {
                                        // Refresh the kupans list
                                        _loadKupans();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(size(6)),
                                      decoration: BoxDecoration(
                                        color: ColorConst.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: size(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildRangeButton({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size(12), horizontal: size(8)),
        decoration: BoxDecoration(
          color: isSelected ? ColorConst.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(size(8)),
          border: Border.all(
            color: isSelected ? ColorConst.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : ColorConst.dark,
            fontWeight: FontWeight.w600,
            fontSize: size(12),
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }
}
