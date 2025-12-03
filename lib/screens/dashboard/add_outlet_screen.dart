import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kupan_business/common_view/city_sheet.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/controllers/details_controller.dart';
import 'package:kupan_business/models/user_businesses_res.dart';
import 'package:kupan_business/utils/utils.dart';
import '../../common_view/common_button.dart';
import '../../common_view/common_dropdown.dart';
import '../../common_view/common_textfield.dart';
import '../../common_view/state_sheet.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/my_outlets_controller.dart';
import '../details/components/address_search_bottom_sheet.dart';

class AddOutletScreen extends StatefulWidget {
  final bool isEditMode;
  final SellerBusiness? outletData;

  const AddOutletScreen({
    super.key,
    this.isEditMode = false,
    this.outletData,
  });

  @override
  State<AddOutletScreen> createState() => _AddOutletScreenState();
}

class _AddOutletScreenState extends State<AddOutletScreen> {
  DetailsController controller = Get.put(DetailsController());
  DashboardController dashboardController = Get.put(DashboardController());
  final _fromKey = GlobalKey<FormState>();
  List<String> existingImageUrls = []; // Store existing image URLs for edit mode

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

    // For edit mode, allow if there are existing images or new images
    // For add mode, require at least one image
    final totalImages = (controller.images?.length ?? 0) + existingImageUrls.length;
    if (totalImages == 0) {
      controller.errorMessageOutletImages("Please select image");
      isValid = false;
    } else {
      controller.errorMessageOutletImages("");
    }

    if (controller.openTime == null) {
      controller.startTimeErrorMessage("Please select open time");
      isValid = false;
    } else {
      controller.startTimeErrorMessage("");
    }

    if (controller.closeTime == null) {
      controller.endTimeErrorMessage("Please select close time");
      isValid = false;
    } else {
      controller.endTimeErrorMessage("");
    }

