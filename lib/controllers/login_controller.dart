import 'dart:convert';
import 'package:kupan_business/services/api_exception.dart';
import 'package:kupan_business/services/secure_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'package:kupan_business/models/verify_otp_res.dart';

import '../models/user_login_model.dart';
import '../services/api_service.dart';
import '../utils/appRoutesStrings.dart';
import 'approval_controller.dart';

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
          Get.toNamed(AppRoutes.otp,
              arguments: {"mobile_number": mobileNumber});
        } else {
          errorMessage.value = loginResponse.value?.message ?? 'Login failed';
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      print("Login::$e");
      errorMessage.value = mapError(e).userMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(
      String mobileNumber, String otp, String verificationId) async {
    isOtpLoading.value = true;
    errorOtpMessage.value = '';
    otpResponse.value = null;

    try {
      // Step 1: Firebase OTP Verify
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Step 2: ID Token lo
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        errorOtpMessage.value = 'Failed to get firebase token';
        return;
      }

      // Step 3: Backend API Call
      http.Response response = await _apiService.verifyOtp(idToken, "vendor");

      if (response.statusCode == 200) {
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
              await SecureStore.i.setToken(otpResponse.value?.data?.token);
            }
            final String? userId = otpResponse.value?.data?.user?.id;
            final String? userName = otpResponse.value?.data?.user?.name;
            print("userId=$userId, userName=$userName");
            if (userId != null) {
              await SecureStore.i.setUserId(userId);
              print("✓ User ID written");
            }
            if (userName != null) {
              await SecureStore.i.setUserName(userName);
              print("✓ User name written");
            }
          } catch (e, st) {
            print("StorageError:: $e\n$st");
            errorOtpMessage.value = 'Failed to save data';
            return;
          }

          // Route based on whether the profile is already complete.
          try {
            await _routeAfterLogin(mobileNumber);
          } catch (e, st) {
            print("NavigationError:: $e\n$st");
            errorOtpMessage.value = 'Navigation failed';
            return;
          }
        } else {
          errorOtpMessage.value =
              otpResponse.value?.message ?? 'Verification failed';
        }
      } else {
        print("VerifyOtp Error Status: ${response.statusCode}");
        try {
          final error = jsonDecode(response.body);
          errorOtpMessage.value = error['message'] ?? 'Login failed';
        } catch (e) {
          errorOtpMessage.value =
              'Verification failed (${response.statusCode})';
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException:::$e");
      errorOtpMessage.value = e.message ?? 'Wrong OTP';
    } catch (e) {
      print("VerifyOtp:::$e");
      errorOtpMessage.value = mapError(e).userMessage;
    } finally {
      isOtpLoading.value = false;
    }
  }

  /// Decides where to send the user after a successful OTP verification:
  ///  - No vendor profile / outlet registered yet (or no name) → details screen to complete setup.
  ///  - Has a vendor profile → routed by approval status: approved → dashboard, else waiting screen.
  Future<void> _routeAfterLogin(String mobileNumber) async {
    final approvalCtrl = ApprovalController();
    final status = await approvalCtrl.checkStatus();
    final bool hasProfile = approvalCtrl.hasVendorProfile.value;
    final String name = otpResponse.value?.data?.user?.name?.trim() ?? '';

    // If new vendor or no business outlet submitted yet, require registration
    if (!hasProfile || name.isEmpty) {
      Get.offAllNamed(AppRoutes.details, arguments: {
        "isEdit": false,
        "mobile_number": mobileNumber,
      });
      return;
    }

    // Once outlet is submitted, vendor has access to the dashboard.
    // Creating coupons is gated by approval status.
    Get.offAllNamed(AppRoutes.dashboard);
  }

  // Auto-verification mate alag method
  Future<void> verifyOtpWithToken(String idToken) async {
    isOtpLoading.value = true;
    errorOtpMessage.value = '';

    try {
      http.Response response = await _apiService.verifyOtp(idToken, "vendor");

      if (response.statusCode == 200) {
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
              await SecureStore.i.setToken(otpResponse.value?.data?.token);
            }
            final String? userId = otpResponse.value?.data?.user?.id;
            final String? userName = otpResponse.value?.data?.user?.name;
            print("userId=$userId, userName=$userName");
            if (userId != null) {
              await SecureStore.i.setUserId(userId);
              print("✓ User ID written");
            }
            if (userName != null) {
              await SecureStore.i.setUserName(userName);
              print("✓ User name written");
            }
          } catch (e, st) {
            print("StorageError:: $e\n$st");
            errorOtpMessage.value = 'Failed to save data';
            return;
          }

          try {
            // Get mobile number from Firebase user (used only if the profile
            // is incomplete and we route to the details screen).
            final String phoneNumber =
                FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
            await _routeAfterLogin(phoneNumber);
          } catch (e, st) {
            print("NavigationError:: $e\n$st");
            errorOtpMessage.value = 'Navigation failed';
            return;
          }
        } else {
          errorOtpMessage.value =
              otpResponse.value?.message ?? 'Verification failed';
        }
      } else {
        print("VerifyOtpWithToken Error Status: ${response.statusCode}");
        try {
          final error = jsonDecode(response.body);
          errorOtpMessage.value = error['message'] ?? 'Login failed';
        } catch (e) {
          errorOtpMessage.value =
              'Verification failed (${response.statusCode})';
        }
      }
    } catch (e) {
      print("verifyOtpWithToken:::$e");
      errorOtpMessage.value = mapError(e).userMessage;
    } finally {
      isOtpLoading.value = false;
    }
  }
}
