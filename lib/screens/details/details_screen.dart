import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/screens/details/components/personal_info.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';

import '../../controllers/dashboard_controller.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  var args = Get.arguments;
  DashboardController? dashboardController;

  @override
  void initState() {
    super.initState();

    if (args['isEdit']) {
      dashboardController = Get.put(DashboardController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
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
      body: PersonalInfo(
        isEdit: args['isEdit'],
        mobileNumber: args['mobile_number'],
        onTap: () {
          Get.toNamed(AppRoutes.dashboard, arguments: {"initialIndex": 2});
        },
      ),
    );
  }
}
