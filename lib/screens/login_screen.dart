import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../common_view/common_button.dart';
import '../common_view/common_text.dart';
import '../common_view/common_textfield.dart';
import '../const/color_const.dart';
import '../const/image_const.dart';
import '../controllers/login_controller.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size(20)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size(100)),
                SvgPicture.asset(
                  ImageConst.login_ph, // Replace with your actual image path
                  height: size(100),
                ),
                SizedBox(height: size(30)),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                              fontSize: size(24),
                              color: ColorConst.dark,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist')),
                      TextSpan(
                          text: 'kupan.',
                          style: TextStyle(
                              fontSize: size(34),
                              color: ColorConst.primary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'ScriptMTBold')),
                    ],
                  ),
                ),
                SizedBox(height: size(20)),
                CommonText(
                  text:
                      'Sign in to unlock exclusive deals and start\nsaving instantly!',
                  textAlign: TextAlign.center,
                  fontSize: 16,
                  color: ColorConst.grey,
                ),
                SizedBox(height: size(40)),
                CommonTextfield(
                  controller: _phoneController,
                  hintText: 'Enter phone number',
                  isNumber: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    // Indian number regex: starts with [6-9], length 10
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return 'Enter valid Indian mobile number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Obx(
                    ()=> CommonButton(
                     isLoading: controller.isLoading.value,
                      onPressed:  () {
                        if (_formKey.currentState!.validate()) {
                          // ✅ Valid mobile number
                          controller.login(
                              _phoneController.text.trim());
                        }
                        // controller.login(_phoneController.text.trim(), "customer");
                        // Get.toNamed(AppRoutes.otp);
                      },
                      text: 'Send to Otp'),
                ),
                // You can add more login options here if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
