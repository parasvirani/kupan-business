
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

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
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
            ()=> Column(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter title.";
                    } else if (value.length < 2) {
                      return "Title must be at least 2 characters long.";
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
                SizedBox(height: size(20)),
                CommonTextfield(
                  controller: dashboardController.titleController,
                  hintText: 'Location',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter location.";
                    } else if (value.length < 2) {
                      return "Location must be at least 2 characters long.";
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
                SizedBox(height: size(20)),
                CommonTextfield(
                  controller: dashboardController.titleController,
                  hintText: 'Term & Conditions',
                  minLines: 5,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Term & Conditions.";
                    } else if (value.length < 2) {
                      return "Term & Conditions must be at least 2 characters long.";
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
                SizedBox(height: size(20)),
                SizedBox(
                  width: Get.width,
                  child: CommonButton(onPressed: () {

                  }, text: "Save Kupan"),
                )
              ],
            ),
          ),
        ),
      ),
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
        dashboardController.images?.add(_imageFile!);
      }
    }
  }
}
