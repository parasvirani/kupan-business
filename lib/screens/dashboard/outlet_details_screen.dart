import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/models/user_businesses_res.dart';
import 'package:kupan_business/utils/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OutletDetailsScreen extends StatefulWidget {
  const OutletDetailsScreen({super.key});

  @override
  State<OutletDetailsScreen> createState() => _OutletDetailsScreenState();
}

class _OutletDetailsScreenState extends State<OutletDetailsScreen> {

  SellerBusiness sellerBusiness = Get.arguments as SellerBusiness;
  final PageController _controller = PageController();

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

                  // Action Buttons Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _buildActionButton(
                        'Add Coupons',
                            () {},
                      ),
                      _buildActionButton(
                        'Edit Outlet',
                            () {},
                      ),
                      _buildActionButton(
                        'Delete Outlet',
                            () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConst.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CommonText(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}