    return isValid;
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() async {
    if (widget.isEditMode && widget.outletData != null) {
      // Populate form with existing outlet data
      final outlet = widget.outletData!;
      controller.businessController.text = outlet.businessName ?? '';
      controller.outletContactController.text = outlet.outletNumber ?? '';
      controller.outletNameController.text = outlet.outletName ?? '';
      controller.addressLine1Controller.text = outlet.location?.address ?? '';
      controller.landmarkController.text = outlet.location?.address ?? '';
      controller.zipCodeController.text = outlet.location?.pincode ?? '';
      controller.selectedBusinessType = outlet.businessType;
      
      // Store existing image URLs
      existingImageUrls = outlet.outletImages ?? [];
      
      // Populate state and city
      if (outlet.location?.state != null && outlet.location?.city != null) {
        try {
          await controller.updateStateByName(
            outlet.location!.state!,
            cityName: outlet.location!.city,
          );
          // Trigger UI rebuild after state/city are set
          if (mounted) {
            setState(() {});
          }
        } catch (e) {
          print("Error setting state/city: $e");
        }
      }
      
      // Parse time from outletTime (format: "9AM-9PM" or "9:00 AM - 9:00 PM")
      if (outlet.outletTime != null && outlet.outletTime!.isNotEmpty) {
        final times = outlet.outletTime!.split('-');
        if (times.length == 2) {
          try {
            controller.openTime = _parseTimeString(times[0].trim());
            controller.closeTime = _parseTimeString(times[1].trim());
            // Trigger UI rebuild after time is set
            if (mounted) {
              setState(() {});
            }
          } catch (e) {
            print("Error parsing time: $e");
          }
        }
      }
      
      // Clear local images - user will need to re-upload if they want to change images
      controller.images?.clear();
    } else {
      // Initialize empty controllers for new outlet
      controller.businessController.clear();
      controller.outletContactController.clear();
      controller.outletNameController.clear();
      controller.addressLine1Controller.clear();
      controller.addressLine2Controller.clear();
      controller.landmarkController.clear();
      controller.zipCodeController.clear();
      controller.selectedState = null;
      controller.selectedCity = null;
      controller.openTime = null;
      controller.closeTime = null;
      controller.images?.clear();
      existingImageUrls.clear();
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Handle formats like "9AM", "9:00 AM", "21", "21:00"
    timeStr = timeStr.trim().toUpperCase();
    
    int hour = 0;
    int minute = 0;
    
    if (timeStr.contains(':')) {
      final parts = timeStr.split(':');
      hour = int.parse(parts[0]);
      final minutePart = parts[1].replaceAll(RegExp(r'[^\d]'), '');
      minute = int.parse(minutePart);
    } else {
      final hourPart = timeStr.replaceAll(RegExp(r'[^\d]'), '');
      hour = int.parse(hourPart);
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  Map<String, dynamic> _buildOutletData() {
    final openTimeStr = controller.openTime != null
        ? '${controller.openTime!.hour}:${controller.openTime!.minute.toString().padLeft(2, '0')}'
        : '';
    final closeTimeStr = controller.closeTime != null
        ? '${controller.closeTime!.hour}:${controller.closeTime!.minute.toString().padLeft(2, '0')}'
        : '';
    
    // Use existing location data if available, otherwise use current location or defaults
    final lat = widget.outletData?.location?.lat ?? 0.0;
    final long = widget.outletData?.location?.long ?? 0.0;
    
    // Combine existing images (that weren't removed) with new uploaded images
    List<String> finalImages = List.from(existingImageUrls);
    
    return {
      'businessName': controller.businessController.text,
      'businessType': controller.selectedBusinessType,
      'outletName': controller.outletNameController.text,
      'outletTime': '$openTimeStr-$closeTimeStr',
      'outletImages': finalImages,
      'outletNumber': controller.outletContactController.text,
      'email': widget.outletData?.email ?? '',
      'location': {
        'lat': lat,
        'long': long,
        'address': controller.addressLine1Controller.text,
        'city': controller.selectedCity?.name ?? '',
        'state': controller.selectedState?.name ?? '',
        'pincode': controller.zipCodeController.text,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditMode ? 'Edit Outlet' : 'Add Outlet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _fromKey,
            child: Column(
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
                  child: (controller.images?.isNotEmpty ?? false) || existingImageUrls.isNotEmpty
                      ? PageView.builder(
                          itemCount: (controller.images?.length ?? 0) + existingImageUrls.length,
                          itemBuilder: (context, index) {
                            final isLocalImage = index < (controller.images?.length ?? 0);
                            
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  isLocalImage
                                      ? Image.file(
                                          File(controller.images?[index].path ?? ""),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 150,
                                        )
                                      : Image.network(
                                          existingImageUrls[index - (controller.images?.length ?? 0)],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 150,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(Icons.broken_image),
                                            );
                                          },
                                        ),
                                  Positioned(
                                    right: size(10),
                                    top: size(10),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isLocalImage) {
                                            controller.images?.removeAt(index);
                                          } else {
                                            existingImageUrls.removeAt(index - (controller.images?.length ?? 0));
                                          }
                                        });
                                        controller.update();
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
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            _showImagesPickerOptions();
                          },
                          child: Column(
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
                      onPressed: ((controller.images?.length ?? 0) + existingImageUrls.length) < 4
                          ? () {
                              _showImagesPickerOptions();
                            }
                          : null,
                      child: CommonText(
                        text: "Add Image ${(controller.images?.length ?? 0) + existingImageUrls.length}/4",
                        color: ((controller.images?.length ?? 0) + existingImageUrls.length) < 4
                            ? ColorConst.primary
                            : ColorConst.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                CommonTextfield(
                  controller: controller.businessController,
                  hintText: 'Business Name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: SvgPicture.asset(ImageConst.business_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter business name.";
                    } else if (value.length < 2) {
                      return "Business name must be at least 2 characters long.";
                    }
                    String pattern = r'^[a-zA-Z0-9&.\-\s]+$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return "Business name can only contain letters, numbers, spaces, &, ., and -.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: size(12)),
                CommonTextfield(
                  controller: controller.outletContactController,
                  hintText: 'Outlet Contact Number',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: SvgPicture.asset(ImageConst.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter outlet contact number.";
                    }
                    String pattern = r'^[6-9]\d{9}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return "Please enter a valid Indian mobile number.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: size(12)),
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
                    String pattern = r'^[a-zA-Z0-9&.\-\s]+$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return "Outlet name can only contain letters, numbers, spaces, &, ., and -.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: size(12)),
                CommonDropdown(
                  value: controller.selectedBusinessType,
                  items: businessTypes,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedBusinessType = value;
                    });
                  },
                  hintText: 'Business Type',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select business type.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: size(12)),
                GetBuilder<DetailsController>(
                  builder: (ctrl) {
                    return InkWell(
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
                    );
                  },
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
                GetBuilder<DetailsController>(
                  builder: (ctrl) {
                    return InkWell(
                      onTap: () {
                        if (controller.selectedState == null) {
                          Get.snackbar('Error', 'Please select a state first');
                          return;
                        }
                        Get.bottomSheet(CitySheet());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: controller.cityErrorMessage.isNotEmpty
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
                    );
                  },
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
                    return null;
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
                CommonTextfield(
                  controller: controller.zipCodeController,
                  hintText: 'Zip Code',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter zip code.";
                    } else if (value.length != 6) {
                      return "Zip code must be 6 digits.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: size(12)),
                Row(
                  children: [
                    SvgPicture.asset(ImageConst.icTime),
                    SizedBox(width: size(6)),
                    CommonText(
                      text: "OUTLET TIMING",
                      color: ColorConst.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: size(12),
                    )
                  ],
                ),
                SizedBox(height: size(12)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _selectOpenTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorConst.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.openTime != null
                                        ? controller.openTime!.format(context)
                                        : 'Open Time',
                                    style: TextStyle(
                                      fontSize: size(16),
                                      color: controller.openTime != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  SvgPicture.asset(ImageConst.icTime),
                                ],
                              ),
                            ),
                          ),
                          if (controller.startTimeErrorMessage.isNotEmpty) ...[
                            SizedBox(height: size(5)),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: size(10)),
                              child: CommonText(
                                text:
                                    controller.startTimeErrorMessage.value,
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
                          GestureDetector(
                            onTap: () => _selectCloseTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorConst.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.closeTime != null
                                        ? controller.closeTime!.format(context)
                                        : 'Close Time',
                                    style: TextStyle(
                                      fontSize: size(16),
                                      color: controller.closeTime != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  SvgPicture.asset(ImageConst.icTime),
                                ],
                              ),
                            ),
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
                SizedBox(height: size(20)),
                SizedBox(
                  width: Get.width,
                  child: Obx(
                    () => CommonButton(
                      isLoading: controller.isLoadingOutlet.value,
                      onPressed: () async {
                        if (validateAll()) {
                          if (widget.isEditMode && widget.outletData != null) {
                            await _handleEditOutlet();
                          } else {
                            controller.submitOutlet();
                          }
                        }
                      },
                      text: widget.isEditMode ? 'Edit Outlet' : 'Add Outlet',
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _pickImagesFromGallery(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
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
        if ((controller.images?.length ?? 0) < 4) {
          setState(() {
            controller.images?.add(File(croppedFile.path));
          });
          controller.update();
        } else {
          Get.snackbar('Error', 'You can only upload 4 images');
        }
      }
    }
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

  void _showImagesPickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select Image'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImagesFromGallery(ImageSource.gallery);
            },
            child: CommonText(
              text: 'Choose from Gallery',
              color: Colors.black,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImagesFromGallery(ImageSource.camera);
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


  Future<void> _selectOpenTime(BuildContext context) async {
    DateTime? picked;
    final now = DateTime.now();
    final initialTime = DateTime(
        now.year,
        now.month,
        now.day,
        controller.openTime?.hour ?? 9,
        controller.openTime?.minute ?? 0);

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
                        setState(() {
                          controller.openTime = TimeOfDay.fromDateTime(picked!);
                          controller.startTimeErrorMessage("");
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
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

  Future<void> _handleEditOutlet() async {
    try {
      controller.isLoadingOutlet.value = true;
      
      // Upload new images if any
      List<String> newImageUrls = [];
      if (controller.images != null && controller.images!.isNotEmpty) {
        for (var imageFile in controller.images!) {
          String? url = await dashboardController.uploadImage(imageFile);
          if (url != null) {
            newImageUrls.add(url);
          }
        }
      }
      
      // Combine existing images with newly uploaded images
      List<String> finalImages = List.from(existingImageUrls);
      finalImages.addAll(newImageUrls);
      
      // Build outlet data with final images
      Map<String, dynamic> outletData = _buildOutletData();
      outletData['outletImages'] = finalImages;
      
      // Call update API
      final myOutletsController = Get.find<MyOutletsController>();
      await myOutletsController.updateBusiness(
        widget.outletData!.id ?? '',
        outletData,
      );
      
      // Go back after successful update
      Get.back();
    } catch (e) {
      print("Error updating outlet: $e");
      Get.snackbar('Error', 'Error updating outlet: ${e.toString()}');
    } finally {
      controller.isLoadingOutlet.value = false;
    }
  }

  Future<void> _selectCloseTime(BuildContext context) async {
    DateTime? picked;
    final now = DateTime.now();
    final initialTime = DateTime(
        now.year,
        now.month,
        now.day,
        controller.closeTime?.hour ?? 21,
        controller.closeTime?.minute ?? 0);

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
                        setState(() {
                          controller.closeTime =
                              TimeOfDay.fromDateTime(picked!);
                          controller.endTimeErrorMessage("");
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
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
}

