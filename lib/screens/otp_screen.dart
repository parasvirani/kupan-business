
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kupan_business/screens/personal_info.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:get/get.dart';

import '../common_view/common_button.dart';
import '../common_view/common_text.dart';
import '../const/color_const.dart';
import '../controllers/login_controller.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final LoginController controller = Get.put(LoginController());
  var args = Get.arguments;
  OtpFieldController otpFieldController = OtpFieldController();
  String? pin = "";

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
      body: SingleChildScrollView(
        child: Padding(
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
                            fontFamily: 'Inter')),
                    TextSpan(
                        text: '+91 ${args['mobile_number']}',
                        style: TextStyle(
                            fontSize: size(16),
                            color: ColorConst.dark,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
               SizedBox(height: size(30)),
              OTPTextField(
                length: 6,
                fieldWidth: size(50),
                controller: otpFieldController,
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
                    fontFamily: 'Inter'),
                textFieldAlignment: MainAxisAlignment.center,
                fieldStyle: FieldStyle.box, // Or box
                onChanged: (value) {
                  this.pin = value;
                  setState(() {

                  });
                },

              ),
              SizedBox(height: size(5)),
               Obx(()=> Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: CommonText(
                   text: controller.errorOtpMessage.value  ,
                   color: Colors.red,
                 ),
               ),),
               SizedBox(height: size(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonText(
                    text: "Don't receive otp?"  ,
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
              Obx(
                ()=> CommonButton(
                  isDisable: pin?.length != 6,
                  isLoading: controller.isOtpLoading.value,
                    onPressed: () {
                  controller.verifyOtp(args['mobile_number'], pin!);
                }, text: 'Otp Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
