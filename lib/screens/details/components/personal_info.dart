import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/const/image_const.dart';
import 'package:kupan_business/controllers/dashboard_controller.dart';
import 'package:kupan_business/controllers/details_controller.dart';

import '../../../common_view/common_button.dart';
import '../../../common_view/common_textfield.dart';
import '../../../utils/utils.dart';

class PersonalInfo extends StatefulWidget {
  String? mobileNumber;
  bool isEdit;
  Function()? onTap;

  PersonalInfo({super.key, this.mobileNumber, this.onTap, this.isEdit =false});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  DashboardController dashboardController = Get.put(DashboardController());
  DetailsController detailsController = Get.put(DetailsController());

  final _fromKey = GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print("Dashboard Controller : ${widget.dashboardController != null}");
    getDetails();
  }

  getDetails () {
    if (widget.isEdit) {
      // print("Dashboard Controller : ${dashboardController.userUpdateRes.value?.data?.contact ?? ""}");
      detailsController.nameController.text = dashboardController.userUpdateRes.value?.data?.name ?? "";
      detailsController.phoneController.text = (dashboardController.userUpdateRes.value?.data?.contact ?? "").replaceFirst("+91", "");
      detailsController.emailController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.email ?? "";
      detailsController.businessController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.businessName ?? "";

      detailsController.outletNameController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletName ?? "";
      detailsController.selectedBusinessType = dashboardController.userUpdateRes.value?.data?.sellerInfo?.businessType ?? "";
      detailsController.addressLine1Controller.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.address ?? "";
      detailsController.addressLine2Controller.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.address2 ?? "";
      detailsController.landmarkController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.landmark ?? "";
      detailsController.updateStateByName(dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.state ?? "", cityName: dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.city ?? "");
      detailsController.zipCodeController.text = dashboardController.userUpdateRes.value?.data?.sellerInfo?.location?.pincode ?? "";
      final apiDays = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletDay ?? [];

      for (var day in detailsController.daysList) {
        day.isSelected = apiDays.contains(day.day);
      }
      detailsController.daysList.refresh();

      String apiTime = dashboardController.userUpdateRes.value?.data?.sellerInfo?.outletTime ?? "9 AM - 9 PM";
      final parts = apiTime.split('-');

      if (parts.length == 2) {
        detailsController.startTime = detailsController.parseTime(parts[0].trim());
        detailsController.endTime = detailsController.parseTime(parts[1].trim());
      }
    } else {
      detailsController.phoneController.text = widget.mobileNumber ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _fromKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              // Profile Avatar
              GetBuilder<DetailsController>(
                builder: (controller) {
                  return InkWell(
                    onTap: () {
                      _showPickerOptions();
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(0xFF7FB3D3),
                            shape: BoxShape.circle,
                          ),
                          child: detailsController.imageFile != null ? ClipOval(
                              child: Image.file(File(detailsController.imageFile!.path))) : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(ImageConst.ic_edit),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 40),

              // Form Fields
              Column(
                children: [
                  CommonTextfield(
                    controller: detailsController.nameController,
                    hintText: 'Enter Your Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name.";
                      } else if (value.length < 2) {
                        return "Name must be at least 2 characters long.";
                      }
                      return null; // input is valid
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.person_outline),
                    ),
                    keyboardType: TextInputType.name,
                  ),

                  SizedBox(height: 16),
                  CommonTextfield(
                    controller: detailsController.phoneController,
                    hintText: 'Phone Number',
                    isNumber: true,
                    readOnly: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.phone_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 16),

                  CommonTextfield(
                    controller: detailsController.emailController,
                    hintText: 'Add Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email.";
                      }
                      // Basic email pattern
                      String pattern =
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return "Please enter a valid email address.";
                      }
                      return null; // input is valid
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),


                  SizedBox(height: 16),

                  CommonTextfield(
                    controller: detailsController.businessController,
                    hintText: 'Business Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your business name.";
                      } else if (value.length < 2) {
                        return "Business name must be at least 2 characters long.";
                      }
                      // Allow letters, numbers, spaces, and & . -
                      String pattern = r'^[a-zA-Z0-9&.\-\s]+$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return "Business name can only contain letters, numbers, spaces, &, ., and -.";
                      }
                      return null; // input is valid
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size(10)),
                      child: SvgPicture.asset(ImageConst.business_outlined),
                    ),
                    keyboardType: TextInputType.name,
                  ),


                  SizedBox(height: 16),

                  // Continue Button
                  Container(
                    width: Get.width,
                    child: CommonButton(
                        onPressed: () {
                          if (_fromKey.currentState!.validate()) {
                            if (widget.isEdit) {
                              detailsController.getStarted(widget.isEdit);
                            } else {
                              widget.onTap!();
                            }
                          }
                        },
                        text: widget.isEdit ? "Update" : 'Continue'),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
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
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
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
        detailsController.imageFile = File(croppedFile.path);
        // });
        detailsController.update();
      }
    }
  }

  void _showPickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) =>
          CupertinoActionSheet(
            title: Text('Select Image'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: CommonText(
                  text: 'Choose from Gallery', color: Colors.black,),
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

}
