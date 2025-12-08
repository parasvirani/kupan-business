import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/my_outlets_controller.dart';
import 'package:kupan_business/models/user_businesses_res.dart';
import 'package:kupan_business/utils/utils.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OutletDetailsScreen extends StatefulWidget {
  const OutletDetailsScreen({super.key});

  @override
  State<OutletDetailsScreen> createState() => _OutletDetailsScreenState();
}

class _OutletDetailsScreenState extends State<OutletDetailsScreen> {

  SellerBusiness sellerBusiness = Get.arguments as SellerBusiness;
  final PageController _controller = PageController();
  final MyOutletsController outletsController = Get.find<MyOutletsController>();

  @override
  void initState() {
    super.initState();
    // Fetch kupans for this outlet
    _loadOutletKupans();
  }

  void _loadOutletKupans() {
    // Fetch kupans by businessId
    outletsController.getOutletKupans(
      businessId: sellerBusiness.id ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: CommonText(
          text: 'Cafe Street',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with rounded corners
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: SizedBox(
                height: size(180),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: sellerBusiness.outletImages?.length ?? 0,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sellerBusiness.outletImages![index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: size(180),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size(10),),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: sellerBusiness.outletImages?.length ?? 0,
                effect: ExpandingDotsEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: Color(0XFFABD915),
                  dotColor: Color(0XFF3F3F3F),
                ),
              ),
            ),
            SizedBox(height: size(20),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: sellerBusiness.outletName ?? "",
                            fontSize: size(20),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          SizedBox(height: size(4)),
                          CommonText(
                            text: sellerBusiness.businessType ?? "",
                            fontSize: size(12),
                            fontWeight: FontWeight.w500,
                            color: ColorConst.textGrey,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4,),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: ColorConst.border, width: 1),
                          borderRadius: BorderRadius.circular(size(4)),
                        ),
                        child: Row(
                          children: [
                             Icon(
                              Icons.star,
                              color: ColorConst.primary,
                              size: size(12),
                            ),
                            const SizedBox(width: 4),
                            CommonText(
                              text: '4.8',
                              fontSize: size(14),
                              fontWeight: FontWeight.w600,
                              color: ColorConst.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size(20)),

                  // Location Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorConst.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: ColorConst.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: sellerBusiness.outletName ?? "",
                                fontSize: size(12),
                                color: ColorConst.textGrey,
                              ),
                              const SizedBox(height: 2),
                              CommonText(
                                text: "${sellerBusiness.location?.address}, ${sellerBusiness.location?.city}, ${sellerBusiness.location?.state}, ${sellerBusiness.location?.pincode}",
                                fontSize: size(14),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorConst.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: ColorConst.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: 'Open',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 2),
                            CommonText(
                              text: '${sellerBusiness.outletTime}',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons in Single Line
                  Row(
                    children: [
                      _buildCompactActionButton(
                        'Add Coupons',
                        Icons.add_circle_outline,
                        ColorConst.primary,
                            () {
                          _navigateToAddKupan();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildCompactActionButton(
                        'Edit \nOutlet',
                        Icons.edit_outlined,
                        const Color(0xFF3B82F6),
                            () {
                          _navigateToEditOutlet();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildCompactActionButton(
                        'Remove Outlet',
                        Icons.delete_outline,
                        const Color(0xFFEF4444),
                            () {
                          _showRemoveConfirmation();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildCompactActionButton(
                        'QR \nCode',
                        Icons.qr_code_2,
                        const Color(0xFF8B5CF6),
                            () {
                          _showQRCodeDialog();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Kupans List Section
                  CommonText(
                    text: 'Coupons',
                    fontSize: size(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 12),
                  _buildKupansList(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKupansList() {
    return Obx(
      () {
        if (outletsController.isLoadingOutletKupans.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (outletsController.errorMessageOutletKupans.value.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: CommonText(
              text: outletsController.errorMessageOutletKupans.value,
              fontSize: 13,
              color: Colors.orange.shade700,
            ),
          );
        }

        if (outletsController.outletKupanList.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  CommonText(
                    text: 'No coupons available',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: outletsController.outletKupanList.length,
          itemBuilder: (context, index) {
            final kupan = outletsController.outletKupanList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Coupon Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: Image.network(
                      kupan.kupanImages?.isNotEmpty == true
                          ? kupan.kupanImages![0]
                          : '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  // Coupon Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            text: kupan.title ?? 'Coupon',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          if (kupan.kupanDays?.isNotEmpty == true)
                            CommonText(
                              text:
                                  '${kupan.kupanDays?.length ?? 0} days available',
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConst.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CommonText(
                              text: 'View Details',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorConst.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withAlpha(60),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                CommonText(
                  text: title,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _showQRCodeDialog() {
    // Get kupanId from arguments or use outlet id
    String kupanId = sellerBusiness.id ?? '';
    
    if (kupanId.isEmpty) {
      Get.snackbar('Error', 'Outlet ID not found');
      return;
    }

    // Generate QR code
    outletsController.generateQRCode(kupanId: kupanId);

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          text: 'QR Code',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (outletsController.isLoadingQR.value)
                          Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              CommonText(
                                text: 'Generating QR Code...',
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          )
                        else if (outletsController.errorMessageQR.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: CommonText(
                              text: outletsController.errorMessageQR.value,
                              fontSize: 14,
                              color: Colors.red.shade700,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (outletsController.qrCodeUrl.value != null &&
                            outletsController.qrCodeUrl.value!.isNotEmpty)
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    outletsController.qrCodeUrl.value!,
                                    width: 280,
                                    height: 280,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 280,
                                        height: 280,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CommonText(
                                text: '${sellerBusiness.outletName ?? "Outlet"}',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ],
                          )
                        else
                          CommonText(
                            text: 'No QR code available',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Footer with action buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CommonText(
                                  text: 'Close',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (outletsController.qrCodeUrl.value != null &&
                                  outletsController.qrCodeUrl.value!.isNotEmpty) {
                                _shareQRCode(outletsController.qrCodeUrl.value!);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ColorConst.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    CommonText(
                                      text: 'Share',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareQRCode(String qrUrl) {
    // Share the QR code URL
    // You can use share_plus package for native sharing
    // For now, just copy to clipboard
    if (qrUrl.isNotEmpty) {
      // Option 1: Copy to clipboard
      // Clipboard.setData(ClipboardData(text: qrUrl));
      // Get.snackbar('Success', 'QR code URL copied to clipboard');
      
      // Option 2: Open URL in browser or share
      Get.snackbar('Share', 'QR Code URL: $qrUrl');
      // You can implement native share using share_plus package
      // share(qrUrl, subject: 'QR Code for ${sellerBusiness.outletName}');
    }
  }

  void _navigateToAddKupan() {
    // Set the selected outlet ID before navigating
    DashboardController dashboardController = Get.find<DashboardController>();
    dashboardController.selectedOutletId.value = sellerBusiness.id ?? '';
    dashboardController.selectedOutletName.value = sellerBusiness.outletName ?? '';

    // Show confirmation snackbar
    Get.snackbar(
      'Adding Coupon',
      '${sellerBusiness.outletName} is selected',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: ColorConst.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    // Navigate to Add Kupan screen and handle return
    Get.toNamed(AppRoutes.addKupan)?.then((_) {
      // When returning from add coupon screen, refresh the kupans list
      _loadOutletKupans();
    });
  }

  void _navigateToEditOutlet() {
    // Navigate to Add Outlet screen in edit mode with outlet data
    Get.toNamed(
      AppRoutes.addOutlet,
      arguments: {
        'isEditMode': true,
        'outletData': sellerBusiness,
      },
    );
  }

  void _showRemoveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(25),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.warning_outlined,
                          color: Color(0xFFEF4444),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CommonText(
                        text: 'Remove Outlet',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 12),
                      CommonText(
                        text: 'Are you sure you want to remove ${sellerBusiness.outletName}? This action cannot be undone.',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: CommonText(
                                text: 'Cancel',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _performRemoveOutlet();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: CommonText(
                                text: 'Remove',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performRemoveOutlet() {
    // Call the remove outlet API
    String outletId = sellerBusiness.id ?? '';
    if (outletId.isEmpty) {
      Get.snackbar('Error', 'Outlet ID not found');
      return;
    }

    // Show loading dialog
    Get.dialog(
      Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    // Call the API to remove the outlet
    outletsController.deleteBusiness(outletId).then((value) {
      Get.back(); // Close loading dialog
      Get.back(); // Go back to previous screen
      Get.snackbar('Success', 'Outlet removed successfully');
    }).catchError((error) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Failed to remove outlet: $error');
    });
  }
}