import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/models/redemptions_res.dart';
import 'package:kupan_business/screens/dashboard/add_kupan_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../common_view/common_text.dart';
import '../../const/color_const.dart';
import '../../const/string_const.dart';
import '../../utils/utils.dart';

class RedemptionsDetailScreen extends StatefulWidget {
  const RedemptionsDetailScreen({Key? key}) : super(key: key);

  @override
  State<RedemptionsDetailScreen> createState() =>
      _RedemptionsDetailScreenState();
}

class _RedemptionsDetailScreenState extends State<RedemptionsDetailScreen> {
  late DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.find<DashboardController>();
  }

  Future<void> _refresh() async {
    final vendorId = dashboardController.box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      await dashboardController.fetchAllRedemptionRanges(vendorId: vendorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      appBar: AppBar(
        backgroundColor: ColorConst.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorConst.dark),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: CommonText(
          text: 'Redemptions',
          fontSize: size(18),
          color: ColorConst.dark,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
          padding: EdgeInsets.all(size(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Redemption Count Card
              Obx(
                () => Container(
                  padding: EdgeInsets.all(size(16)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorConst.primary.withOpacity(0.1),
                        ColorConst.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(size(12)),
                    border: Border.all(
                      color: ColorConst.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: size(60),
                        height: size(60),
                        decoration: BoxDecoration(
                          color: ColorConst.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dashboardController.todayRedemptionCount.value
                                .toString(),
                            style: TextStyle(
                              fontSize: size(24),
                              fontWeight: FontWeight.bold,
                              color: ColorConst.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: 'Total Redemptions',
                              fontSize: size(12),
                              color: ColorConst.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(height: size(4)),
                            CommonText(
                              text:
                                  '${dashboardController.selectedRedemptionRange.value.toUpperCase()} PERIOD',
                              fontSize: size(13),
                              color: ColorConst.dark,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size(20)),

              // Range Filter Buttons
              CommonText(
                text: 'Filter by Range',
                fontSize: size(14),
                color: ColorConst.dark,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: size(12)),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildRangeButton(
                        label: 'Weekly',
                        value: 'weekly',
                        isSelected:
                            dashboardController.selectedRedemptionRange.value ==
                                'weekly',
                        onTap: () =>
                            dashboardController.setRedemptionRange('weekly'),
                      ),
                    ),
                    SizedBox(width: size(12)),
                    Expanded(
                      child: _buildRangeButton(
                        label: 'Monthly',
                        value: 'monthly',
                        isSelected:
                            dashboardController.selectedRedemptionRange.value ==
                                'monthly',
                        onTap: () =>
                            dashboardController.setRedemptionRange('monthly'),
                      ),
                    ),
                    SizedBox(width: size(12)),
                    Expanded(
                      child: _buildRangeButton(
                        label: 'All Time',
                        value: 'all',
                        isSelected:
                            dashboardController.selectedRedemptionRange.value ==
                                'all',
                        onTap: () =>
                            dashboardController.setRedemptionRange('all'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size(24)),

              // Redemptions List
              CommonText(
                text: 'Kupan Details',
                fontSize: size(14),
                color: ColorConst.dark,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: size(12)),
              Obx(
                () {
                  var currentRedemptions = _getCurrentRedemptions();

                  if (dashboardController.isLoadingRedemptions.value) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: size(12)),
                            height: size(120),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(size(12)),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (dashboardController
                      .errorMessageRedemptions.value.isNotEmpty) {
                    return Container(
                      height: size(150),
                      alignment: Alignment.center,
                      child: CommonText(
                        text: dashboardController
                            .errorMessageRedemptions.value,
                        color: Colors.red,
                        fontSize: size(14),
                      ),
                    );
                  }

                  if (currentRedemptions == null ||
                      currentRedemptions.data.isEmpty) {
                    return Container(
                      height: size(150),
                      alignment: Alignment.center,
                      child: CommonText(
                        text: 'No redemptions for this period',
                        color: ColorConst.grey,
                        fontSize: size(14),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentRedemptions.data.length,
                    itemBuilder: (context, index) {
                      final item = currentRedemptions.data[index];
                      return _buildRedemptionCard(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  RedemptionsResponse? _getCurrentRedemptions() {
    final range = dashboardController.selectedRedemptionRange.value;
    if (range == 'weekly') {
      return dashboardController.weeklyRedemptions.value;
    } else if (range == 'monthly') {
      return dashboardController.monthlyRedemptions.value;
    } else if (range == 'all') {
      return dashboardController.allTimeRedemptions.value;
    }
    return null;
  }

  Widget _buildRedemptionCard(RedemptionData item) {
    return Container(
      margin: EdgeInsets.only(bottom: size(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size(12)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(size(12)),
            child: Row(
              children: [
                // Image
                if (item.kupanImages.isNotEmpty)
                  Container(
                    width: size(100),
                    height: size(100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size(8)),
                      color: Colors.grey[200],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      item.kupanImages[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: size(100),
                    height: size(100),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: size(14),
                          fontWeight: FontWeight.w600,
                          color: ColorConst.dark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: size(4)),

                      // Redemption count badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size(8),
                          vertical: size(4),
                        ),
                        decoration: BoxDecoration(
                          color: ColorConst.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(size(4)),
                        ),
                        child: Text(
                          '${item.totalRedemptions} redemptions',
                          style: TextStyle(
                            fontSize: size(11),
                            fontWeight: FontWeight.w600,
                            color: ColorConst.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: size(8)),

                      // Days
                      Wrap(
                        spacing: size(4),
                        runSpacing: size(4),
                        children: item.kupanDays.take(3).map((day) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size(6),
                              vertical: size(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(size(3)),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: size(10),
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (item.kupanDays.length > 3)
                        Text(
                          '+${item.kupanDays.length - 3} more',
                          style: TextStyle(
                            fontSize: size(10),
                            color: Colors.grey[600],
                          ),
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
                final result =
                    await Get.to(() => AddKupanView(kupanToEdit: item));
                if (result == true) {
                  // Refresh the current range redemptions
                  dashboardController.setRedemptionRange(
                      dashboardController.selectedRedemptionRange.value);
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
