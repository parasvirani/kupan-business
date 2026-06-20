import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/my_outlets_controller.dart';
import 'package:kupan_business/models/kupans_list_res.dart';
import 'package:kupan_business/screens/dashboard/add_kupan_view.dart';
import 'package:kupan_business/screens/dashboard/components/main_drawer.dart';
import 'package:kupan_business/screens/dashboard/redemptions_detail_screen.dart';

import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../const/string_const.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';

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
    _loadKupans();
  }

  void _loadKupans() {
    String vendorId = dashboardController.box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      dashboardController.getKupanByVendor(vendorId: vendorId, limit: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(size(14)),
          child: SvgPicture.asset(
            ImageConst.ic_location2,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        title: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT ADDRESS',
                style: TextStyle(
                  fontSize: size(11),
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  fontFamily: 'Urbanist',
                ),
              ),
              Obx(
                () => Text(
                  dashboardController.currentAddress.value.isEmpty
                      ? 'Loading...'
                      : dashboardController.currentAddress.value,
                  style: TextStyle(
                    fontSize: size(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: size(8)),
            child: IconButton(
              icon: SvgPicture.asset(
                ImageConst.notification2,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.notification);
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: MainDrawer(
          onTap: () => _scaffoldKey.currentState?.closeDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Outlets hero count
            Padding(
              padding: EdgeInsets.fromLTRB(size(20), size(28), size(20), size(4)),
              child: Center(
                child: Column(
                  children: [
                    Obx(
                      () => Text(
                        myOutletsController.outletsList.length.toString(),
                        style: TextStyle(
                          fontSize: size(52),
                          fontWeight: FontWeight.w800,
                          color: ColorConst.dark,
                          fontFamily: 'Urbanist',
                          height: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(height: size(4)),
                    Text(
                      'Total Outlets',
                      style: TextStyle(
                        fontSize: size(14),
                        color: ColorConst.grey,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size(20)),

            // 3 Stat cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildStatCard(
                        count: dashboardController.kupanList.length.toString(),
                        label: 'Total\nCoupons',
                      ),
                    ),
                  ),
                  SizedBox(width: size(10)),
                  Expanded(
                    child: Obx(
                      () => _buildStatCard(
                        count: (dashboardController.allTimeRedemptions.value?.data.length ?? 0).toString(),
                        label: 'Visited\nCoupon',
                      ),
                    ),
                  ),
                  SizedBox(width: size(10)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.to(() => const RedemptionsDetailScreen()),
                      child: Obx(
                        () => _buildStatCard(
                          count: dashboardController.allTimeCount.value.toString(),
                          label: 'Total\nRedemption',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size(28)),

            // Recent Coupons header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Coupons',
                    style: TextStyle(
                      fontSize: size(17),
                      fontWeight: FontWeight.w700,
                      color: ColorConst.dark,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View more',
                      style: TextStyle(
                        fontSize: size(13),
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primary,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size(14)),

            // 2-column grid of coupon cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: Obx(
                () => dashboardController.kupanList.isEmpty
                    ? Container(
                        height: size(150),
                        alignment: Alignment.center,
                        child: Text(
                          'No coupons available',
                          style: TextStyle(
                            color: ColorConst.grey,
                            fontSize: size(14),
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: size(12),
                          mainAxisSpacing: size(12),
                          childAspectRatio: 0.72,
                        ),
                        itemCount: dashboardController.kupanList.length,
                        itemBuilder: (context, index) {
                          return _buildCouponCard(dashboardController.kupanList[index]);
                        },
                      ),
              ),
            ),
            SizedBox(height: size(24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String count, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: size(16), horizontal: size(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size(10)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            color: Colors.grey[400],
            size: size(26),
          ),
          SizedBox(height: size(8)),
          Text(
            count,
            style: TextStyle(
              fontSize: size(22),
              fontWeight: FontWeight.w700,
              color: ColorConst.dark,
              fontFamily: 'Urbanist',
            ),
          ),
          SizedBox(height: size(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size(11),
              color: ColorConst.grey,
              fontFamily: 'Urbanist',
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(KupanData coupon) {
    final imageUrl = (coupon.kupanImages?.isNotEmpty == true) ? coupon.kupanImages![0] : null;
    final outletName = coupon.getOutletName();

    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => AddKupanView(kupanToEdit: coupon));
        if (result == true) _loadKupans();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size(12)),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlays
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size(12)),
                      topRight: Radius.circular(size(12)),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(size(12)),
                                topRight: Radius.circular(size(12)),
                              ),
                            ),
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          ),
                  ),
                  // Bottom gradient + outlet name
                  if (outletName != null && outletName.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(size(8), size(16), size(8), size(6)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                        child: Text(
                          outletName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size(11),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  // Star rating badge top-right
                  Positioned(
                    top: size(8),
                    right: size(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: size(6), vertical: size(3)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(size(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: size(12)),
                          SizedBox(width: size(2)),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: size(11),
                              fontWeight: FontWeight.w700,
                              color: ColorConst.dark,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text section below image
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(size(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon.title ?? 'Coupon',
                      style: TextStyle(
                        fontSize: size(12),
                        fontWeight: FontWeight.w700,
                        color: ColorConst.dark,
                        fontFamily: 'Urbanist',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size(4)),
                    Text(
                      coupon.kupanDays != null && coupon.kupanDays!.isNotEmpty
                          ? 'Hurry! expires in 2 days'
                          : 'Limited time offer',
                      style: TextStyle(
                        fontSize: size(11),
                        color: ColorConst.grey,
                        fontFamily: 'Urbanist',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
