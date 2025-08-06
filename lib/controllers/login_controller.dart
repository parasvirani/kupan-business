import 'dart:convert';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../models/user_login_model.dart';
import '../services/api_service.dart';
import '../utils/appRoutesStrings.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var loginResponse = Rxn<UserLoginResponse>();
  var errorMessage = ''.obs;

  Future<void> login(String mobileNumber, String userType) async {
    isLoading.value = true;
    errorMessage.value = '';
    loginResponse.value = null;

    try {
      http.Response response = await _apiService.loginUser(mobileNumber, userType);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        loginResponse.value = UserLoginResponse.fromJson(data);
        print("OTP: ${loginResponse.value!.otp}");
        Get.toNamed(AppRoutes.otp);
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = "Error: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }
}
