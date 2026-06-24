
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';

import '../models/Days.dart';
import '../models/business_outlets_res.dart';
import '../models/create_kupan_res.dart' hide KupanData;
import '../models/kupans_list_res.dart';
import '../models/redemptions_res.dart';
import '../models/user_update_res.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';
import '../services/redemptions_service.dart';

class DashboardController extends GetxController {
  RxList<File>? images = <File>[].obs;
  RxString errorMessageOutletImages = "".obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var userUpdateRes = Rxn<UserUpdateRes>();
  RxInt currentIndex = 0.obs;

  var errorMessage = ''.obs;
  RxString currentAddress = "".obs;
  final box = GetStorage();

  var isLoadingCreateKupan = false.obs;
  var errorMessageCreateKupan = ''.obs;
  var createKupanRes = Rxn<CreateKupanRes>();

  var isLoadingGetKupan = false.obs;
  var errorMessageGetKupan = ''.obs;
  var kupansListRes = Rxn<KupansListRes>();
  RxList<KupanData> kupanList = <KupanData>[].obs;

  RxList<Days> daysList = <Days>[
    Days(day: "Sunday"),
    Days(day: "Monday"),
    Days(day: "Tuesday"),
    Days(day: "Wednesday"),
    Days(day: "Thursday"),
    Days(day: "Friday"),
    Days(day: "Saturday"),
  ].obs;
  RxString errorMessageDaySelection = "".obs;

  // Outlet selection properties
  RxString selectedOutletId = "".obs;
  RxString selectedOutletName = "".obs;
  RxString errorMessageOutletSelection = "".obs;

  // Coupon type selection
  RxString selectedKupanType = "".obs;
  RxString errorMessageKupanType = "".obs;

  // Business outlets properties
  var isLoadingOutlets = false.obs;
  var errorMessageOutlets = ''.obs;
  var businessOutletsRes = Rxn<BusinessOutletsRes>();

  // Redemptions properties
  final RedemptionsService _redemptionsService = RedemptionsService();
  var isLoadingRedemptions = false.obs;
  var errorMessageRedemptions = ''.obs;
  var dailyRedemptions = Rxn<RedemptionsResponse>();
  RxInt todayRedemptionCount = 0.obs;
  
  // Redemption ranges
  var weeklyRedemptions = Rxn<RedemptionsResponse>();
  var monthlyRedemptions = Rxn<RedemptionsResponse>();
  var allTimeRedemptions = Rxn<RedemptionsResponse>();
  RxString selectedRedemptionRange = 'weekly'.obs;
  RxInt weeklyCount = 0.obs;
  RxInt monthlyCount = 0.obs;
  RxInt allTimeCount = 0.obs;

