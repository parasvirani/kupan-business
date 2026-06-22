// ============================================================
// add_outlet_screen.dart  –  Pixel-perfect Outlet Info Screen
// ============================================================
// pubspec.yaml dependencies:
//   image_picker: ^1.0.7
//   image_cropper: ^5.0.0
//   flutter_svg: ^2.0.9
//   get: ^4.6.6
//
// Keep your existing controllers, models, routes, common widgets.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../common_view/city_sheet.dart';
import '../../common_view/state_sheet.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/details_controller.dart';
import '../../controllers/my_outlets_controller.dart';
import '../../models/user_businesses_res.dart';
import '../../services/api_service.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _dark = Color(0xFF1A1A1A);
const Color _labelColor = Color(0xFF6B6B6B);
const Color _hintColor = Color(0xFFAAAAAA);
const Color _borderColor = Color(0xFFE4E4E4);
const Color _sectionBg = Color(0xFFFFFFFF);
const Color _pageBg = Color(0xFFF5F5F5);
const Color _primaryBlack = Color(0xFF1A1A1A);
const String _font = 'Inter';

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
  // ── Controllers ───────────────────────────────────────────────────────────
  final DetailsController controller = Get.put(DetailsController());
  final DashboardController dashboardController = Get.put(DashboardController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── Local state ───────────────────────────────────────────────────────────
  List<String> existingImageUrls = [];
  bool _isFetchingLocation = false;

  // Business type options
  final List<String> businessTypes = ['restaurant', 'cafe', 'hotel'];
  String? _selectedBusinessType;

  // Open days
  final List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final Set<String> selectedDays = {'Sun'}; // Sun pre-selected as per design

  // Text controllers for address fields (to mirror the labelled design)
  final TextEditingController _address1Ctrl = TextEditingController();
  final TextEditingController _address2Ctrl = TextEditingController();
  final TextEditingController _landmarkCtrl = TextEditingController();
  final TextEditingController _zipCtrl = TextEditingController();
  final TextEditingController _outletNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.isEditMode && widget.outletData != null) {
      final o = widget.outletData!;
      _outletNameCtrl.text = o.outletName ?? '';
      _selectedBusinessType = o.businessType;
      _address1Ctrl.text = o.location?.address ?? '';
      _landmarkCtrl.text = o.location?.address ?? '';
      _zipCtrl.text = o.location?.pincode ?? '';
      existingImageUrls = o.outletImages ?? [];

      if (o.location?.state != null) {
        try {
          await controller.updateStateByName(
            o.location!.state!,
            cityName: o.location?.city,
          );
        } catch (_) {}
      }

      if (o.outletTime != null && o.outletTime!.contains('-')) {
        final parts = o.outletTime!.split('-');
        if (parts.length == 2) {
          try {
            controller.openTime = _parseTime(parts[0].trim());
            controller.closeTime = _parseTime(parts[1].trim());
          } catch (_) {}
        }
      }
      if (mounted) setState(() {});
    }
  }

  TimeOfDay _parseTime(String s) {
    s = s.trim().toUpperCase();
    int h = 0, m = 0;
    if (s.contains(':')) {
      final p = s.split(':');
      h = int.parse(p[0]);
      m = int.parse(p[1].replaceAll(RegExp(r'[^\d]'), ''));
    } else {
      h = int.parse(s.replaceAll(RegExp(r'[^\d]'), ''));
    }
    return TimeOfDay(hour: h, minute: m);
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    bool ok = _formKey.currentState!.validate();
    if (_selectedBusinessType == null) ok = false;
    final totalImages = (controller.images?.length ?? 0) + existingImageUrls.length;
    if (totalImages == 0) {
      controller.errorMessageOutletImages('Please select at least one image');
      ok = false;
    } else {
      controller.errorMessageOutletImages('');
    }
    if (controller.openTime == null) {
      controller.startTimeErrorMessage('Please select start time');
      ok = false;
    } else {
      controller.startTimeErrorMessage('');
    }
    if (controller.closeTime == null) {
      controller.endTimeErrorMessage('Please select end time');
      ok = false;
    } else {
      controller.endTimeErrorMessage('');
    }
    if (controller.selectedState == null) {
      controller.stateErrorMessage('Please select state');
      ok = false;
    } else {
      controller.stateErrorMessage('');
    }
    if (controller.selectedCity == null) {
      controller.cityErrorMessage('Please select city');
      ok = false;
    } else {
      controller.cityErrorMessage('');
    }
    return ok;
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  void _showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Select Image'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Choose from Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Take a Photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped != null) {
      final count = (controller.images?.length ?? 0) + existingImageUrls.length;
      if (count < 4) {
        setState(() => controller.images?.add(File(cropped.path)));
        controller.update();
      } else {
        Get.snackbar('Limit reached', 'You can only upload 4 images');
      }
    }
  }

  // ── Time pickers ──────────────────────────────────────────────────────────
  Future<void> _pickTime(BuildContext ctx, bool isOpen) async {
    final init = DateTime(
      2024, 1, 1,
      isOpen ? (controller.openTime?.hour ?? 9) : (controller.closeTime?.hour ?? 21),
      isOpen ? (controller.openTime?.minute ?? 0) : (controller.closeTime?.minute ?? 0),
    );
    DateTime picked = init;

    await showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
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
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        if (isOpen) {
                          controller.openTime = TimeOfDay.fromDateTime(picked);
                          controller.startTimeErrorMessage('');
                        } else {
                          controller.closeTime = TimeOfDay.fromDateTime(picked);
                          controller.endTimeErrorMessage('');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: init,
                use24hFormat: false,
                onDateTimeChanged: (v) => picked = v,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onGetStarted() async {
    if (!_validate()) return;

    try {
      controller.isLoadingOutlet.value = true;

      // Upload new local images
      List<String> uploadedUrls = [];
      for (final f in controller.images ?? []) {
        final url = await dashboardController.uploadImage(f);
        if (url == null) {
          Get.snackbar('Error', 'Image upload failed. Please try again.',
              backgroundColor: Colors.red, colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        uploadedUrls.add(url);
      }

      final finalImages = [...existingImageUrls, ...uploadedUrls];
      final payload = _buildPayload(finalImages);

      if (widget.isEditMode && widget.outletData != null) {
        final myOutletsController = Get.find<MyOutletsController>();
        await myOutletsController.updateBusiness(widget.outletData!.id ?? '', payload);
      } else {
        final apiService = ApiService();
        final response = await apiService.addBusiness(payload);
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['success'] == true) {
          controller.images?.clear();
          await MyOutletsController.refreshOutlets();
          Get.back();
          Get.snackbar('Success', 'Outlet added successfully!',
              backgroundColor: Colors.green, colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to add outlet',
              backgroundColor: Colors.red, colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      controller.isLoadingOutlet.value = false;
    }
  }

  Map<String, dynamic> _buildPayload(List<String> images) {
    final openStr = controller.openTime?.format(Get.context!) ?? '';
    final closeStr = controller.closeTime?.format(Get.context!) ?? '';
    final lat = controller.lat.value != 0.0
        ? controller.lat.value
        : (widget.outletData?.location?.lat ?? 0.0);
    final long = controller.long.value != 0.0
        ? controller.long.value
        : (widget.outletData?.location?.long ?? 0.0);
    return {
      'outletName': _outletNameCtrl.text.trim(),
      'businessName': _outletNameCtrl.text.trim(),
      'businessType': _selectedBusinessType,
      'outletTime': '$openStr - $closeStr',
      'outletImages': images,
      'outletDays': selectedDays.toList(),
      'location': {
        'address': _address1Ctrl.text.trim(),
        'address2': _address2Ctrl.text.trim(),
        'landmark': _landmarkCtrl.text.trim(),
        'city': controller.selectedCity?.name ?? '',
        'state': controller.selectedState?.name ?? '',
        'pincode': _zipCtrl.text.trim(),
        'lat': lat,
        'long': long,
      },
    };
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  _buildOutletInfoCard(),
                  const SizedBox(height: 12),
                  _buildOutletAddressCard(),
                  const SizedBox(height: 12),
                  _buildOpenDaysCard(),
                ],
              ),
            ),
            // Sticky bottom button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _pageBg,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _borderColor, width: 1.5),
            color: Colors.white,
          ),
          child: const Icon(Icons.chevron_left_rounded, color: _dark, size: 22),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 1: OUTLET INFO
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOutletInfoCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('OUTLET INFO'),
          const SizedBox(height: 14),

          // Image thumbnails row
          _buildImageRow(),
          const SizedBox(height: 16),

          // Outlet Name
          _buildLabeledField(
            label: 'OUTLET NAME',
            child: _InputField(
              controller: _outletNameCtrl,
              hint: 'Enter your name',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter outlet name';
                if (v.trim().length < 2) return 'At least 2 characters required';
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),

          // Business Type
          _buildLabeledField(
            label: 'BUSINESS TYPE',
            child: _buildBusinessTypeDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageRow() {
    final localImages = controller.images ?? [];
    final totalCount = localImages.length + existingImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Existing + local image thumbnails
            ...List.generate(localImages.length, (i) => _buildThumb(
              child: Image.file(File(localImages[i].path), fit: BoxFit.cover),
              onRemove: () => setState(() {
                controller.images?.removeAt(i);
                controller.update();
              }),
            )),
            ...List.generate(existingImageUrls.length, (i) => _buildThumb(
              child: Image.network(
                existingImageUrls[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: _hintColor),
              ),
              onRemove: () => setState(() => existingImageUrls.removeAt(i)),
            )),

            // Upload button (show if < 4 images)
            if (totalCount < 4)
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _borderColor,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.upload_rounded, color: _dark, size: 26),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Error message
        Obx(() => controller.errorMessageOutletImages.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            controller.errorMessageOutletImages.value,
            style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: _font),
          ),
        )
            : const SizedBox()),

        // Add image count
        if (totalCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Add Image $totalCount/4',
              style: const TextStyle(
                color: _labelColor,
                fontSize: 12,
                fontFamily: _font,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThumb({required Widget child, required VoidCallback onRemove}) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 72, height: 72, child: child),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBusinessType,
      hint: const Text(
        'Select business type',
        style: TextStyle(color: _hintColor, fontSize: 15, fontFamily: _font),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _dark),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _dark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(
        color: _dark,
        fontSize: 15,
        fontFamily: _font,
        fontWeight: FontWeight.w400,
      ),
      items: businessTypes
          .map((t) => DropdownMenuItem(
        value: t,
        child: Text(t[0].toUpperCase() + t.substring(1)),
      ))
          .toList(),
      onChanged: (v) => setState(() => _selectedBusinessType = v),
      validator: (v) =>
      (v == null || v.isEmpty) ? 'Please select business type' : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 2: OUTLET ADDRESS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOutletAddressCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('OUTLET ADDRESS'),
          const SizedBox(height: 16),

          // Use current location
          _isFetchingLocation
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Getting current location...',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2E7D32),
                      fontFamily: _font,
                      fontWeight: FontWeight.w600)),
            ],
          )
              : GestureDetector(
            onTap: () async {
              setState(() => _isFetchingLocation = true);
              try {
                await controller.getCurrentLocation();
                if (mounted) {
                  setState(() {
                    _address1Ctrl.text = controller.addressLine1Controller.text;
                    _address2Ctrl.text = controller.addressLine2Controller.text;
                    _landmarkCtrl.text = controller.landmarkController.text;
                    _zipCtrl.text = controller.zipCodeController.text;
                  });
                }
              } catch (e) {
                Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
              } finally {
                if (mounted) setState(() => _isFetchingLocation = false);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                  ),
                  child: const Icon(Icons.my_location,
                      size: 12, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Use current location',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 15,
                    fontFamily: _font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Address Line 1
          _buildLabeledField(
            label: 'ADDRESS LINE 1',
            child: _InputField(
              controller: _address1Ctrl,
              hint: 'Address line 1',
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Please enter address' : null,
            ),
          ),
          const SizedBox(height: 14),

          // Address Line 2
          _buildLabeledField(
            label: 'ADDRESS LINE 2',
            child: _InputField(
              controller: _address2Ctrl,
              hint: 'Address line 2',
            ),
          ),
          const SizedBox(height: 14),

          // Landmark
          _buildLabeledField(
            label: 'LANDMARK',
            child: _InputField(
              controller: _landmarkCtrl,
              hint: 'Landmark',
            ),
          ),
          const SizedBox(height: 14),

          // City + State row
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'CITY',
                  child: GetBuilder<DetailsController>(
                    builder: (ctrl) => _DropdownTile(
                      value: ctrl.selectedCity?.name,
                      hint: 'City',
                      hasError: ctrl.cityErrorMessage.isNotEmpty,
                      errorText: ctrl.cityErrorMessage.value,
                      onTap: () {
                        if (ctrl.selectedState == null) {
                          Get.snackbar('Error', 'Please select state first');
                          return;
                        }
                        Get.bottomSheet(CitySheet());
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'STATE',
                  child: GetBuilder<DetailsController>(
                    builder: (ctrl) => _DropdownTile(
                      value: ctrl.selectedState?.name,
                      hint: 'State',
                      hasError: ctrl.stateErrorMessage.isNotEmpty,
                      errorText: ctrl.stateErrorMessage.value,
                      onTap: () => Get.bottomSheet(StateSheet()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Zip Code
          _buildLabeledField(
            label: 'ZIP CODE',
            child: _InputField(
              controller: _zipCtrl,
              hint: 'Zip Code',
              inputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter zip code';
                if (v.length != 6) return 'Zip code must be 6 digits';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 3: OPEN DAYS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOpenDaysCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('OPEN DAYS'),
          const SizedBox(height: 16),

          // Select open days label
          const Text(
            'SELECT OPEN DAYS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _labelColor,
              letterSpacing: 0.6,
              fontFamily: _font,
            ),
          ),
          const SizedBox(height: 10),

          // Day chips
          _buildDayChips(),
          const SizedBox(height: 20),

          // Start Time + End Time
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'START TIME',
                  child: _TimeTile(
                    value: controller.openTime?.format(context),
                    hint: 'Start Time',
                    onTap: () => _pickTime(context, true),
                    errorText: controller.startTimeErrorMessage.value,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'END TIME',
                  child: _TimeTile(
                    value: controller.closeTime?.format(context),
                    hint: 'End Time',
                    onTap: () => _pickTime(context, false),
                    errorText: controller.endTimeErrorMessage.value,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weekDays.map((day) {
        final selected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              selectedDays.remove(day);
            } else {
              selectedDays.add(day);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _primaryBlack : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? _primaryBlack : _borderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _dark,
                    fontFamily: _font,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => selectedDays.remove(day)),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom button ─────────────────────────────────────────────────────────
  Widget _buildBottomButton() {
    return Container(
      color: _pageBg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Obx(
            () => SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: controller.isLoadingOutlet.value ? null : _onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlack,
              disabledBackgroundColor: _primaryBlack.withOpacity(0.6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isLoadingOutlet.value
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
                : const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: _font,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared labeled-field wrapper ──────────────────────────────────────────
  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _labelColor,
            letterSpacing: 0.6,
            fontFamily: _font,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  @override
  void dispose() {
    _outletNameCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _landmarkCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

/// White card with rounded corners and subtle shadow
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sectionBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ALL-CAPS section title
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _dark,
        letterSpacing: 0.8,
        fontFamily: _font,
      ),
    );
  }
}

/// Reusable plain text input field
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.inputType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _dark,
        fontFamily: _font,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: _hintColor,
          fontFamily: _font,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _dark, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

/// Dropdown-style tap tile (for State/City)
class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.hint,
    required this.onTap,
    this.value,
    this.hasError = false,
    this.errorText,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : _borderColor,
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: _font,
                      color: value != null ? _dark : _hintColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _dark, size: 20),
              ],
            ),
          ),
        ),
        if (hasError && (errorText?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                  color: Colors.red, fontSize: 12, fontFamily: _font),
            ),
          ),
      ],
    );
  }
}

/// Time selector tile
class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.hint,
    required this.onTap,
    this.value,
    this.errorText,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (errorText?.isNotEmpty ?? false) ? Colors.red : _borderColor,
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: _font,
                      color: value != null ? _dark : _hintColor,
                    ),
                  ),
                ),
                const Icon(Icons.access_time_rounded, color: _dark, size: 18),
              ],
            ),
          ),
        ),
        if (errorText?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                  color: Colors.red, fontSize: 12, fontFamily: _font),
            ),
          ),
      ],
    );
  }
}