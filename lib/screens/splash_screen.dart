import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common_view/common_text.dart';
import '../const/color_const.dart';
import '../const/image_const.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    await Future.delayed(Duration(seconds: 3));
    Get.offNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            ImageConst.splash,
            width: Get.width,
            height: Get.height,
            fit: BoxFit.cover,
          ),
          Center(
            child: Text(
              "kupan.",
              style: TextStyle(
                  fontSize: size(62),
                  color: ColorConst.white,
                  fontFamily: 'ScriptMTBold'),
            ),
          ),
          Positioned(
            bottom: size(36),
            right: 0,
            left: 0,
            child: Center(
              child: CommonText(
                text:
                    "By dolor sit amet, elit, sed do eiusmod\ntempor ut labore et dolore magna aliqua.",
                fontSize: size(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
