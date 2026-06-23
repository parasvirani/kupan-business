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
    final vendorId = dashboardController.box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      dashboardController.getVendorKupans(vendorId: vendorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      drawer: Drawer(
        child: MainDrawer(
          onTap: () => _scaffoldKey.currentState?.closeDrawer(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadKupans(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size(20)),
              _buildStatsGrid(),
              SizedBox(height: size(24)),
              _buildRecentCouponsHeader(),
              SizedBox(height: size(14)),
              _buildCouponsGrid(),
              SizedBox(height: size(24)),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () => Get.toNamed(AppRoutes.notification),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size(16)),
      child: Obx(
        () => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: size(12),
          mainAxisSpacing: size(12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _statCard(
              count: myOutletsController.outletsList.length.toString(),
              label: 'Total Outlets',
            ),
            _statCard(
              count: dashboardController.kupanList.length.toString(),
              label: 'Total Coupons',
            ),
            _statCard(
              count: (dashboardController.allTimeRedemptions.value?.data.length ?? 0)
                  .toString(),
              label: 'Visited Coupon',
            ),
            GestureDetector(
              onTap: () => Get.to(() => const RedemptionsDetailScreen()),
              child: _statCard(
                count: dashboardController.allTimeCount.value.toString(),
                label: 'Total Redemption',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required String count, required String label}) {
    return Row(
      children: [
        Container(
            width: 2,
           
             decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(size(10)),
            ),
          ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: size(12), vertical: size(14)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size(10)),
                bottomRight: Radius.circular(size(10)),
              ),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  ImageConst.icKupan,
                  width: size(28),
                  height: size(28),
                  colorFilter:
                      ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
                ),
                SizedBox(width: size(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        count,
                        style: TextStyle(
                          fontSize: size(22),
                          fontWeight: FontWeight.w800,
                          color: ColorConst.dark,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        label,
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCouponsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size(16)),
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
                color: Color(0xFF919191),
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size(16)),
      child: Obx(
        () {
          if (dashboardController.isLoadingGetKupan.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dashboardController.kupanList.isEmpty) {
            return Container(
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
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: size(12),
              mainAxisSpacing: size(12),
              childAspectRatio: 0.72,
            ),
            itemCount: dashboardController.kupanList.length,
            itemBuilder: (context, index) =>
                _couponCard(dashboardController.kupanList[index]),
          );
        },
      ),
    );
  }

  Widget _couponCard(KupanData coupon) {
    final imageUrl = (coupon.kupanImages?.isNotEmpty == true)
        ? coupon.kupanImages![0]
        : null;
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
            // Image section
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size(12)),
                  
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey[400]),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[400]),
                          ),
                  ),
                  // Outlet name overlay at bottom
                  if (outletName != null && outletName.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 60,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: size(8), vertical: size(4)),
                        decoration: BoxDecoration(
                         color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size(12)),
                            topRight: Radius.circular(size(12),)
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
                  // Star rating badge
                  Positioned(
                    top: size(8),
                    right: size(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size(6), vertical: size(3)),
                      decoration: BoxDecoration(
                        color: Color(0XFF919191).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(size(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            ImageConst.icRate,
                            width: size(12),
                            height: size(12),
                          ),
                          SizedBox(width: size(2)),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: size(11),
                              fontWeight: FontWeight.w700,
                              color: ColorConst.white,
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
            // Text section
            Expanded(
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
