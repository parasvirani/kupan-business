import 'dart:convert';
import 'dart:io';

import 'package:country_state_city/country_state_city.dart' as country;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import '../models/Days.dart';
import '../models/user_update_res.dart';
import '../models/verify_otp_res.dart';
import '../services/api_service.dart';
import '../utils/appRoutesStrings.dart';

class DetailsController extends GetxController {
  final ApiService _apiService = ApiService();

  final box = GetStorage();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessController = TextEditingController();

  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;

  var isLoading = false.obs;
  var userUpdateRes = Rxn<UserUpdateRes>();
  var errorMessage = ''.obs;

  File? imageFile;
  String? selectedBusinessType;

  RxList<country.State> states = <country.State>[].obs;
  RxList<country.City> cities = <country.City>[].obs;
  country.State? selectedState;
  country.City? selectedCity;
  DateTime? startDay;
  DateTime? endDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final ImagePicker _picker = ImagePicker();
  RxList<File>? images = <File>[].obs;
  RxString errorMessageOutletImages = "".obs;

  RxString cityErrorMessage = "".obs;
  RxString stateErrorMessage = "".obs;
  RxString startDateErrorMessage = "".obs;
  RxString endDateErrorMessage = "".obs;
  RxString startTimeErrorMessage = "".obs;
  RxString endTimeErrorMessage = "".obs;
  DashboardController dashboardController = Get.put(DashboardController());

  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController outletNameController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

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

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getState();
  }

  TimeOfDay parseTime(String timeString) {
    // Clean up hidden Unicode spaces
    timeString = timeString.replaceAll('\u202F', ' ').trim();

    // Split into parts
    final format = DateFormat("h:mm a");
    final dateTime = format.parse(timeString);

    return TimeOfDay.fromDateTime(dateTime);
  }


  getStarted(bool isEdit) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      List<String> days = daysList
          .where((element) => element.isSelected)
          .map((element) => element.day ?? "")
          .where((day) => day.isNotEmpty)
          .toList();
      print("User add successfully ${imageFile?.path}");

      String? profilePic;
      if (imageFile != null) {
        profilePic = await dashboardController.uploadImage(imageFile!);
      }
      print("User add successfully ${profilePic}");

      Map<String, dynamic> map = {
        "profilePic": profilePic ?? "",
        "name": nameController.text,
        "contact": phoneController.text,
        "email": emailController.text,
        "businessName": businessController.text,
        "businessType": selectedBusinessType?.toLowerCase(),
        "outletImages": images?.map((element) => element.path,).toList() ?? [],
        "outletName": outletNameController.text,
        "address": addressLine1Controller.text,
        "address2": addressLine2Controller.text,
        "landmark": landmarkController.text,
        "state": selectedState?.name,
        "city": selectedCity?.name,
        "pincode": zipCodeController.text,
        "outletDay": days,
        "outletTime":
            "${startTime!.format(Get.context!)} - ${endTime!.format(Get.context!)}",
        "role": "vendor",
        "lat": lat.value,
        "long": long.value,
      };

      http.Response response = await _apiService.updateUser(map);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        userUpdateRes.value = UserUpdateRes.fromJson(data);

        if (userUpdateRes.value!.success!) {

          box.write(StringConst.USER_ID, userUpdateRes.value?.data?.id);
          box.write(StringConst.USER_NAME, userUpdateRes.value?.data?.name);
          if (isEdit) {
            dashboardController.getUser();
            Get.back();
          } else {
            Get.offAllNamed(AppRoutes.dashboard);
          }

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
      isLoading.value = false;
    }
  }

  daySelector(int index) {
    daysList[index].isSelected = !daysList[index].isSelected;
    update();
  }

  getState() async {
    var statesAll = await country.getStatesOfCountry('IN');
    states(statesAll);
  }

  getCities(String stateCode) async {
    var city = await country.getStateCities("IN", stateCode);
    cities(city);
  }

  updateState(country.State state) {
    selectedState = state;
    selectedCity = null;
    getCities(state.isoCode);
    update();
  }

  updateCity(country.City city) {
    selectedCity = city;
    // getCities(state.isoCode);
    update();
  }

  updateStateByName(String stateName, {String? cityName}) async {
    // Find the state by name
    var stateList =
        await country.getStatesOfCountry('IN'); // change 'IN' as needed
    country.State state = stateList.firstWhere(
      (s) => s.name.toLowerCase() == stateName.toLowerCase(),
      orElse: () => throw Exception("State not found"),
    );

    selectedState = state;
    selectedCity = null;

    // Load cities for this state
    var cityList =
        await country.getStateCities(state.countryCode, state.isoCode);

    if (cityName != null) {
      final city = cityList.firstWhere(
        (c) => c.name.toLowerCase() == cityName.toLowerCase(),
        orElse: () => throw Exception("City not found"),
      );
      selectedCity = city;
    }

    update();
  }

  Future getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    lat(position.latitude);
    long(position.longitude);

    Placemark place = placemarks[0];

    addressLine1Controller.text = place.street ?? "";
    landmarkController.text = place.subLocality ?? "";
    zipCodeController.text = place.postalCode ?? "";
    updateStateByName(place.administrativeArea ?? "", cityName: place.locality);
    update();
  }

  getAddressFromLatLong(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    lat(latitude);
    long(longitude);
    Placemark place = placemarks[0];

    //             String address = """
    // Address Line 1: ${place.street}
    // Landmark: ${place.subLocality}
    // City: ${place.locality}
    // State: ${place.administrativeArea}
    // Zip Code: ${place.postalCode}
    // Country: ${place.country}
    // """;
    //             print("=====address=====");
    //             print(address);
    // print("=====address=====");
    addressLine1Controller.text = place.street ?? "";
    landmarkController.text = place.subLocality ?? "";
    zipCodeController.text = place.postalCode ?? "";
    updateStateByName(place.administrativeArea ?? "", cityName: place.locality);
    update();
  }

  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      lat(position.latitude);
      long(position.longitude);
      Placemark place = placemarks[0];

      print("Address Line 1: ${place.street}");
      print("Landmark: ${place.subLocality}");
      print("City: ${place.locality}");
      print("State: ${place.administrativeArea}");
      print("Zip Code: ${place.postalCode}");
      print("Country: ${place.country}");
    } catch (e) {
      print(e);
    }
  }
}
