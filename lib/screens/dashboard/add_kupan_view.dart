
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kupan_business/common_view/common_button.dart';

import '../../common_view/common_text.dart';
import '../../common_view/common_textfield.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/my_outlets_controller.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'components/main_drawer.dart';

class AddKupanView extends StatefulWidget {
  const AddKupanView({super.key});

  @override
  State<AddKupanView> createState() => _AddKupanViewState();
}

class _AddKupanViewState extends State<AddKupanView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardController dashboardController = Get.find();
  final MyOutletsController controller = Get.put(MyOutletsController());
  final _fromKey = GlobalKey<FormState>();
  File? _imageFile;
  bool isOutletPreSelected = false;

  @override
  void initState() {
    super.initState();
    // Check if outlet was pre-selected from outlet details screen
    if (dashboardController.selectedOutletId.value.isNotEmpty) {
      isOutletPreSelected = true;
    }
  }

  bool validateAll() {
    bool isValid = _fromKey.currentState!.validate();

    // Validate outlet selection
    if (dashboardController.selectedOutletId.value.isEmpty) {
      dashboardController.errorMessageOutletSelection("Please select an outlet");
      isValid = false;
    } else {
      dashboardController.errorMessageOutletSelection("");
    }

    bool isAnySelected = dashboardController.daysList.any((data) => data.isSelected);
    if (!isAnySelected) {
      dashboardController.errorMessageDaySelection("Please select at least one day");
      isValid = false;
    } else {
      dashboardController.errorMessageDaySelection("");
    }


    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final double borderRadius = 10;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorConst.white,
      appBar: AppBar(
        backgroundColor: ColorConst.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            }, icon: SvgPicture.asset(ImageConst.ic_menu)),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonText(
              text: 'Current address',
              fontSize: size(12),
              color: ColorConst.grey,
            ),
            CommonText(
              text: '68 High Street, England',
              fontSize: size(16),
              color: ColorConst.dark,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(ImageConst.ic_notification),
            onPressed: () {
              Get.toNamed(AppRoutes.notification);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: MainDrawer(onTap: () {
          _scaffoldKey.currentState?.closeDrawer();
        },),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size(20)),
          child: Obx(
            ()=> Form(
              key: _fromKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size(20)),
                  CommonText(text: "Select Outlet", color: Colors.black,),
                  SizedBox(height: size(5)),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading outlets...'),
                          ],
                        ),
                      );
                    }
                    if (controller.errorMessage.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade200, width: 1),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(controller.errorMessage.value)),
                            TextButton(
                              onPressed: controller.getOutlets,
                              child: Text('Retry'),
                            )
                          ],
                        ),
                      );
                    }

                    // If outlet is pre-selected, show it as read-only
                    if (isOutletPreSelected && dashboardController.selectedOutletId.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: size(15), vertical: size(14)),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorConst.primary.withAlpha(100),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(size(10)),
                          color: ColorConst.primary.withAlpha(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(
                                    text: 'Selected Outlet',
                                    fontSize: size(10),
                                    color: ColorConst.grey,
                                  ),
                                  SizedBox(height: size(2)),
                                  CommonText(
                                    text: dashboardController.selectedOutletName.value,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: size(14),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorConst.primary.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: ColorConst.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show dropdown for outlet selection if not pre-selected
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: size(15)),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorConst.border, width: 1),
                        borderRadius: BorderRadius.circular(size(10)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: SizedBox(),
                        value: controller.selectedOutletId.value.isEmpty
                            ? null
                            : controller.selectedOutletId.value,
                        hint: CommonText(
                          text: 'Choose an outlet',
                          color: ColorConst.grey,
                        ),
                        items: controller.outletsList.map((outlet) {
                          return DropdownMenuItem(
                            value: outlet.id ?? "",
                            child: CommonText(
                              text: outlet.outletName ?? 'No outlet',
                              color: Colors.black,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedOutletId.value = value;
                            final selectedOutlet = controller.outletsList
                                .firstWhere((outlet) => outlet.id == value);
                            controller.selectedOutletName.value =
                                selectedOutlet.outletName ?? "";
                            controller.errorMessageOutletSelection.value = "";
                            dashboardController.selectedOutletId.value = value;
                            dashboardController.selectedOutletName.value =
                                selectedOutlet.outletName ?? "";
                          }
                        },
                      ),
                    );
                  }
                  ),
                  Visibility(
                    visible: controller.errorMessageOutletSelection.value.isNotEmpty,
                    child: CommonText(
                      text: controller.errorMessageOutletSelection.value,
                      color: Colors.red,
                    ),
                  ),
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
                    child: dashboardController.images?.isNotEmpty ?? false
                        ? PageView.builder(
                      itemCount: dashboardController.images?.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.file(
                              File(dashboardController.images?[index].path ?? ""),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            ),
                            Positioned(
                              right: size(10),
                              top: size(10),
                              child: InkWell(
                                onTap: () {
                                  dashboardController.images?.removeAt(index);
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
                        visible: dashboardController
                            .errorMessageOutletImages.value.isNotEmpty,
                        child: CommonText(
                          text: dashboardController.errorMessageOutletImages.value,
                          color: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: dashboardController.images!.length < 4
                            ? () {
                          _showPickerOptions();
                        }
                            : null,
                        child: CommonText(
                          text: "Add Image ${dashboardController.images?.length}/4",
                          color: dashboardController.images!.length < 4
                              ? ColorConst.primary
                              : ColorConst.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size(20)),
                  CommonTextfield(
                    controller: dashboardController.titleController,
                    hintText: 'Title',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter title.";
                      } else if (value.length < 2) {
                        return "Title must be at least 2 characters long.";
                      }
                      return null; // input is valid
                    },
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: size(20)),
                  CommonText(text: "Valid on", color: Colors.black,),
                  SizedBox(height: size(5)),
                  Obx(
                      ()=> Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size(10)),
                        border: Border.all(color: ColorConst.border, width: 1)
                      ),
                      padding: EdgeInsets.all(size(10)),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 2,
                            crossAxisSpacing: size(10),
                            mainAxisSpacing: size(10)
                        ),
                        itemCount: dashboardController.daysList.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            dashboardController.daySelector(index);
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size(8)),
                                  border:
                                  Border.all(color: ColorConst.border, width: dashboardController.daysList[index].isSelected ? 0 : 1),
                                  color: dashboardController.daysList[index].isSelected ? ColorConst.primary : Colors.white),
                              child: CommonText(
                                text: dashboardController.daysList[index].day ?? "",
                                color: dashboardController.daysList[index].isSelected ? Colors.white : Colors.black,
                                fontSize: size(12),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: dashboardController
                        .errorMessageDaySelection.value.isNotEmpty,
                    child: CommonText(
                      text: dashboardController.errorMessageDaySelection.value,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: size(20)),
                  Visibility(
                    visible: dashboardController
                        .errorMessageCreateKupan.value.isNotEmpty,
                    child: CommonText(
                      text: dashboardController.errorMessageCreateKupan.value,
                      color: Colors.red,
                    ),
                  ),
                  Obx(
                    ()=> SizedBox(
                      width: Get.width,
                      child: CommonButton(
                        isLoading: dashboardController.isLoadingCreateKupan.value,
                          onPressed: () {
                        if (validateAll()) {
                          _createKupanAndNavigateBack();
                        }
                      }, text: "Save Kupan"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createKupanAndNavigateBack() async {
    // Get the outlet ID before creating kupan
    String outletId = dashboardController.selectedOutletId.value;

    // Call createKupan
    await dashboardController.createKupan();

    // Check if creation was successful
    if (dashboardController.errorMessageCreateKupan.value.isEmpty &&
        dashboardController.createKupanRes.value?.success == true) {
      // Success! Refresh the outlet kupans list
      if (outletId.isNotEmpty) {
        await controller.getOutletKupans(businessId: outletId);
      }

      // Show success message
      // Get.snackbar(
      //   'Success',
      //   'Coupon created successfully!',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   icon: const Icon(Icons.check_circle, color: Colors.white),
      // );

      // Navigate back to outlet details screen with the outlet data
      // await Future.delayed(const Duration(milliseconds: 500));

      // Get the outlet data from the outlets list
      final selectedOutlet = controller.outletsList.firstWhereOrNull(
        (outlet) => outlet.id == outletId,
      );

      if (selectedOutlet != null) {
        // Navigate back to outlet details with the specific outlet data
        Get.back(result: selectedOutlet);
      } else {
        // If outlet not found in list, just go back
        Get.back();
      }
    } else {
      // Show error message
      Get.snackbar(
        'Error',
        dashboardController.errorMessageCreateKupan.value.isEmpty
            ? 'Failed to create coupon'
            : dashboardController.errorMessageCreateKupan.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
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
        dashboardController.images?.add(_imageFile!);
      }
    }
  }
}
