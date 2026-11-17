import 'package:flutter/material.dart';
import 'package:kupan_business/services/secure_store.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../const/image_const.dart';
import '../utils/appRoutesStrings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    await Future.delayed(Duration(seconds: 3));
    String token = SecureStore.i.token;
    if (token.isEmpty) {
      Get.offNamed(AppRoutes.login);
      return;
    }

    // Logged-in vendor: directly access dashboard.
    // Dashboard displays 'Under Review' banner if pending/unapproved.
    Get.offNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            color: Color(0XFF1A1A1A),
          ),
          Center(
            child: Image.asset(
              ImageConst.kupanLogoWhiteHorizontal,
              width: Get.width * 0.6,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              ImageConst.splash_1,
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            child: Image.asset(
              ImageConst.splash_2,
            ),
          ),
          Positioned(
            bottom: 150,
            right: 0,
            child: Image.asset(
              ImageConst.splash_3,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              ImageConst.splash_4,
            ),
          ),
        ],
      ),
    );
  }
}
