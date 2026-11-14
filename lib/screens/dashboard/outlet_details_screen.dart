import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/my_outlets_controller.dart';
import 'package:kupan_business/models/user_businesses_res.dart';
import 'package:kupan_business/utils/utils.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'add_outlet_screen.dart';

class OutletDetailsScreen extends StatefulWidget {
  const OutletDetailsScreen({super.key});

  @override
  State<OutletDetailsScreen> createState() => _OutletDetailsScreenState();
}

class _OutletDetailsScreenState extends State<OutletDetailsScreen> {
  SellerBusiness sellerBusiness = Get.arguments as SellerBusiness;
  final PageController _controller = PageController();
  final MyOutletsController outletsController = Get.find<MyOutletsController>();
  final GlobalKey _qrStandBoundaryKey = GlobalKey();

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
            SizedBox(
              height: size(10),
            ),
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
            SizedBox(
              height: size(20),
            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: ColorConst.border, width: 1),
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
                                text:
                                    "${sellerBusiness.location?.address}, ${sellerBusiness.location?.city}, ${sellerBusiness.location?.state}, ${sellerBusiness.location?.pincode}",
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
    String kupanId = sellerBusiness.id ?? '';

    if (kupanId.isEmpty) {
      Get.snackbar('Error', 'Outlet ID not found');
      return;
    }

    // Generate QR code
    outletsController.generateQRCode(kupanId: kupanId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Paytm-style Countertop Stand card wrapped in RepaintBoundary
                  RepaintBoundary(
                    key: _qrStandBoundaryKey,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 340),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Top Paytm-style Header Banner (Kupan Brand Orange Gradient)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ColorConst.primary, const Color(0xFFFF7A00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'KUPAN DIGITAL QR STAND',
                                    style: TextStyle(
                                      color: ColorConst.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Scan & Save Instant Discounts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. White Body: Logo + Outlet Name + QR
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Official Horizontal Kupan Logo
                                Image.asset(
                                  'assets/icon/kupan_hori.png',
                                  height: 38,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Text(
                                    'KUPAN',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: ColorConst.primary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Outlet Name badge
                                Text(
                                  sellerBusiness.outletName ?? 'Kupan Partner',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F2937),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((sellerBusiness.location?.address ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    sellerBusiness.location!.address!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                const SizedBox(height: 14),

                                // QR Code Container with Kupan Brand Orange border
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: ColorConst.primary.withOpacity(0.35),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorConst.primary.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: outletsController.isLoadingQR.value
                                      ? Container(
                                          width: 210,
                                          height: 210,
                                          alignment: Alignment.center,
                                          child: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(strokeWidth: 3),
                                              SizedBox(height: 12),
                                              Text(
                                                'Generating QR Code...',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : outletsController.errorMessageQR.value.isNotEmpty
                                          ? Container(
                                              width: 210,
                                              height: 210,
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                outletsController.errorMessageQR.value,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : (outletsController.qrCodeUrl.value != null &&
                                                  outletsController.qrCodeUrl.value!.isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    outletsController.qrCodeUrl.value!,
                                                    width: 210,
                                                    height: 210,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: 210,
                                                        height: 210,
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  width: 210,
                                                  height: 210,
                                                  alignment: Alignment.center,
                                                  child: const Text('No QR Code'),
                                                ),
                                ),

                                const SizedBox(height: 14),

                                // Footer instruction callout (Kupan brand orange accent)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4ED),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFFFD7BE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 16,
                                        color: ColorConst.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Scan with Kupan App to claim coupons',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: ColorConst.primary,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Stand acrylic bottom accent stripe
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ColorConst.primary, const Color(0xFFFF7A00)],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Below the Stand (Close + Share Stand QR)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (outletsController.qrCodeUrl.value != null &&
                              outletsController.qrCodeUrl.value!.isNotEmpty) {
                            _shareStandImage();
                          }
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text(
                          'Share Stand QR',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConst.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareStandImage() async {
    // Show quick progress dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    try {
      // 1. Capture the RepaintBoundary as high-DPI image
      final boundary = _qrStandBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Stand view not ready for capture');
      }

      // pixelRatio 3.0 gives ultra crisp print/share quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate PNG bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 2. Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/kupan_stand_${sellerBusiness.id ?? 'outlet'}.png',
      );
      await file.writeAsBytes(pngBytes);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) Get.back();

      // 3. Share the branded stand image
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '${sellerBusiness.outletName ?? "Kupan Outlet"} - Scan to redeem exclusive discounts with Kupan App!\n${outletsController.qrCodeUrl.value ?? ""}',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      // Fallback: share raw QR if capture fails
      if (outletsController.qrCodeUrl.value != null &&
          outletsController.qrCodeUrl.value!.isNotEmpty) {
        _shareQRCode(outletsController.qrCodeUrl.value!);
      } else {
        Get.snackbar(
          'Share failed',
          'Could not share the stand. Please try again.',
        );
      }
    }
  }

  Future<void> _shareQRCode(String qrUrl) async {
    // Guard: nothing to share while the QR is still generating / URL is empty.
    if (qrUrl.isEmpty) return;

    // Brief loading overlay so a slow download doesn't feel like a dead tap.
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Download the QR PNG from Cloudinary to a temp file, then share the image.
      final res = await http.get(Uri.parse(qrUrl));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final file = File(
        '${Directory.systemTemp.path}/qr_${sellerBusiness.id ?? 'outlet'}.png',
      );
      await file.writeAsBytes(res.bodyBytes);

      // Close the loader before the system share sheet appears.
      if (Get.isDialogOpen ?? false) Get.back();

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code for ${sellerBusiness.outletName ?? ''}\n$qrUrl',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Share failed',
        'Could not share the QR code. Please try again.',
      );
    }
  }

  void _navigateToAddKupan() {
    // Set the selected outlet ID before navigating
    DashboardController dashboardController = Get.find<DashboardController>();
    dashboardController.selectedOutletId.value = sellerBusiness.id ?? '';
    dashboardController.selectedOutletName.value =
        sellerBusiness.outletName ?? '';

    // Show confirmation snackbar
    // Get.snackbar(
    //   'Adding Coupon',
    //   '${sellerBusiness.outletName} is selected',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 1),
    //   backgroundColor: ColorConst.primary,
    //   colorText: Colors.white,
    //   icon: const Icon(Icons.check_circle, color: Colors.white),
    // );

    // Navigate to Add Kupan screen and handle return.
    // 'fromOutlet' tells the screen to lock the outlet to this one.
    Get.toNamed(AppRoutes.addKupan, arguments: {'fromOutlet': true})?.then((_) {
      // When returning from add coupon screen, refresh the kupans list
      _loadOutletKupans();
    });
  }

  void _navigateToEditOutlet() {
    // Navigate to Add Outlet screen in edit mode with outlet data
    // Get.toNamed(
    //   AppRoutes.addOutlet,
    //   arguments: {
    //     'isEditMode': true,
    //     'outletData': sellerBusiness,
    //   },
    // );

    Get.to(
      () => AddOutletScreen(
        isEditMode: true,
        outletData: sellerBusiness,
      ),
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
                        text:
                            'Are you sure you want to remove ${sellerBusiness.outletName}? This action cannot be undone.',
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
