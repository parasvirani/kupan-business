import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/my_outlets_controller.dart';
import 'package:kupan_business/models/kupans_list_res.dart';
import 'package:kupan_business/screens/dashboard/add_kupan_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../const/string_const.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';

class MyKupanView extends StatefulWidget {
  const MyKupanView({super.key});

  @override
  State<MyKupanView> createState() => _MyKupanViewState();
}

class _MyKupanViewState extends State<MyKupanView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardController dashboardController = Get.find();
  final MyOutletsController myOutletsController = Get.find();

  // Filter tabs: display label → businessType value (null = All)
  final List<Map<String, String?>> _filters = [
    {'label': 'All', 'value': null},
    {'label': 'Restaurant', 'value': 'restaurant'},
    {'label': 'Saloon', 'value': 'cafe'},
    {'label': 'Hospitality', 'value': 'hotel'},
  ];

  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final vendorId =
        dashboardController.box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      await dashboardController.getVendorKupans(vendorId: vendorId);
      await dashboardController.fetchTodayRedemptionsByKupan(
          vendorId: vendorId);
    }
  }

  List<KupanData> _filteredKupans() {
    final selectedValue = _filters[_selectedFilterIndex]['value'];
    if (selectedValue == null) return dashboardController.kupanList;

    return dashboardController.kupanList.where((kupan) {
      final directType = kupan.getBusinessType();
      if (directType != null) return directType == selectedValue;

      final outlet = myOutletsController.outletsList.firstWhereOrNull(
        (o) => o.id == kupan.businessId,
      );
      return outlet?.businessType == selectedValue;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => AddKupanView());
          if (result != null) _refresh();
        },
        backgroundColor: const Color(0xFF919191),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: Obx(() {
                if (dashboardController.isLoadingGetKupan.value) {
                  return _buildShimmer();
                }

                final kupans = _filteredKupans();

                if (kupans.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: size(80)),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.confirmation_number_outlined,
                                size: size(60), color: Colors.grey[300]),
                            SizedBox(height: size(16)),
                            Text(
                              'No coupons found',
                              style: TextStyle(
                                fontSize: size(16),
                                fontWeight: FontWeight.w600,
                                color: ColorConst.dark,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            SizedBox(height: size(8)),
                            Text(
                              'Tap + to create your first coupon',
                              style: TextStyle(
                                fontSize: size(13),
                                color: ColorConst.grey,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      size(16), size(12), size(16), size(100)),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: kupans.length,
                  separatorBuilder: (_, __) => SizedBox(height: size(12)),
                  itemBuilder: (context, index) =>
                      _kupanCard(kupans[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: size(48),
      leading: Padding(
        padding: EdgeInsets.all(size(14)),
        child: SvgPicture.asset(
          ImageConst.ic_location2,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENT ADDRESS',
              style: TextStyle(
                fontSize: size(11),
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.055,
                fontFamily: 'Urbanist',
              ),
            ),
            Text(
              dashboardController.currentAddress.value.isEmpty
                  ? 'Loading...'
                  : dashboardController.currentAddress.value,
              style: TextStyle(
                fontSize: size(14),
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.07,
                fontFamily: 'Urbanist',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
          horizontal: size(16), vertical: size(12)),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: EdgeInsets.only(
                right: index < _filters.length - 1 ? size(12) : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: size(32),
                padding: EdgeInsets.symmetric(
                    horizontal: size(14), vertical: size(8)),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(size(8)),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0x33919191)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _filters[index]['label']!,
                  style: TextStyle(
                    fontSize: size(12),
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _kupanCard(KupanData kupan) {
    final imageUrl = kupan.kupanImages?.isNotEmpty == true
        ? kupan.kupanImages![0]
        : null;

    final address =
        kupan.getOutletAddress() ?? _getAddressFromOutlets(kupan.businessId);
    final validDays = _formatValidDays(kupan.kupanDays);
    final todayCount =
        dashboardController.todayRedemptionsByKupan[kupan.id] ?? 0;
    final dailyLimit = kupan.dailyLimit ?? 10;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size(16)),
        border: Border.all(color: const Color(0x1A1A1A1A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(size(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area with overlays
          SizedBox(
            height: size(149.5),
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Main image
                ClipRRect(
                  borderRadius: BorderRadius.circular(size(8)),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                // Delete + edit overlay buttons
                Positioned(
                  top: size(7),
                  right: size(9),
                  child: Column(
                    children: [
                      _overlayActionButton(
                        icon: ImageConst.icDelete2,
                        onTap: () => _confirmDelete(kupan),
                      ),
                      SizedBox(height: size(8)),
                      _overlayActionButton(
                        icon: ImageConst.icEdit2,
                        onTap: () async {
                          final result = await Get.to(
                              () => AddKupanView(kupanToEdit: kupan));
                          if (result == true) _refresh();
                        },
                      ),
                    ],
                  ),
                ),
                // Location strip at bottom of image
                if (address.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size(8)),
                        bottomRight: Radius.circular(size(8)),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: Container(
                          color: const Color(0x80000000),
                          padding: EdgeInsets.symmetric(
                              horizontal: size(12), vertical: size(6)),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                ImageConst.ic_location2,
                                width: size(18),
                                height: size(18),
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                              SizedBox(width: size(4)),
                              Expanded(
                                child: Text(
                                  address,
                                  style: TextStyle(
                                    fontSize: size(11),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Urbanist',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: size(10)),
          // Title row + daily limit
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  kupan.title ?? 'Coupon',
                  style: TextStyle(
                    fontSize: size(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: 'Urbanist',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: size(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Daily limit',
                    style: TextStyle(
                      fontSize: size(11),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF919191),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  SizedBox(width: size(4)),
                  Container(
                    height: size(24),
                    padding: EdgeInsets.symmetric(
                        horizontal: size(12), vertical: size(4)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$todayCount/$dailyLimit',
                      style: TextStyle(
                        fontSize: size(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size(4)),
          // Valid days
          Text(
            validDays,
            style: TextStyle(
              fontSize: size(11),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              fontFamily: 'Urbanist',
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            width: size(32),
            height: size(32),
            decoration: const BoxDecoration(
              color: Color(0xCC919191),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: size(18),
                height: size(18),
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size(8)),
      ),
      child: Icon(Icons.image_not_supported,
          color: Colors.grey[400], size: size(40)),
    );
  }

  void _confirmDelete(KupanData kupan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size(16))),
        title: Text(
          'Delete Coupon?',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: size(18),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${kupan.title}"? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: size(14),
            color: ColorConst.grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Urbanist', color: ColorConst.dark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (kupan.id != null) {
                dashboardController.deleteKupan(kupan.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size(8))),
            ),
            child: const Text('Delete',
                style: TextStyle(
                    fontFamily: 'Urbanist', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getAddressFromOutlets(String? businessId) {
    if (businessId == null) return '';
    final outlet = myOutletsController.outletsList.firstWhereOrNull(
      (o) => o.id == businessId,
    );
    if (outlet == null) return '';
    final loc = outlet.location;
    if (loc == null) return '';
    final parts = <String>[];
    if (loc.address != null && loc.address!.isNotEmpty) {
      parts.add(loc.address!);
    }
    if (loc.city != null && loc.city!.isNotEmpty) parts.add(loc.city!);
    return parts.join(', ');
  }

  String _formatValidDays(List<String>? days) {
    if (days == null || days.isEmpty) return 'Valid: All days';
    if (days.length == 7) return 'Valid: All days';
    final abbr = days.map((d) => d.substring(0, 3)).join('–');
    return 'Valid: $abbr';
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.all(size(16)),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: size(12)),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: size(240),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(size(16)),
          ),
        ),
      ),
    );
  }
}
