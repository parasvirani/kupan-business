import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../common_view/common_text.dart';
import '../const/color_const.dart';
import '../const/image_const.dart';
import '../const/string_const.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

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
    String? token = box.read(StringConst.TOKEN);
    if (token?.isNotEmpty ?? false) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }


  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = (value) => screenWidth / (375 / value); // 375 is standard width base

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
              ImageConst.splash_5,
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
