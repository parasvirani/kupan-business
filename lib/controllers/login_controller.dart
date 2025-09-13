import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'package:kupan_business/models/verify_otp_res.dart';

import '../const/string_const.dart';
import '../models/user_login_model.dart';
import '../services/api_service.dart';
import '../utils/appRoutesStrings.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();

  // login
  var isLoading = false.obs;
  var loginResponse = Rxn<UserLoginResponse>();
  var errorMessage = ''.obs;

  // verify otp
  var isOtpLoading = false.obs;
  var otpResponse = Rxn<VerifyOtpRes>();
  var errorOtpMessage = ''.obs;
  final box = GetStorage();

  Future<void> login(String mobileNumber) async {
    isLoading.value = true;
    errorMessage.value = '';
    loginResponse.value = null;

    try {
      http.Response response = await _apiService.loginUser(mobileNumber);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        loginResponse.value = UserLoginResponse.fromJson(data);
        // print("OTP: ${loginResponse.value!.otp}");
        if (loginResponse.value!.success) {
          Get.toNamed(AppRoutes.otp, arguments: {"mobile_number" : mobileNumber});
        } else {
          errorMessage.value = loginResponse.value!.message;
        }

      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      print("Login::$e");
      errorMessage.value = "Error: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
    isOtpLoading.value = true;
    errorOtpMessage.value = '';
    otpResponse.value = null;

    try {
      http.Response response = await _apiService.verifyOtp(mobileNumber, otp, "vendor");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        otpResponse.value = VerifyOtpRes.fromJson(data);
        if (otpResponse.value!.success!) {
          box.write(StringConst.TOKEN, otpResponse.value?.data?.token);
          Get.toNamed(AppRoutes.details, arguments: {"mobile_number": mobileNumber});
        } else {
          errorOtpMessage.value = otpResponse.value!.message!;
        }

      } else {
        final error = jsonDecode(response.body);
        errorOtpMessage.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      errorOtpMessage.value = "Error: ${e.toString()}";
    } finally {
      isOtpLoading.value = false;
    }
  }
}
