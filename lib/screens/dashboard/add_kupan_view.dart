
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
import '../../models/kupans_list_res.dart';
import '../../models/redemptions_res.dart';
import '../../services/redemptions_service.dart';
import '../../utils/appRoutesStrings.dart';
import '../../utils/utils.dart';
import 'components/main_drawer.dart';

class AddKupanView extends StatefulWidget {
  final dynamic kupanToEdit;

  const AddKupanView({super.key, this.kupanToEdit});

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
  bool isEditMode = false;

@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.titleController = TextEditingController();
     dashboardController.daysList.forEach((element) => element.isSelected = false);
            dashboardController.daysList.refresh();
    });
     
    
  }

  @override
  void initState() {
    super.initState();
   
    if (widget.kupanToEdit != null) {
      isEditMode = true;
      _initializeEditMode();
    } else {
      if (dashboardController.selectedOutletId.value.isNotEmpty) {
        isOutletPreSelected = true;
      }
    }
  }

 

  void _initializeEditMode() {
    final kupan = widget.kupanToEdit;
    dashboardController.titleController.text = kupan.title ?? '';
    
    // Handle both KupanData and RedemptionData models
    if (kupan is KupanData) {
      // KupanData model - has businessId and outlet info in sellerBusinesses
      dashboardController.selectedOutletId.value = kupan.businessId ?? '';
      // Use the getOutletName() method to properly extract outlet name from sellerBusinesses
      final outletName = kupan.getOutletName() ?? kupan.outletName ?? '';
      dashboardController.selectedOutletName.value = outletName;
      isOutletPreSelected = true; // Lock outlet selection for KupanData
    } else if (kupan is RedemptionData) {
      // RedemptionData model - outlet info not available in this model
      // Allow user to select outlet for redemption updates
      dashboardController.selectedOutletId.value = '';
      dashboardController.selectedOutletName.value = '';
      isOutletPreSelected = false; // Allow outlet selection for RedemptionData
    } else {
      // Fallback for other types - if it's KupanData
      if (kupan is KupanData) {
        dashboardController.selectedOutletId.value = kupan.businessId ?? '';
        final outletName = kupan.getOutletName() ?? kupan.outletName ?? '';
        dashboardController.selectedOutletName.value = outletName;
      } else {
        dashboardController.selectedOutletId.value = kupan.businessId ?? '';
        dashboardController.selectedOutletName.value = kupan.outletName ?? '';
      }
      isOutletPreSelected = true;
    }
    
    // Load existing kupan images
    if (kupan.kupanImages != null && kupan.kupanImages!.isNotEmpty) {
      // Note: kupan.kupanImages contains URLs (strings), not File objects
      // We store them as metadata for display purposes
      // Users will need to select new images if they want to update
      print('Existing kupan images: ${kupan.kupanImages}');
    }
    
    if (kupan.kupanDays != null) {
      // Filter out 'All' and only use individual day names
      final daysList = kupan.kupanDays!.where((day) => day != 'All').toList();
      final selectedDaysSet = daysList.toSet();
      for (int i = 0; i < dashboardController.daysList.length; i++) {
        dashboardController.daysList[i].isSelected =
            selectedDaysSet.contains(dashboardController.daysList[i].day);
      }
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
        leading: isEditMode
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: ColorConst.dark),
                onPressed: () => Get.back(),
              )
            : IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                }, 
                icon: SvgPicture.asset(ImageConst.ic_menu)
            ),
        centerTitle: true,
        title: isEditMode
            ? CommonText(
                text: 'Edit Kupan',
                fontSize: size(16),
                color: ColorConst.dark,
                fontWeight: FontWeight.w600,
              )
            : Column(
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
      drawer: isEditMode
          ? null
          : Drawer(
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

                    // If outlet is pre-selected AND in KupanData edit mode, show it as read-only
                    if (isOutletPreSelected && dashboardController.selectedOutletId.value.isNotEmpty && widget.kupanToEdit is KupanData) {
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
                    child: (dashboardController.images?.isNotEmpty ?? false) || (isEditMode && (widget.kupanToEdit?.kupanImages?.isNotEmpty ?? false))
                        ? PageView.builder(
                      itemCount: ((dashboardController.images?.length ?? 0) + (isEditMode ? (widget.kupanToEdit?.kupanImages?.length ?? 0) : 0)).toInt(),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Show newly selected images first, then existing images
                            if (index < (dashboardController.images?.length ?? 0))
                              Image.file(
                                File(dashboardController.images?[index].path ?? ""),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              )
                            else if (isEditMode && widget.kupanToEdit?.kupanImages != null)
                              Image.network(
                                widget.kupanToEdit!.kupanImages![index - (dashboardController.images?.length ?? 0)],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            Positioned(
                              right: size(10),
                              top: size(10),
                              child: InkWell(
                                onTap: () {
                                  if (index < (dashboardController.images?.length ?? 0)) {
                                    dashboardController.images?.removeAt(index);
                                  } else if (isEditMode && widget.kupanToEdit?.kupanImages != null) {
                                    final existingImageIndex = index - (dashboardController.images?.length ?? 0);
                                    widget.kupanToEdit!.kupanImages!.removeAt(existingImageIndex);
                                  }
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
                        onPressed: ((dashboardController.images?.length ?? 0) + (isEditMode ? (widget.kupanToEdit?.kupanImages?.length ?? 0) : 0)) < 4
                            ? () {
                          _showPickerOptions();
                        }
                            : null,
                        child: CommonText(
                          text: "Add Image ${(dashboardController.images?.length ?? 0) + (isEditMode ? (widget.kupanToEdit?.kupanImages?.length ?? 0) : 0)}/4",
                          color: ((dashboardController.images?.length ?? 0) + (isEditMode ? (widget.kupanToEdit?.kupanImages?.length ?? 0) : 0)) < 4
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
                          isEditMode
                              ? _updateKupanAndNavigateBack()
                              : _createKupanAndNavigateBack();
                        }
                      }, text: isEditMode ? "Update Kupan" : "Save Kupan"),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dashboardController.errorMessageCreateKupan.value.isEmpty
                ? 'Failed to create coupon'
                : dashboardController.errorMessageCreateKupan.value,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _updateKupanAndNavigateBack() async {
    final kupan = widget.kupanToEdit;
    final title = dashboardController.titleController.text.trim();
    
    final selectedDays = dashboardController.daysList
        .where((day) => day.isSelected)
        .map((day) => day.day!)
        .toList();

    try {
      // Set loading state
      dashboardController.isLoadingCreateKupan.value = true;
      
      final redemptionsService = RedemptionsService();
      
      // Handle both KupanData and RedemptionData models
      String? kupanId;
      List<String> kupanImages = [];
      
      // Check if it's a RedemptionData (has kupanId property)
      if (kupan is RedemptionData) {
        kupanId = kupan.kupanId;
      } else {
        // It's KupanData (has id property)
        kupanId = kupan.id;
      }
      
      if (kupanId == null) {
        throw Exception('Kupan ID is missing');
      }

      // First, add any existing images that weren't deleted
      if (kupan.kupanImages != null && kupan.kupanImages!.isNotEmpty) {
        kupanImages.addAll(kupan.kupanImages!.cast<String>());
      }
      
      // Then upload any new images and add their URLs
      if (dashboardController.images != null && dashboardController.images!.isNotEmpty) {
        for (var imageFile in dashboardController.images!) {
          String? uploadedUrl = await dashboardController.uploadImage(imageFile);
          if (uploadedUrl != null) {
            kupanImages.add(uploadedUrl);
          }
        }
      }
      
      await redemptionsService.editKupan(
        kupanId: kupanId,
        title: title,
        kupanImages: kupanImages,
        kupanDays: selectedDays,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kupan updated successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh the appropriate list based on the source
      final vendorId = dashboardController.selectedOutletId.value;
      if (kupan is KupanData && vendorId.isNotEmpty) {
        // Update from home screen - refresh the kupan list
        await dashboardController.getKupanByVendor(
          vendorId: vendorId,
        );
      } else if (kupan is RedemptionData && vendorId.isNotEmpty) {
        // Update from redemptions screen - refresh all redemption ranges
        await dashboardController.fetchAllRedemptionRanges(
          vendorId: vendorId,
        );
      }

      Get.back(result: true);
    } catch (e) {
      print('Failed to update kupan: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update kupan: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      dashboardController.isLoadingCreateKupan.value = false;
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
