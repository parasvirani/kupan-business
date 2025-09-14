
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';
import '../models/user_update_res.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  RxList<File>? images = <File>[].obs;
  RxString errorMessageOutletImages = "".obs;
  TextEditingController titleController = TextEditingController();
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var userUpdateRes = Rxn<UserUpdateRes>();
  var errorMessage = ''.obs;
  RxString currentAddress = "".obs;
  final box = GetStorage();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUser();
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


}