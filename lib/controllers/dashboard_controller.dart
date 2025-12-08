
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';

import '../models/Days.dart';
import '../models/business_outlets_res.dart';
import '../models/create_kupan_res.dart' hide KupanData;
import '../models/kupans_list_res.dart';
import '../models/user_update_res.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  RxList<File>? images = <File>[].obs;
  RxString errorMessageOutletImages = "".obs;
  TextEditingController titleController = TextEditingController();
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
    Days(day: "All"),
  ].obs;
  RxString errorMessageDaySelection = "".obs;

  // Outlet selection properties
  RxString selectedOutletId = "".obs;
  RxString selectedOutletName = "".obs;
  RxString errorMessageOutletSelection = "".obs;

  // Business outlets properties
  var isLoadingOutlets = false.obs;
  var errorMessageOutlets = ''.obs;
  var businessOutletsRes = Rxn<BusinessOutletsRes>();
  RxList<OutletData> outletsList = <OutletData>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUser();
    // Fetch kupans using the new API endpoint
    String vendorId = box.read(StringConst.USER_ID) ?? '';
    if (vendorId.isNotEmpty) {
      getKupanByVendor(vendorId: vendorId, limit: 10);
    }
    getBusinessOutlets();
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
            // print("Success user get");
            final location = userUpdateRes.value?.data?.sellerInfo?.location;

            final fullAddress = [
              location?.address,
              location?.address2,
              location?.landmark,
              location?.city,
              location?.state,
            ]
                .where((e) => e != null && e.toString().trim().isNotEmpty) // remove null/empty
                .join(", ");
            currentAddress(fullAddress);
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
    if (daysList[index].day == "All") {
      // Toggle All
      bool newValue = !daysList[index].isSelected;
      for (var day in daysList) {
        day.isSelected = newValue;
      }
    } else {
      // Toggle individual day
      daysList[index].isSelected = !daysList[index].isSelected;

      // If any one day is unselected, unselect "All"
      if (!daysList[index].isSelected) {
        daysList.firstWhere((d) => d.day == "All").isSelected = false;
      } else {
        // If all individual days selected, then select "All"
        bool allSelected = daysList
            .where((d) => d.day != "All")
            .every((d) => d.isSelected);
        if (allSelected) {
          daysList.firstWhere((d) => d.day == "All").isSelected = true;
        }
      }
    }
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
            images!.clear();
            daysList.forEach((element) => element.isSelected = false);
            daysList.refresh();
            selectedOutletId.value = '';
            selectedOutletName.value = '';
          } else {
            errorMessageCreateKupan.value = createKupanRes.value!.message!;
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageCreateKupan.value = "Invalid response format from server";
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

  Future<void> getBusinessOutlets() async {
    isLoadingOutlets(true);
    errorMessageOutlets.value = '';

    try {
      print("📋 Fetching business outlets");

      http.Response response = await _apiService.getBusinessOutlets();

      print("📍 Response Status: ${response.statusCode}");
      print("📍 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          businessOutletsRes.value = BusinessOutletsRes.fromJson(data);

          if (businessOutletsRes.value!.success!) {
            outletsList.clear();
            outletsList.addAll(businessOutletsRes.value?.data ?? []);
            outletsList.refresh();

            // Auto-select the first outlet if available
            if (outletsList.isNotEmpty) {
              selectedOutletId.value = outletsList[0].id ?? "";
              selectedOutletName.value = outletsList[0].outletName ?? "";
            }
            print("✅ Outlets loaded: ${outletsList.length}");
          } else {
            errorMessageOutlets.value = businessOutletsRes.value!.message ?? 'Unknown error';
          }
        } catch (parseError) {
          print("❌ JSON Parse Error: $parseError");
          errorMessageOutlets.value = 'Invalid response format from server';
        }
      } else {
        // Try to parse error response
        try {
          // Check if response is HTML (error page)
          if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
            print("❌ Server returned HTML error page");
            errorMessageOutlets.value = 'Server error (${response.statusCode}): Please try again later';
          } else {
            // Try to parse as JSON
            final error = jsonDecode(response.body);
            errorMessageOutlets.value = error['message'] ?? 'Failed to fetch outlets (${response.statusCode})';
          }
        } catch (e) {
          print("❌ Error Response Parse Error: $e");
          errorMessageOutlets.value = 'Server error (${response.statusCode}): ${response.statusCode == 500 ? 'Internal server error' : 'Please try again'}';
        }
      }
    } catch (e) {
      print("❌ Error fetching outlets: $e");
      errorMessageOutlets.value = "Error: ${e.toString()}";
    } finally {
      isLoadingOutlets(false);
    }
  }
}