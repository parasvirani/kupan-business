
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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

  createKupan() async {
    isLoadingCreateKupan.value = true;
    errorMessageCreateKupan.value = '';

    try {
      List<String> days = daysList
          .where((element) => element.isSelected)
          .map((element) => element.day ?? "")
          .where((day) => day.isNotEmpty)
          .toList();

      List<String> images = ["ASd.png", "asdf.jpg"];

      Map<String, dynamic> map = {
        "kupanImages": images,
        "title": titleController.text,
        "kupanDays": days
      };

      print("ASDF:::${jsonEncode(map)}");


      http.Response response = await _apiService.createKupan(map);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        createKupanRes.value = CreateKupanRes.fromJson(data);

        if (createKupanRes.value!.success!) {
          getKupan();
          currentIndex(0);
          titleController.clear();
          daysList.forEach((element) {
            element.isSelected = false;
          });
          daysList.refresh();
        } else {

          errorMessageCreateKupan.value = createKupanRes.value!.message!;
        }
      } else {
        final error = jsonDecode(response.body);
        print("MAP:::${error['message']}");
        errorMessageCreateKupan.value = error['message'] ?? 'Login failed';
      }
    } catch (e) {
      print("Login::$e");
      errorMessageCreateKupan.value = "Error: ${e.toString()}";
    } finally {
      isLoadingCreateKupan.value = false;
    }
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