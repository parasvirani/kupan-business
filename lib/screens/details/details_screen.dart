import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/screens/details/components/personal_info.dart';
import 'components/outlet_info.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  var args = Get.arguments;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            if (_tabController.index == 0) {
              // Personal Info tab is visible → exit screen
              Navigator.of(context).pop();
            } else {
              // Other tab (Outlet Info) → go back to Personal Info tab
              _tabController.animateTo(0);
            }
          },
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: IgnorePointer(
              ignoring: true,
              child: TabBar(
                controller: _tabController,
                labelColor: Color(0xFFFF4500),
                unselectedLabelColor: Colors.grey[400],
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Color(0xFFFF4500),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Personal Info'),
                  Tab(text: 'Outlet Info'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                PersonalInfo(mobileNumber : args['mobile_number'], onTap:() {
                  _tabController.animateTo(1);
                },),
                OutletInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
