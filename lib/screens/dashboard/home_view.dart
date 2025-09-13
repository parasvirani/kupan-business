
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../common_view/common_text.dart';
import '../../common_view/common_textfield.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../models/restaurant_deal.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final List<RestaurantDeal> deals = [
    RestaurantDeal(
      image: 'assets/indian_food.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: 'assets/restaurant_interior.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: 'assets/indian_food.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: 'assets/salon_interior.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: 'assets/indian_food.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
    RestaurantDeal(
      image: 'assets/indian_food.jpg',
      title: 'panjabi dhaba',
      offer: 'Get up to 40% off only dine-in',
      subtitle: 'Limited time deals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      appBar: AppBar(
        backgroundColor: ColorConst.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {}, icon: SvgPicture.asset(ImageConst.ic_menu)),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonText(
              text: 'Current address',
              fontSize: size(12),
              color: ColorConst.grey,
            ),
            CommonText(
              text: '68 High Street, England',
              fontSize: size(16),
              color: ColorConst.dark,
              fontWeight: FontWeight.w600,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextfield(
                hintText: 'Search for "restaurant"',
                readOnly: true,
                onTap: (){
                  Get.toNamed(AppRoutes.search);
                },
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size(10)),
                  child: SvgPicture.asset(ImageConst.ic_search),
                ),
                controller: TextEditingController(),
              ),
              SizedBox(height: size(16)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(deal: deals[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class RestaurantCard extends StatelessWidget {
  final RestaurantDeal deal;

  const RestaurantCard({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Restaurant Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 80,
              color: Colors.orange[100],
              child: deal.image.contains('food')
                  ? _buildFoodImage()
                  : deal.image.contains('interior')
                  ? _buildInteriorImage()
                  : _buildSalonImage(),
            ),
          ),

          // Restaurant Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    deal.offer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    deal.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Edit Icon
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFoodImage() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange[200]!, Colors.red[200]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.restaurant,
        size: 32,
        color: Colors.orange[800],
      ),
    ),
  );
}

Widget _buildInteriorImage() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey[300]!, Colors.grey[400]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.store,
        size: 32,
        color: Colors.grey[700],
      ),
    ),
  );
}

Widget _buildSalonImage() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.pink[100]!, Colors.purple[100]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.content_cut,
        size: 32,
        color: Colors.pink[800],
      ),
    ),
  );
}
