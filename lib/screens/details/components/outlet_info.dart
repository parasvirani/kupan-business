import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kupan_business/common_view/city_sheet.dart';
import 'package:kupan_business/common_view/common_date_picker.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/common_view/common_time_picker.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/controllers/details_controller.dart';
import 'package:kupan_business/utils/utils.dart';
import 'package:country_state_city/country_state_city.dart' as country;
import '../../../common_view/common_button.dart';
import '../../../common_view/common_dropdown.dart';
import '../../../common_view/common_textfield.dart';
import '../../../common_view/state_sheet.dart';
import '../../../controllers/dashboard_controller.dart';
import 'address_search_bottom_sheet.dart';

class OutletInfo extends StatefulWidget {
  bool isEdit;
  OutletInfo({super.key, this.isEdit = false});

  @override
  State<OutletInfo> createState() => _OutletInfoState();
}

class _OutletInfoState extends State<OutletInfo> {
  DetailsController controller = Get.put(DetailsController());
  DashboardController dashboardController = Get.put(DashboardController());
  final _fromKey = GlobalKey<FormState>();

  File? _imageFile;
  final List<String> businessTypes = [
    'restaurant',
    'cafe',
    'hotel'
  ];

  bool validateAll() {
    bool isValid = _fromKey.currentState!.validate();

    // Dropdown validations
    if (controller.selectedState == null) {
      controller.stateErrorMessage("Please select state");
      isValid = false;
    } else {
      controller.stateErrorMessage("");
    }

    if (controller.selectedCity == null) {
      controller.cityErrorMessage("Please select city");
      isValid = false;
    } else {
      controller.cityErrorMessage("");
    }

    // if (controller.startDay == null) {
    //   controller.startDateErrorMessage("Please select start date");
    //   isValid = false;
    // } else {
    //   controller.startDateErrorMessage("");
    // }

    // if (controller.endDay == null) {
    //   controller.endDateErrorMessage("Please select end date");
    //   isValid = false;
    // } else {
    //   controller.endDateErrorMessage("");
    //   controller.endDateErrorMessage("");
    // }

    if (controller.startTime == null) {
      controller.startTimeErrorMessage("Please select start time");
      isValid = false;
    } else {
      controller.startTimeErrorMessage("");
    }

    if (controller.endTime == null) {
      controller.endTimeErrorMessage("Please select end time");
      isValid = false;
    } else {
      controller.endTimeErrorMessage("");
    }

    if (controller.images?.isEmpty ?? true) {
      controller.errorMessageOutletImages("Please select image");
      isValid = false;
    } else {
      controller.errorMessageOutletImages("");
    }

    bool isAnySelected = controller.daysList.any((data) => data.isSelected);
    if (!isAnySelected) {
      controller.errorMessageDaySelection("Please select at least one day");
      isValid = false;
    } else {
      controller.errorMessageDaySelection("");
    }


    return isValid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  getDetails() {
    if (widget.isEdit) {
      controller.outletNameController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletName ?? "";
      controller.selectedBusinessType = dashboardController.userUpdateRes.value?.data?.sellerInfo?.businessType ?? "";
      controller.addressLine1Controller.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.address ?? "";
      controller.addressLine2Controller.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.address2 ?? "";
      controller.landmarkController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.landmark ?? "";
      controller.updateStateByName(dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.state ?? "", cityName: dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.city ?? "");
      controller.zipCodeController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.pincode ?? "";
      final apiDays = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletDay ?? [];

      for (var day in controller.daysList) {
        day.isSelected = apiDays.contains(day.day);
      }
      controller.daysList.refresh();

      String apiTime = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletTime ?? "9 AM - 9 PM";
      final parts = apiTime.split('-');

      if (parts.length == 2) {
        controller.startTime = controller.parseTime(parts[0].trim());
        controller.endTime = controller.parseTime(parts[1].trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailsController>(
      builder: (controller) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => Form(
              key: _fromKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size(20)),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: ColorConst.primary.withOpacity(0.03),
                      border: Border.all(
                        color: ColorConst.primary.withOpacity(0.5),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: controller.images?.isNotEmpty ?? false
                        ? PageView.builder(
                            itemCount: controller.images?.length,
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(controller.images?[index].path ?? ""),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 150,
                                  ),
                                  Positioned(
                                    right: size(10),
                                    top: size(10),
                                    child: InkWell(
                                      onTap: () {
                                        controller.images?.removeAt(index);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(size(5)),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Icon(Icons.close)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(ImageConst.icUpload),
                              const SizedBox(height: 8),
                              CommonText(
                                text: 'Upload Image',
                                fontSize: size(14),
                                color: ColorConst.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: size(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: controller
                            .errorMessageOutletImages.value.isNotEmpty,
                        child: CommonText(
                          text: controller.errorMessageOutletImages.value,
                          color: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.images!.length < 4
                            ? () {
                                _showPickerOptions();
                              }
                            : null,
                        child: CommonText(
                          text: "Add Image ${controller.images?.length}/4",
                          color: controller.images!.length < 4
                              ? ColorConst.primary
                              : ColorConst.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  CommonTextfield(
                    controller: controller.outletNameController,
                    hintText: 'Outlet Name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.business_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter outlet name.";
                      } else if (value.length < 2) {
                        return "Outlet name must be at least 2 characters long.";
                      }
                      // Allow letters, numbers, spaces, and & . -
                      String pattern = r'^[a-zA-Z0-9&.\-\s]+$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return "Outlet name can only contain letters, numbers, spaces, &, ., and -.";
                      }
                      return null; // input is valid
                    },
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: size(12)),
                  CommonDropdown(
                    value: controller.selectedBusinessType,
                    hintText: 'Select Business Type',
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.business_outlined),
                    ),
                    items: businessTypes,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please select a business type.";
                      }
                      return null;
                    },
                    onChanged: (value) {
                        controller.selectedBusinessType = value;
                    },
                  ),
                  SizedBox(height: size(12)),
                  Row(
                    children: [
                      SvgPicture.asset(ImageConst.ic_location),
                      SizedBox(
                        width: size(6),
                      ),
                      CommonText(
                        text: "OUTLET ADDRESS",
                        color: ColorConst.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: size(12),
                      )
                    ],
                  ),
                  SizedBox(height: size(12)),
                  InkWell(
                    onTap: () async {
                      try {
                        await controller.getCurrentLocation();
                      } catch (e) {
                        print("Error: $e");
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(ImageConst.ic_current_location),
                        SizedBox(
                          width: size(6),
                        ),
                        CommonText(
                          text: "Use current location",
                          color: ColorConst.primary,
                          fontSize: size(16),
                          fontWeight: FontWeight.w600,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: size(12)),
                  CommonTextfield(
                    controller: controller.addressLine1Controller,
                    hintText: 'Address line 1',
                    readOnly: true,
                    keyboardType: TextInputType.name,
                    onTap: () {
                      _showAddressSearch();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select an address.";
                      }
                      return null; // input is valid
                    },
                  ),
                  SizedBox(height: size(12)),
                  CommonTextfield(
                    controller: controller.addressLine2Controller,
                    hintText: 'Address line 2',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: size(12)),
                  CommonTextfield(
                    controller: controller.landmarkController,
                    hintText: 'Landmark',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: size(12)),
                  InkWell(
                    onTap: () {
                      Get.bottomSheet(StateSheet());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: controller.stateErrorMessage.isNotEmpty
                                ? Colors.red
                                : ColorConst.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedState?.name ?? "State",
                              style: TextStyle(
                                  fontSize: size(16),
                                  color: ColorConst.dark,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                          SizedBox(
                            width: size(12),
                          ),
                          SvgPicture.asset(
                            ImageConst.icDown,
                            width: size(24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.stateErrorMessage.isNotEmpty) ...[
                    SizedBox(height: size(5)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: CommonText(
                        text: controller.stateErrorMessage.value,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  SizedBox(height: size(12)),
                  InkWell(
                    onTap: () {
                      Get.bottomSheet(CitySheet());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: controller.stateErrorMessage.isNotEmpty
                                ? Colors.red
                                : ColorConst.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedCity?.name ?? "City",
                              style: TextStyle(
                                  fontSize: size(16),
                                  color: ColorConst.dark,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                          SizedBox(
                            width: size(12),
                          ),
                          SvgPicture.asset(
                            ImageConst.icDown,
                            width: size(24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.cityErrorMessage.isNotEmpty) ...[
                    SizedBox(height: size(5)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: CommonText(
                        text: controller.cityErrorMessage.value,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  SizedBox(height: size(12)),
                  CommonTextfield(
                    controller: controller.zipCodeController,
                    hintText: 'Zip Code',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a Zip Code.";
                      } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                        return "Please enter a valid 6-digit Zip Code.";
                      }
                      return null; // ✅ valid
                    },
                  ),
                  SizedBox(height: size(12)),
                  Row(
                    children: [
                      SvgPicture.asset(ImageConst.icTime),
                      SizedBox(
                        width: size(6),
                      ),
                      CommonText(
                        text: "OUTLET OPEN",
                        color: ColorConst.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: size(12),
                      )
                    ],
                  ),
                  SizedBox(height: size(12)),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           CommonDatePicker(
                  //             value: controller.startDay,
                  //             hintText: 'Start Date',
                  //             isError:
                  //                 controller.startDateErrorMessage.isNotEmpty,
                  //             onTap: () => _selectDate(context, true),
                  //           ),
                  //           if (controller
                  //               .startDateErrorMessage.isNotEmpty) ...[
                  //             SizedBox(height: size(5)),
                  //             Padding(
                  //               padding:
                  //                   EdgeInsets.symmetric(horizontal: size(10)),
                  //               child: CommonText(
                  //                 text: controller.startDateErrorMessage.value,
                  //                 color: Colors.red,
                  //               ),
                  //             ),
                  //           ],
                  //         ],
                  //       ),
                  //     ),
                  //     SizedBox(width: size(12)),
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           CommonDatePicker(
                  //             value: controller.endDay,
                  //             hintText: 'End Date',
                  //             isError:
                  //                 controller.endDateErrorMessage.isNotEmpty,
                  //             onTap: () => _selectDate(context, false),
                  //           ),
                  //           if (controller.endDateErrorMessage.isNotEmpty) ...[
                  //             SizedBox(height: size(5)),
                  //             Padding(
                  //               padding:
                  //                   EdgeInsets.symmetric(horizontal: size(10)),
                  //               child: CommonText(
                  //                 text: controller.startDateErrorMessage.value,
                  //                 color: Colors.red,
                  //               ),
                  //             ),
                  //           ],
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2,
                      crossAxisSpacing: size(10),
                      mainAxisSpacing: size(10)
                    ),
                    itemCount: controller.daysList.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        controller.daySelector(index);
                      },
                      child: Container(
                        alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size(8)),
                              border:
                                  Border.all(color: ColorConst.border, width: controller.daysList[index].isSelected ? 0 : 1),
                              color: controller.daysList[index].isSelected ? ColorConst.primary : Colors.white),
                          child: CommonText(
                            text: controller.daysList[index].day ?? "",
                            color: controller.daysList[index].isSelected ? Colors.white : Colors.black,
                          )),
                    ),
                  ),
                  Visibility(
                    visible: controller
                        .errorMessageDaySelection.value.isNotEmpty,
                    child: CommonText(
                      text: controller.errorMessageDaySelection.value,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: size(12)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTimePicker(
                              value: controller.startTime,
                              hintText: 'Start Time',
                              isError:
                                  controller.startTimeErrorMessage.isNotEmpty,
                              onTap: () => _selectTime(context, true),
                            ),
                            if (controller
                                .startTimeErrorMessage.isNotEmpty) ...[
                              SizedBox(height: size(5)),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: size(10)),
                                child: CommonText(
                                  text: controller.startTimeErrorMessage.value,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: size(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTimePicker(
                              value: controller.endTime,
                              hintText: 'End Time',
                              isError:
                                  controller.endTimeErrorMessage.isNotEmpty,
                              onTap: () => _selectTime(context, false),
                            ),
                            if (controller.endTimeErrorMessage.isNotEmpty) ...[
                              SizedBox(height: size(5)),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: size(10)),
                                child: CommonText(
                                  text: controller.endTimeErrorMessage.value,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (controller.errorMessage.isNotEmpty) ...[
                    SizedBox(height: size(5)),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: size(10)),
                      child: CommonText(
                        text: controller.errorMessage.value,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  SizedBox(height: size(12)),
                  SizedBox(
                    width: Get.width,
                    child: CommonButton(
                      isLoading: controller.isLoading.value,
                        onPressed: () {
                          if (validateAll()) {
                            controller.getStarted(widget.isEdit);
                          }
                        },
                        text: widget.isEdit ? "Update" : 'Get Started'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select Image'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: CommonText(
              text: 'Choose from Gallery',
              color: Colors.black,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: CommonText(text: 'Take a Photo', color: Colors.black),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: CommonText(text: 'Cancel', color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // Crop the image after picking
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        // setState(() {
        _imageFile = File(croppedFile.path);
        // });
        controller.images?.add(_imageFile!);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked;
    final DateTime now = DateTime.now();
    final DateTime minDate = DateTime(now.year, now.month, now.day);
    final DateTime initialDate = isStartDate && controller.startDay != null
        ? controller.startDay!
        : (!isStartDate && controller.endDay != null
            ? controller.endDay!
            : minDate);

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (picked != null) {
                        // setState(() {
                        if (isStartDate) {
                          controller.startDay = picked;
                        } else {
                          controller.endDay = picked;
                        }
                        // });
                      }
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: minDate,
                maximumDate: minDate.add(const Duration(days: 365)),
                onDateTimeChanged: (DateTime value) {
                  picked = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    DateTime? picked;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (picked != null) {
                        // setState(() {
                        TimeOfDay timeOfDay = TimeOfDay.fromDateTime(picked!);
                        if (isStartTime) {
                          controller.startTime = timeOfDay;
                        } else {
                          controller.endTime = timeOfDay;
                        }
                        controller.update();
                        // });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime.now(),
                use24hFormat: false,
                onDateTimeChanged: (DateTime value) {
                  picked = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSearchBottomSheet(
        onAddressSelected: (address) {
          setState(() {
            controller.addressLine1Controller.text = address;
          });
        },
      ),
    );
  }
}
