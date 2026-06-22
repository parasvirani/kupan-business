import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
        // print("OTP: ${loginResponse.value?.otp}");
        if (loginResponse.value?.success == true) {
          Get.toNamed(AppRoutes.otp, arguments: {"mobile_number" : mobileNumber});
        } else {
          errorMessage.value = loginResponse.value?.message ?? 'Login failed';
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

  Future<void> verifyOtp(String mobileNumber, String otp, String verificationId) async {
    isOtpLoading.value = true;
    errorOtpMessage.value = '';
    otpResponse.value = null;

    try {
      // Step 1: Firebase OTP Verify
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Step 2: ID Token lo
      String? idToken = await userCredential.user?.getIdToken();
      print("ID Token:::$idToken");

      if (idToken == null) {
        errorOtpMessage.value = 'Failed to get firebase token';
        return;
      }

      // Step 3: Backend API Call
      http.Response response = await _apiService.verifyOtp(idToken, "vendor");

      if (response.statusCode == 200) {
        print("VerifyOtp Response Body: ${response.body}");
        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("Decoded JSON: $data");
        } catch (e, st) {
          print("JsonDecodeError:: $e\n$st");
          errorOtpMessage.value = 'Invalid response format';
          return;
        }
        try {
          otpResponse.value = VerifyOtpRes.fromJson(data);
          print("Parsed VerifyOtpRes successfully: ${otpResponse.value}");
        } catch (e, st) {
          print("ParseVerifyOtpError:: $e\n$st");
          errorOtpMessage.value = 'Invalid server response';
          return;
        }

        print("Checking success flag: ${otpResponse.value?.success}");
        if (otpResponse.value?.success == true) {
          print("✓ OTP verification successful");
          // Persist token & user info if available
          try {
            if (otpResponse.value?.data?.token != null) {
              print("Writing token...");
              box.write(StringConst.TOKEN, otpResponse.value?.data?.token);
              print("✓ Token written");
            }
            final String? userId = otpResponse.value?.data?.user?.id;
            final String? userName = otpResponse.value?.data?.user?.name;
            print("userId=$userId, userName=$userName");
            if (userId != null) {
              box.write(StringConst.USER_ID, userId);
              print("✓ User ID written");
            }
            if (userName != null) {
              box.write(StringConst.USER_NAME, userName);
              print("✓ User name written");
            }
          } catch (e, st) {
            print("StorageError:: $e\n$st");
            errorOtpMessage.value = 'Failed to save data';
            return;
          }

          // Navigate to details screen for profile completion
          try {
            print("Navigating to details screen...");
            Get.offAllNamed(AppRoutes.details, arguments: {
              "isEdit": false,
              "mobile_number": mobileNumber,
            });
          } catch (e, st) {
            print("NavigationError:: $e\n$st");
            errorOtpMessage.value = 'Navigation failed';
            return;
          }
        } else {
          errorOtpMessage.value = otpResponse.value?.message ?? 'Verification failed';
        }
      } else {
        print("VerifyOtp Error Status: ${response.statusCode}");
        try {
          final error = jsonDecode(response.body);
          errorOtpMessage.value = error['message'] ?? 'Login failed';
        } catch (e) {
          errorOtpMessage.value = 'Verification failed (${response.statusCode})';
        }
      }

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException:::$e");
      errorOtpMessage.value = e.message ?? 'Wrong OTP';
    } catch (e) {
      print("VerifyOtp:::$e");
      errorOtpMessage.value = "Error: ${e.toString()}";
    } finally {
      isOtpLoading.value = false;
    }
  }

  // Auto-verification mate alag method
  Future<void> verifyOtpWithToken(String idToken) async {
    isOtpLoading.value = true;
    errorOtpMessage.value = '';

    try {
      http.Response response = await _apiService.verifyOtp(idToken, "vendor");

      if (response.statusCode == 200) {
        print("VerifyOtpWithToken Response Body: ${response.body}");
        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("Decoded JSON: $data");
        } catch (e, st) {
          print("JsonDecodeError:: $e\n$st");
          errorOtpMessage.value = 'Invalid response format';
          return;
        }
        try {
          otpResponse.value = VerifyOtpRes.fromJson(data);
          print("Parsed VerifyOtpRes successfully: ${otpResponse.value}");
        } catch (e, st) {
          print("ParseVerifyOtpError:: $e\n$st");
          errorOtpMessage.value = 'Invalid server response';
          return;
        }

        print("Checking success flag: ${otpResponse.value?.success}");
        if (otpResponse.value?.success == true) {
          print("✓ OTP verification successful");
          try {
            if (otpResponse.value?.data?.token != null) {
              print("Writing token...");
              box.write(StringConst.TOKEN, otpResponse.value?.data?.token);
              print("✓ Token written");
            }
            final String? userId = otpResponse.value?.data?.user?.id;
            final String? userName = otpResponse.value?.data?.user?.name;
            print("userId=$userId, userName=$userName");
            if (userId != null) {
              box.write(StringConst.USER_ID, userId);
              print("✓ User ID written");
            }
            if (userName != null) {
              box.write(StringConst.USER_NAME, userName);
              print("✓ User name written");
            }
          } catch (e, st) {
            print("StorageError:: $e\n$st");
            errorOtpMessage.value = 'Failed to save data';
            return;
          }

          try {
            print("Navigating to details screen...");
            // Get mobile number from Firebase user
            final String? phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
            if (phoneNumber == null || phoneNumber.isEmpty) {
              errorOtpMessage.value = 'Phone number not found';
              return;
            }
            Get.offAllNamed(AppRoutes.details, arguments: {
              "isEdit": false,
              "mobile_number": phoneNumber,
            });
          } catch (e, st) {
            print("NavigationError:: $e\n$st");
            errorOtpMessage.value = 'Navigation failed';
            return;
          }
        } else {
          errorOtpMessage.value = otpResponse.value?.message ?? 'Verification failed';
        }
      } else {
        print("VerifyOtpWithToken Error Status: ${response.statusCode}");
        try {
          final error = jsonDecode(response.body);
          errorOtpMessage.value = error['message'] ?? 'Login failed';
        } catch (e) {
          errorOtpMessage.value = 'Verification failed (${response.statusCode})';
        }
      }
    } catch (e) {
      print("verifyOtpWithToken:::$e");
      errorOtpMessage.value = "Error: ${e.toString()}";
    } finally {
      isOtpLoading.value = false;
    }
  }
}
