
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';
import '../models/Days.dart';
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

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUser();
    getKupan();
  }

  Future getUser() async {
    isLoading(true);
    errorMessage.value = '';

    try {

      http.Response response = await _apiService.getUser();

      // print("User add successfully ${response.body}");
      if (response.statusCode == 200) {
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
        } else {
          errorMessage.value = userUpdateRes.value!.message!;
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Login failed';
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

  final String uploadUrl = "https://kupan-backend-production-0a1c.up.railway.app/api/v1/uploads";
  final String token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmYxNGUyMmQ5ZmM4ZmM3YjZlZWFhMiIsImlhdCI6MTc1OTY4Mzk1NCwiZXhwIjoxNzYwMjg4NzU0fQ.NVozy8rQeAoQ5TftN-ASB0E01Bsm6v7aAGF3FrOwveA";

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
      List<File> localImages = images!.value; // <-- your selected image files
      List<String> uploadedUrls = [];

      for (var file in localImages) {
        String? url = await uploadImage(file);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      print("✅ Uploaded URLs: $uploadedUrls");

      // ✅ Step 3: Create Kupan payload
      Map<String, dynamic> map = {
        "kupanImages": uploadedUrls,
        "title": titleController.text,
        "kupanDays": days,
      };

      print("📦 Payload: ${jsonEncode(map)}");

      // ✅ Step 4: Call createKupan API
      http.Response response = await _apiService.createKupan(map);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        createKupanRes.value = CreateKupanRes.fromJson(data);

        if (createKupanRes.value!.success!) {
          getKupan();
          currentIndex(0);
          titleController.clear();
          images!.clear();
          daysList.forEach((element) => element.isSelected = false);
          daysList.refresh();
        } else {
          errorMessageCreateKupan.value = createKupanRes.value!.message!;
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessageCreateKupan.value = error['message'] ?? 'Failed to create kupan';
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

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.headers['Authorization'] = token;

      // detect file type
      String ext = imageFile.path.split('.').last.toLowerCase();
      String mainType = (ext == 'mp4' || ext == 'mov') ? 'video' : 'image';

      request.files.add(await http.MultipartFile.fromPath(
        'files',
        imageFile.path,
        contentType: MediaType(mainType, ext),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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

      http.Response response = await _apiService.getKupan();

      // print("User add successfully ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        kupansListRes.value = KupansListRes.fromJson(data);

        if (kupansListRes.value!.success!) {
          // print("Success user get");
          kupanList.clear();
          kupanList.addAll(kupansListRes.value?.data ?? []);
          kupanList.refresh();
        } else {
          errorMessageGetKupan.value = kupansListRes.value!.message!;
        }
      } else {
        final error = jsonDecode(response.body);
        print("Error::${error}");
        errorMessageGetKupan.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      print("Login::$e");
      errorMessageGetKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingGetKupan(false);
    }
  }
}