  // Today's redemptions per kupanId (for daily limit display)
  RxMap<String, int> todayRedemptionsByKupan = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getUser();
    fetchCurrentLocation();
    _registerFcmToken();
    String vendorId = box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      getVendorKupans(vendorId: vendorId);
      fetchAllRedemptionRanges(vendorId: vendorId);
      fetchTodayRedemptionsByKupan(vendorId: vendorId);
    }
  }

  Future<void> _registerFcmToken() async {
    try {
      final token = await PushService.getFcmToken();
      if (token != null && token.isNotEmpty) {
        await _apiService.updateFcmToken(token);
      }
    } catch (_) {}
  }

  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return;
      final p = placemarks.first;

      final parts = [
        p.thoroughfare,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e.trim().isNotEmpty).toList();

      if (parts.isNotEmpty) {
        currentAddress.value = parts.join(', ');
      }
    } catch (_) {
      // GPS unavailable — currentAddress stays as whatever getUser() set
    }
  }

  Future getUser() async {
    isLoading(true);
    errorMessage.value = '';

    try {
      print("👤 Fetching user data...");

      http.Response response = await _apiService.getUser();

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      // print("User add successfully ${response.body}");
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          userUpdateRes.value = UserUpdateRes.fromJson(data);

          if (userUpdateRes.value!.success!) {
            // Try sellerInfo.location first, then fall back to sellerBusinesses[0].location
            final location = userUpdateRes.value?.data?.sellerInfo?.location;
            Map<String, dynamic>? rawLocation;
            if (location == null) {
              final rawData = data['data'];
              if (rawData is Map) {
                final businesses = rawData['sellerBusinesses'];
                if (businesses is List && businesses.isNotEmpty) {
                  final first = businesses.first;
                  if (first is Map) {
                    rawLocation = (first['location'] as Map<String, dynamic>?);
                  }
                }
              }
            }

            final address = location?.address ?? rawLocation?['address']?.toString();
            final address2 = location?.address2 ?? rawLocation?['address2']?.toString();
            final landmark = location?.landmark ?? rawLocation?['landmark']?.toString();
            final city = location?.city ?? rawLocation?['city']?.toString();
            final state = location?.state ?? rawLocation?['state']?.toString();

            final fullAddress = [address, address2, landmark, city, state]
                .where((e) => e != null && e.trim().isNotEmpty)
                .join(', ');

            if (fullAddress.isNotEmpty && currentAddress.value.isEmpty) {
              currentAddress.value = fullAddress;
            }
            print("✅ User loaded successfully");
          } else {
            errorMessage.value = userUpdateRes.value!.message!;
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessage.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          // Check if response is HTML (error page)
          if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessage.value = 'Server error (${response.statusCode}): Please try again later';
          } else {
            // Try to parse as JSON
            final error = jsonDecode(response.body);
            errorMessage.value = error['message'] ?? 'Login failed (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessage.value = 'Server error (${response.statusCode}): ${response.statusCode == 500 ? 'Internal server error' : 'Please try again'}';
        }
      }
    } catch (e) {
      print("Login::$e");
      errorMessage.value = "Error: ${e.toString()}";
    } finally {
      isLoading(false);
    }
  }

  logoutUser() async {
    await box.remove(StringConst.TOKEN);
    await box.remove(StringConst.USER_NAME);
    await box.remove(StringConst.USER_ID);
    Get.offAllNamed(AppRoutes.login);
  }

  daySelector(int index) {
    daysList[index].isSelected = !daysList[index].isSelected;
    daysList.refresh();
  }

  Future<void> createKupan() async {
    isLoadingCreateKupan.value = true;
    errorMessageCreateKupan.value = '';

    try {
      // ✅ Step 1: Prepare selected days
      List<String> days = daysList
          .where((element) => element.isSelected)
          .map((element) => element.day ?? "")
          .where((day) => day.isNotEmpty)
          .toList();

      // ✅ Step 2: Upload multiple images & collect URLs
      List<File> localImages = images ?? []; // <-- your selected image files
      List<String> uploadedUrls = [];

      for (var file in localImages) {
        String? url = await uploadImage(file);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      print("✅ Uploaded URLs: $uploadedUrls");

      // ✅ Step 3: Get vendorId and businessId
      String vendorId = box.read(StringConst.USER_ID) ?? '';
      String businessId = selectedOutletId.value;

      print("📋 DEBUG - Vendor ID: $vendorId");
      print("📋 DEBUG - Business ID (Selected Outlet): $businessId");

      // ✅ Step 4: Create Kupan payload
      Map<String, dynamic> map = {
        "kupanImages": uploadedUrls,
        "title": titleController.text,
        "description": descriptionController.text,
        "kupanType": selectedKupanType.value,
        "kupanDays": days,
        "vendorId": vendorId,
        "businessId": businessId,
      };

      print("📦 Payload: ${jsonEncode(map)}");

      // ✅ Step 5: Call createKupan API
      http.Response response = await _apiService.createKupan(map);

      print("📍 Response Status Code: ${response.statusCode}");
      print("📍 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          createKupanRes.value = CreateKupanRes.fromJson(data);

          if (createKupanRes.value!.success!) {
            // Refresh kupan list after successful creation
            String vendorId = box.read(StringConst.USER_ID) ?? '';
            if (vendorId.isNotEmpty) {
              getKupanByVendor(vendorId: vendorId, limit: 10);
            }
            currentIndex(0);
            titleController.clear();
            descriptionController.clear();
            images!.clear();
            daysList.forEach((element) => element.isSelected = false);
            daysList.refresh();
            selectedOutletId.value = '';
            selectedOutletName.value = '';
            selectedKupanType.value = '';
          } else {
            errorMessageCreateKupan.value = createKupanRes.value!.message!;
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageCreateKupan.value = "Invalid response format from server";
        } finally {
          isLoadingCreateKupan.value = false;
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          errorMessageCreateKupan.value = error['message'] ?? 'Failed to create kupan (${response.statusCode})';
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageCreateKupan.value = 'Server error: ${response.statusCode}. Please try again.';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageCreateKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingCreateKupan.value = false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        print("⚠️ File not found: ${imageFile.path}");
        return null;
      }


      http.Response response = await _apiService.uploadImage(imageFile: imageFile);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        } else if (data['data'] != null) {
          return data['data'];
        }
      } else {
        print("❌ Upload failed: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Upload error: $e");
    }
    return null;
  }

  Future getKupan() async {
    isLoadingGetKupan(true);
    errorMessageGetKupan.value = '';

    try {
      print("📋 Fetching kupans using old endpoint");

      http.Response response = await _apiService.getKupan();

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          kupansListRes.value = KupansListRes.fromJson(data);

          if (kupansListRes.value!.success!) {
            kupanList.clear();
            kupanList.addAll(kupansListRes.value?.data ?? []);
            kupanList.refresh();
            print("✅ Kupans loaded: ${kupanList.length}");
          } else {
            errorMessageGetKupan.value = kupansListRes.value!.message ?? 'Unknown error';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageGetKupan.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          // Check if response is HTML (error page)
          if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageGetKupan.value = 'Server error (${response.statusCode}): Please try again later';
          } else {
            // Try to parse as JSON
            final error = jsonDecode(response.body);
            errorMessageGetKupan.value = error['message'] ?? 'Failed to fetch kupans (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageGetKupan.value = 'Server error (${response.statusCode}): ${response.statusCode == 500 ? 'Internal server error' : 'Please try again'}';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageGetKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingGetKupan(false);
    }
  }

  Future getKupanWithFilters({
    required String vendorId,
    required String businessId,
    int limit = 10,
  }) async {
    isLoadingGetKupan(true);
    errorMessageGetKupan.value = '';

    try {
      print("📋 Fetching kupans - VendorId: $vendorId, BusinessId: $businessId, Limit: $limit");

      http.Response response = await _apiService.getKupanWithFilters(
        vendorId: vendorId,
        businessId: businessId,
        limit: limit,
      );

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          kupansListRes.value = KupansListRes.fromJson(data);

          if (kupansListRes.value!.success!) {
            kupanList.clear();
            kupanList.addAll(kupansListRes.value?.data ?? []);
            kupanList.refresh();
            print("✅ Kupans loaded: ${kupanList.length}");
          } else {
            errorMessageGetKupan.value = kupansListRes.value!.message ?? 'Unknown error';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageGetKupan.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          // Check if response is HTML (error page)
          if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageGetKupan.value = 'Server error (${response.statusCode}): Please try again later';
          } else {
            // Try to parse as JSON
            final error = jsonDecode(response.body);
            errorMessageGetKupan.value = error['message'] ?? 'Failed to fetch kupans (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageGetKupan.value = 'Server error (${response.statusCode}): ${response.statusCode == 500 ? 'Internal server error' : 'Please try again'}';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageGetKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingGetKupan(false);
    }
  }

  Future<void> getKupanByVendor({
    required String vendorId,
    int limit = 10,
  }) async {
    isLoadingGetKupan(true);
    errorMessageGetKupan.value = '';

    try {
      print("📋 Fetching kupans by vendor - VendorId: $vendorId, Limit: $limit");

      http.Response response = await _apiService.getKupanByVendor(
        vendorId: vendorId,
        limit: limit,
      );

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          kupansListRes.value = KupansListRes.fromJson(data);

          if (kupansListRes.value!.success!) {
            kupanList.clear();
            kupanList.addAll(kupansListRes.value?.data ?? []);
            kupanList.refresh();
            print("✅ Kupans loaded: ${kupanList.length}");
          } else {
            errorMessageGetKupan.value = kupansListRes.value!.message ?? 'Unknown error';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageGetKupan.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          // Check if response is HTML (error page)
          if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageGetKupan.value = 'Server error (${response.statusCode}): Please try again later';
          } else {
            // Try to parse as JSON
            final error = jsonDecode(response.body);
            errorMessageGetKupan.value = error['message'] ?? 'Failed to fetch kupans (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageGetKupan.value = 'Server error (${response.statusCode}): ${response.statusCode == 500 ? 'Internal server error' : 'Please try again'}';
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessageGetKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingGetKupan(false);
    }
  }

 
  // ------------------------------------------------------------------
  // GET VENDOR KUPANS via /kupan/vendor/:id (flat list, new endpoint)
  // ------------------------------------------------------------------
  Future<void> getVendorKupans({required String vendorId}) async {
    isLoadingGetKupan(true);
    errorMessageGetKupan.value = '';

    try {
      http.Response response = await _apiService.getKupan();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Response is { success, data: [...] }
        if (data['success'] == true && data['data'] is List) {
          kupanList.clear();
          kupanList.addAll(
            (data['data'] as List).map((x) => KupanData.fromJson(x as Map<String, dynamic>)),
          );
          kupanList.refresh();
        } else {
          errorMessageGetKupan.value = data['message'] ?? 'Failed to load kupans';
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          errorMessageGetKupan.value = error['message'] ?? 'Failed to load kupans (${response.statusCode})';
        } catch (_) {
          errorMessageGetKupan.value = 'Server error: ${response.statusCode}';
        }
      }
    } catch (e) {
      errorMessageGetKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingGetKupan(false);
    }
  }

  // ------------------------------------------------------------------
  // DELETE KUPAN
  // ------------------------------------------------------------------
  Future<void> deleteKupan(String kupanId) async {
    try {
      http.Response response = await _apiService.deleteKupan(kupanId);
      if (response.statusCode == 200) {
        kupanList.removeWhere((k) => k.id == kupanId);
        kupanList.refresh();
        Get.snackbar(
          'Success',
          'Coupon deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete coupon',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  // ------------------------------------------------------------------
  // TODAY REDEMPTIONS per kupan (for daily limit display)
  // ------------------------------------------------------------------
  Future<void> fetchTodayRedemptionsByKupan({required String vendorId}) async {
    try {
      final response = await _redemptionsService.getRedemptions(
        vendorId: vendorId,
        range: 'today',
      );

      if (response != null && response.success) {
        final map = <String, int>{};
        for (var item in response.data) {
          map[item.kupanId] = item.totalRedemptions.toInt();
        }
        todayRedemptionsByKupan.value = map;
      }
    } catch (_) {}
  }

  Future<void> fetchAllRedemptionRanges({required String vendorId}) async {
    await Future.wait([
      _fetchRedemptionsForRange(vendorId: vendorId, range: 'weekly'),
      _fetchRedemptionsForRange(vendorId: vendorId, range: 'monthly'),
      _fetchRedemptionsForRange(vendorId: vendorId, range: 'allTime'),
    ]);
    setRedemptionRange('weekly');
  }

  Future<void> _fetchRedemptionsForRange({
    required String vendorId,
    required String range,
  }) async {
    try {
      print("🔄 Fetching $range redemptions for vendor: $vendorId");

      final response = await _redemptionsService.getRedemptions(
        vendorId: vendorId,
        range: range,
      );

      if (response != null && response.success) {
        int totalCount = 0;
        print("📦 $range Redemption items: ${response.data.length}");
        for (var item in response.data) {
          print("  - ${item.title}: ${item.totalRedemptions}");
          totalCount += item.totalRedemptions.toInt();
        }
        
        // Store the response based on range
        if (range == 'weekly') {
          weeklyRedemptions.value = response;
          weeklyCount.value = totalCount;
        } else if (range == 'monthly') {
          monthlyRedemptions.value = response;
          monthlyCount.value = totalCount;
        } else if (range == 'allTime') {
          allTimeRedemptions.value = response;
          allTimeCount.value = totalCount;
        }
        
        print("✅ $range Redemptions loaded: $totalCount");
      } else {
        errorMessageRedemptions.value = response?.message ?? 'Failed to fetch $range redemptions';
        print("❌ $range Response not successful: ${response?.message}");
      }
    } catch (e) {
      print("❌ Error fetching $range redemptions: $e");
      errorMessageRedemptions.value = "Error: ${e.toString()}";
    } finally {
      isLoadingRedemptions.value = false;
    }
  }

  void setRedemptionRange(String range) {
    selectedRedemptionRange.value = range;
    
    // Update today's count based on selected range
    if (range == 'weekly') {
      todayRedemptionCount.value = weeklyCount.value;
    } else if (range == 'monthly') {
      todayRedemptionCount.value = monthlyCount.value;
    } else if (range == 'allTime') {
      todayRedemptionCount.value = allTimeCount.value;
    }
    
    print("🔀 Redemption range changed to: $range");
  }

  Future<void> fetchTodayRedemptions({required String vendorId}) async {
    try {
      isLoadingRedemptions.value = true;
      errorMessageRedemptions.value = '';

      print("🔄 Fetching redemptions for vendor: $vendorId");

      final response = await _redemptionsService.getRedemptions(
        vendorId: vendorId,
        range: 'weekly',
      );

      if (response != null && response.success && response.data.isNotEmpty) {
        dailyRedemptions.value = response;
        // Calculate total redemptions for today
        int totalCount = 0;
        print("📦 Redemption items: ${response.data.length}");
        for (var item in response.data) {
          print("  - ${item.title}: ${item.totalRedemptions}");
          totalCount += item.totalRedemptions.toInt();
        }
        todayRedemptionCount.value = totalCount;
        print("✅ Redemptions loaded: $totalCount");
      } else if (response != null && response.success && response.data.isEmpty) {
        print("⚠️  Response successful but no data found");
        todayRedemptionCount.value = 0;
        dailyRedemptions.value = response;
      } else {
        errorMessageRedemptions.value = response?.message ?? 'Failed to fetch redemptions';
        print("❌ Response not successful: ${response?.message}");
        todayRedemptionCount.value = 0;
      }
    } catch (e) {
      print("❌ Error fetching redemptions: $e");
      errorMessageRedemptions.value = "Error: ${e.toString()}";
      todayRedemptionCount.value = 0;
    } finally {
      isLoadingRedemptions.value = false;
    }
  }
}