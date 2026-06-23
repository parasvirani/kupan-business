import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/my_outlets_controller.dart';
import '../../models/user_businesses_res.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'add_outlet_screen.dart';

class MyOutletsScreen extends StatefulWidget {
  final dynamic args;
  const MyOutletsScreen({super.key, this.args});

  @override
  State<MyOutletsScreen> createState() => _MyOutletsScreenState();
}

class _MyOutletsScreenState extends State<MyOutletsScreen> {
  final MyOutletsController controller = Get.put(MyOutletsController());
  final DashboardController dashboardController = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.args != null && widget.args['initialIndex'] != null) {
      Future.delayed(Duration.zero, () {
        Get.to(() => const AddOutletScreen());
      });
    }
  }

  void _navigateToEditOutlet(SellerBusiness outlet) {
    Get.to(() => AddOutletScreen(isEditMode: true, outletData: outlet));
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String businessId, String outletName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Obx(
        () => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(size(24)),
            child: controller.isDeleting.value
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ColorConst.primary),
                      SizedBox(height: size(16)),
                      Text('Deleting outlet...',
                          style: TextStyle(
                              fontSize: size(16),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist')),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_rounded,
                            color: Colors.red, size: 30),
                      ),
                      SizedBox(height: size(16)),
                      Text('Delete Outlet?',
                          style: TextStyle(
                              fontSize: size(18),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist')),
                      SizedBox(height: size(10)),
                      Text(
                        'Are you sure you want to delete "$outletName"?\nThis action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: size(13),
                            color: ColorConst.grey,
                            fontFamily: 'Urbanist',
                            height: 1.5),
                      ),
                      SizedBox(height: size(20)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: size(11)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      color: ColorConst.dark,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: size(12)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.deleteBusiness(businessId);
                                Navigator.of(ctx).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    vertical: size(11)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Delete',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddOutletScreen()),
        backgroundColor: const Color(0xFF919191),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerGrid();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildError();
        }

        if (controller.outletsList.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          onRefresh: () => controller.getOutlets(),
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(
                size(16), size(16), size(16), size(100)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: size(12),
              mainAxisSpacing: size(12),
              childAspectRatio: 0.79,
            ),
            itemCount: controller.outletsList.length,
            itemBuilder: (context, index) =>
                _outletCard(controller.outletsList[index]),
          ),
        );
      }),
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

  Widget _outletCard(SellerBusiness outlet) {
    final imageUrl = outlet.outletImages?.isNotEmpty == true
        ? outlet.outletImages![0]
        : null;
    final locationLabel =
        outlet.location?.address ?? outlet.location?.city ?? '';

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.outletDetails, arguments: outlet),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size(12)),
          border: Border.all(color: const Color(0x1A1A1A1A)),
        ),
        padding: EdgeInsets.all(size(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size(8)),
                    child: SizedBox.expand(
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholderImage(),
                            )
                          : _placeholderImage(),
                    ),
                  ),
                  // Delete + edit overlay buttons
                  Positioned(
                    top: size(7),
                    right: size(8),
                    child: Column(
                      children: [
                        _overlayActionButton(
                          icon: ImageConst.icDelete2,
                          onTap: () => _showDeleteConfirmationDialog(
                            context,
                            outlet.id ?? '',
                            outlet.outletName ?? 'Outlet',
                          ),
                        ),
                        SizedBox(height: size(8)),
                        _overlayActionButton(
                          icon: ImageConst.icEdit2,
                          onTap: () => _navigateToEditOutlet(outlet),
                        ),
                      ],
                    ),
                  ),
                  // Location label at bottom-left of image
                  if (locationLabel.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        height: size(20),
                        constraints: BoxConstraints(maxWidth: size(108)),
                        padding: EdgeInsets.symmetric(
                            horizontal: size(8), vertical: size(4)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size(8)),
                            topRight: Radius.circular(size(8)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          locationLabel,
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
                    ),
                ],
              ),
            ),
            SizedBox(height: size(6)),
            Text(
              outlet.outletName ?? '',
              style: TextStyle(
                fontSize: size(12),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                fontFamily: 'Urbanist',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Hurry! expires in 2 days',
              style: TextStyle(
                fontSize: size(11),
                color: const Color(0xFF919191),
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
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
      child: Icon(Icons.store, color: ColorConst.primary, size: size(40)),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(size(16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: size(12),
        mainAxisSpacing: size(12),
        childAspectRatio: 0.79,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(size(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Colors.red.withValues(alpha: 0.5)),
          SizedBox(height: size(16)),
          Text('Failed to load outlets',
              style: TextStyle(
                  fontSize: size(16),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist')),
          SizedBox(height: size(8)),
          Text(controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: size(13),
                  color: ColorConst.grey,
                  fontFamily: 'Urbanist')),
          SizedBox(height: size(20)),
          ElevatedButton(
            onPressed: controller.getOutlets,
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primary),
            child: const Text('Retry',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined,
              size: 72,
              color: ColorConst.grey.withValues(alpha: 0.4)),
          SizedBox(height: size(16)),
          Text('No Outlets Yet',
              style: TextStyle(
                  fontSize: size(18),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist')),
          SizedBox(height: size(8)),
          Text(
            'Tap + to add your first outlet.',
            style: TextStyle(
                fontSize: size(13),
                color: ColorConst.grey,
                fontFamily: 'Urbanist'),
          ),
          SizedBox(height: size(32)),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddOutletScreen()),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Outlet',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primary,
              padding: EdgeInsets.symmetric(
                  horizontal: size(32), vertical: size(12)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
