
import 'package:flutter/material.dart';
import 'package:kupan_business/screens/personal_info.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:get/get.dart';

import '../common_view/common_button.dart';
import '../common_view/common_text.dart';
import '../const/color_const.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      appBar: AppBar(
        backgroundColor: ColorConst.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(size(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size(30)),
            CommonText(
              text: 'Otp Verification',
              textAlign: TextAlign.center,
                fontSize: size(28),
                fontWeight: FontWeight.bold,
                color: ColorConst.dark,
            ),
             SizedBox(height: size(10)),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'We will send you an one time password\non this ',
                      style: TextStyle(
                          fontSize: size(16),
                          color: ColorConst.dark,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Urbanist')),
                  TextSpan(
                      text: '+91 945 69 721 58',
                      style: TextStyle(
                          fontSize: size(16),
                          color: ColorConst.dark,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist')),
                ],
              ),
            ),
             SizedBox(height: size(30)),
            OTPTextField(
              length: 6,
              fieldWidth: size(50),
              spaceBetween: size(10),
              otpFieldStyle: OtpFieldStyle(
                enabledBorderColor: ColorConst.grey.withAlpha(30),
                focusBorderColor: ColorConst.primary,
                borderColor: ColorConst.grey.withAlpha(30),
                disabledBorderColor: ColorConst.grey.withAlpha(10),
                errorBorderColor: ColorConst.primary,
              ),
              style: TextStyle(fontSize: size(16),
                  color: ColorConst.dark,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Urbanist'),
              textFieldAlignment: MainAxisAlignment.center,
              fieldStyle: FieldStyle.box, // Or box
              onCompleted: (pin) {
                print("Completed: $pin"); // Handle OTP completion
              },
            ),
             SizedBox(height: size(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                  text: "Don't receive otp?",
                  color: ColorConst.grey,
                ),
                TextButton(
                  onPressed: () {
                    // Handle resend OTP
                  },
                  child: CommonText(
                    text: 'Resend Otp',
                    color: ColorConst.primary,
                  ),
                ),
              ],
            ),
             SizedBox(height: size(40)),
            CommonButton(onPressed: (){
              Get.toNamed(AppRoutes.personalinfo);
              // Get.toNamed(AppRoutes.locations);
            }, text: 'Otp Verify'),
          ],
        ),
      ),
    );
  }
}
