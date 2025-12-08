import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/kupans_list_res.dart';
import '../models/qr_code_res.dart';
import '../models/user_businesses_res.dart';
import '../services/api_service.dart';

class MyOutletsController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var isDeleting = false.obs;
  var errorMessage = ''.obs;
  var userBusinessesRes = Rxn<UserBusinessesRes>();
  RxList<SellerBusiness> outletsList = <SellerBusiness>[].obs;

  var selectedOutletId = ''.obs;
  var selectedOutletName = ''.obs;
  var errorMessageOutletSelection = ''.obs;

  // QR Code properties
  var isLoadingQR = false.obs;
  var errorMessageQR = ''.obs;
  var qrCodeUrl = Rxn<String>();

  // Outlet Kupans properties
  var isLoadingOutletKupans = false.obs;
  var errorMessageOutletKupans = ''.obs;
  RxList<KupanData> outletKupanList = <KupanData>[].obs;


  @override
  void onInit() {
    super.onInit();
    getOutlets();
  }

  Future<void> getOutlets() async {
    isLoading(true);
    errorMessage.value = '';

    try {
      http.Response response = await _apiService.getBusinessOutlets();
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Decoded Data: $data");

        // Safely parse the response
        if (data is Map<String, dynamic>) {
          try {
            // Extract success and message directly from the response
            bool success = data['success'] as bool? ?? false;
            String message = data['message'] as String? ?? '';

            print("Success: $success, Message: $message");

            if (success) {
              // Manually parse the data object to avoid type casting issues
              final responseData = data['data'];
              print("Response Data Type: ${responseData.runtimeType}");
              print("Response Data: $responseData");

              if (responseData is Map<String, dynamic>) {
                final businessesData = responseData['sellerBusinesses'];
                print("sellerBusinesses Type: ${businessesData.runtimeType}");
                print("sellerBusinesses Data: $businessesData");

                if (businessesData is List) {
                  // Parse each business item manually
                  outletsList.clear();
                  for (var item in businessesData) {
                    if (item is Map<String, dynamic>) {
                      try {
                        final business = SellerBusiness.fromJson(item);
                        outletsList.add(business);
                        print("Added business: ${business.outletName}");
                      } catch (e) {
                        print("Error parsing business item: $e");
                      }
                    }
                  }
                  outletsList.refresh();
                  print("Outlets loaded successfully: ${outletsList.length}");
                } else {
                  print("sellerBusinesses is not a List");
                  outletsList.clear();
                }
              } else {
                print("Response data is not a Map");
                outletsList.clear();
              }
            } else {
              errorMessage.value = message.isNotEmpty ? message : 'Failed to fetch outlets';
              print("API Error: ${errorMessage.value}");
            }
          } catch (parseError) {
            print("Parse Error: $parseError");
            print("Stack trace: ${StackTrace.current}");
            errorMessage.value = "Failed to parse response: ${parseError.toString()}";
          }
        } else {
          errorMessage.value = 'Invalid response format';
          print("Invalid response format, data is not a Map");
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          errorMessage.value = error['message'] ?? 'Failed to fetch outlets';
        } catch (e) {
          errorMessage.value = 'HTTP Error: ${response.statusCode}';
        }
      }
    } catch (e) {
      print("Error fetching outlets::$e");
      errorMessage.value = "Error: ${e.toString()}";
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBusiness(String businessId) async {
    isDeleting(true);
    try {
      print("Attempting to delete business with ID: $businessId");
      http.Response response = await _apiService.deleteBusiness(businessId);
      print("Delete Response Status: ${response.statusCode}");
      print("Delete Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool success = data['success'] as bool? ?? false;

        if (success) {
          // Remove the business from the list
          print("Removing outlet with ID: $businessId from list");
          outletsList.removeWhere((outlet) => outlet.id == businessId);
          outletsList.refresh();
          Get.snackbar(
            'Success',
            'Outlet deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 76, 175, 80),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          print("Business deleted successfully");
        } else {
          String message = data['message'] ?? 'Failed to delete outlet';
          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          String message = error['message'] ?? 'Failed to delete outlet';
          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'HTTP Error: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      print("Error deleting business: $e");
      Get.snackbar(
        'Error',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isDeleting(false);
    }
  }

  Future<void> updateBusiness(String businessId, Map<String, dynamic> businessData) async {
    try {
      print("Attempting to update business with ID: $businessId");
      http.Response response = await _apiService.updateBusiness(businessId, businessData);
      print("Update Response Status: ${response.statusCode}");
      print("Update Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool success = data['success'] as bool? ?? false;

        if (success) {
          // Refresh the outlets list to get updated data
          await getOutlets();
          // Get.snackbar(
          //   'Success',
          //   'Outlet updated successfully',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: const Color.fromARGB(255, 76, 175, 80),
          //   colorText: Colors.white,
          //   duration: const Duration(seconds: 2),
          // );
          Get.back();
          print("Business updated successfully");
        } else {
          String message = data['message'] ?? 'Failed to update outlet';
          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          String message = error['message'] ?? 'Failed to update outlet';
          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'HTTP Error: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      print("Error updating business: $e");
      Get.snackbar(
        'Error',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Static method to refresh outlets from anywhere
  static Future<void> refreshOutlets() async {
    try {
      final controller = Get.find<MyOutletsController>();
      await controller.getOutlets();
      print("Outlets refreshed successfully");
    } catch (e) {
      print("Error refreshing outlets: $e");
    }
  }

  void onOutletChanged(String? value) {
    if (value == null) {
      selectedOutletId.value = '';
      selectedOutletName.value = '';
      return;
    }

    selectedOutletId.value = value;
    final selected = outletsList.firstWhere(
          (o) => o.id == value,
    );

    selectedOutletName.value = selected.outletName ?? '';
    errorMessageOutletSelection.value = '';
  }

  Future<void> generateQRCode({required String kupanId}) async {
    isLoadingQR(true);
    errorMessageQR.value = '';
    qrCodeUrl.value = null;

    try {
      print("🔄 Generating QR Code for kupan: $kupanId");

      http.Response response =
          await _apiService.generateQRCode(kupanId: kupanId);

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final qrRes = QRCodeRes.fromJson(data);

          if (qrRes.success ?? false) {
            qrCodeUrl.value = qrRes.data?.qrUrl;
            print("✅ QR Code generated: ${qrCodeUrl.value}");
          } else {
            errorMessageQR.value = qrRes.message ?? 'Failed to generate QR code';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageQR.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          if (response.body.startsWith('<!DOCTYPE') ||
              response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageQR.value =
                'Server error (${response.statusCode}): Please try again later';
          } else {
            final error = jsonDecode(response.body);
            errorMessageQR.value = error['message'] ??
                'Failed to generate QR code (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageQR.value =
              'Server error (${response.statusCode}): Please try again';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageQR.value = "Error: ${e.toString()}";
    } finally {
      isLoadingQR(false);
    }
  }

  Future<void> getOutletKupans({required String businessId}) async {
    isLoadingOutletKupans(true);
    errorMessageOutletKupans.value = '';
    outletKupanList.clear();

    try {
      print("📋 Fetching kupans for outlet - BusinessId: $businessId");

      http.Response response =
          await _apiService.getKupanWithFilters(
        vendorId: '', // Will use logged-in user's ID
        businessId: businessId,
        limit: 20,
      );

      print("📍 Response Status: ${response.statusCode}");
      print(
          "📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final kupansRes = KupansListRes.fromJson(data);

          if (kupansRes.success ?? false) {
            outletKupanList.clear();
            outletKupanList.addAll(kupansRes.data ?? []);
            outletKupanList.refresh();
            print("✅ Outlet kupans loaded: ${outletKupanList.length}");
          } else {
            errorMessageOutletKupans.value =
                kupansRes.message ?? 'Failed to fetch coupons';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageOutletKupans.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          if (response.body.startsWith('<!DOCTYPE') ||
              response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageOutletKupans.value =
                'Server error (${response.statusCode}): Please try again later';
          } else {
            final error = jsonDecode(response.body);
            errorMessageOutletKupans.value = error['message'] ??
                'Failed to fetch coupons (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageOutletKupans.value =
              'Server error (${response.statusCode}): Please try again';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageOutletKupans.value = "Error: ${e.toString()}";
    } finally {
      isLoadingOutletKupans(false);
    }
  }
}
