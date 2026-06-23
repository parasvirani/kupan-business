import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/my_outlets_controller.dart';
import '../../models/kupans_list_res.dart';
import '../../models/redemptions_res.dart';
import '../../services/redemptions_service.dart';
import '../../utils/utils.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const Color _pageBg = Color(0xFFF5F5F5);
const Color _cardBg = Color(0xFFFFFFFF);
const Color _labelColor = Color(0xFF8A8A8A);
const Color _borderColor = Color(0xFFE4E4E4);
const Color _dark = Color(0xFF1A1A1A);
const String _font = 'Urbanist';

class AddKupanView extends StatefulWidget {
  final dynamic kupanToEdit;
  const AddKupanView({super.key, this.kupanToEdit});

  @override
  State<AddKupanView> createState() => _AddKupanViewState();
}

class _AddKupanViewState extends State<AddKupanView> {
  final DashboardController dc = Get.find();
  final MyOutletsController oc = Get.put(MyOutletsController());
  final _formKey = GlobalKey<FormState>();

  bool isEditMode = false;
  bool isOutletPreSelected = false;
  File? _lastPickedFile;

  // Coupon type options
  static const List<String> _kupanTypes = [
    'Buy 1 Get 1 Free',
    'Flat Discount',
    'Free Item',
    'Combo Deal',
    'Happy Hours',
    'Special Offer',
  ];

  @override
  void initState() {
    super.initState();
    // Reset form state on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dc.titleController.clear();
      dc.descriptionController.clear();
      dc.images?.clear();
      for (final d in dc.daysList) {
        d.isSelected = false;
      }
      dc.daysList.refresh();
      dc.errorMessageOutletSelection.value = '';
      dc.errorMessageDaySelection.value = '';
      dc.errorMessageCreateKupan.value = '';
      dc.errorMessageKupanType.value = '';

      if (widget.kupanToEdit != null) {
        isEditMode = true;
        _initEditMode();
      } else {
        if (dc.selectedOutletId.value.isNotEmpty) {
          isOutletPreSelected = true;
        } else {
          dc.selectedOutletId.value = '';
          dc.selectedOutletName.value = '';
          dc.selectedKupanType.value = '';
        }
      }
    });
  }

  void _initEditMode() {
    final k = widget.kupanToEdit;
    dc.titleController.text = k.title ?? '';
    dc.descriptionController.text = k.description ?? '';
    dc.selectedKupanType.value = k.kupanType ?? '';

    if (k is KupanData) {
      dc.selectedOutletId.value = k.businessId ?? '';
      dc.selectedOutletName.value =
          k.getOutletName() ?? k.outletName ?? '';
      isOutletPreSelected = true;
    } else if (k is RedemptionData) {
      dc.selectedOutletId.value = '';
      dc.selectedOutletName.value = '';
      isOutletPreSelected = false;
    }

    if (k.kupanDays != null) {
      final selected = (k.kupanDays as List)
          .where((d) => d != 'All')
          .map((d) => d.toString())
          .toSet();
      for (int i = 0; i < dc.daysList.length; i++) {
        dc.daysList[i].isSelected =
            selected.contains(dc.daysList[i].day);
      }
      dc.daysList.refresh();
    }
  }

  bool _validateAll() {
    bool valid = _formKey.currentState!.validate();

    if (dc.selectedOutletId.value.isEmpty) {
      dc.errorMessageOutletSelection.value = 'Please select an outlet';
      valid = false;
    } else {
      dc.errorMessageOutletSelection.value = '';
    }

    if (dc.selectedKupanType.value.isEmpty) {
      dc.errorMessageKupanType.value = 'Please select a coupon type';
      valid = false;
    } else {
      dc.errorMessageKupanType.value = '';
    }

    if (!dc.daysList.any((d) => d.isSelected)) {
      dc.errorMessageDaySelection.value = 'Please select at least one day';
      valid = false;
    } else {
      dc.errorMessageDaySelection.value = '';
    }

    return valid;
  }

  // ── Image helpers ───────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );

    if (cropped != null) {
      _lastPickedFile = File(cropped.path);
      dc.images?.add(_lastPickedFile!);
    }
  }

  void _showImagePickerSheet() {
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
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  // ── Save / Update ───────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_validateAll()) return;

    if (isEditMode) {
      await _updateKupan();
    } else {
      await _createKupan();
    }
  }

  Future<void> _createKupan() async {
    final outletId = dc.selectedOutletId.value;
    await dc.createKupan();

    if (dc.errorMessageCreateKupan.value.isEmpty &&
        dc.createKupanRes.value?.success == true) {
      if (outletId.isNotEmpty) {
        await oc.getOutletKupans(businessId: outletId);
      }
      final selectedOutlet = oc.outletsList
          .firstWhereOrNull((o) => o.id == outletId);
      Get.back(result: selectedOutlet ?? true);
    } else {
      _showError(dc.errorMessageCreateKupan.value.isEmpty
          ? 'Failed to create coupon'
          : dc.errorMessageCreateKupan.value);
    }
  }

  Future<void> _updateKupan() async {
    final k = widget.kupanToEdit;
    final selectedDays = dc.daysList
        .where((d) => d.isSelected)
        .map((d) => d.day!)
        .toList();

    try {
      dc.isLoadingCreateKupan.value = true;

      String? kupanId;
      List<String> kupanImages = [];

      if (k is RedemptionData) {
        kupanId = k.kupanId;
      } else {
        kupanId = k.id;
      }
      if (kupanId == null) throw Exception('Kupan ID missing');

      if (k.kupanImages != null && k.kupanImages!.isNotEmpty) {
        kupanImages.addAll(k.kupanImages!.cast<String>());
      }
      if (dc.images != null && dc.images!.isNotEmpty) {
        for (final f in dc.images!) {
          final url = await dc.uploadImage(f);
          if (url != null) kupanImages.add(url);
        }
      }

      await RedemptionsService().editKupan(
        kupanId: kupanId,
        title: dc.titleController.text.trim(),
        kupanImages: kupanImages,
        kupanDays: selectedDays,
      );

      _showSuccess('Coupon updated successfully');

      final vendorId = dc.selectedOutletId.value;
      if (k is KupanData && vendorId.isNotEmpty) {
        await dc.getVendorKupans(vendorId: vendorId);
      } else if (k is RedemptionData && vendorId.isNotEmpty) {
        await dc.fetchAllRedemptionRanges(vendorId: vendorId);
      }
      Get.back(result: true);
    } catch (e) {
      _showError('Failed to update coupon: ${e.toString()}');
    } finally {
      dc.isLoadingCreateKupan.value = false;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              size(16), size(16), size(16), size(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card 1: Outlet + Coupon Type ─────────────────────────────
              _card(
                child: Column(
                  children: [
                    _buildOutletSelector(),
                    _divider(),
                    _buildCouponTypeSelector(),
                  ],
                ),
              ),
              SizedBox(height: size(12)),

              // ── Card 2: Coupon Info ───────────────────────────────────────
              _card(
                label: 'COUPON INFO',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageUploadRow(),
                    SizedBox(height: size(16)),
                    _fieldLabel('OFFER TITLE'),
                    SizedBox(height: size(6)),
                    _buildTitleField(),
                    SizedBox(height: size(14)),
                    _fieldLabel('DESCRIPTION'),
                    SizedBox(height: size(6)),
                    _buildDescriptionField(),
                  ],
                ),
              ),
              SizedBox(height: size(12)),

              // ── Card 3: Valid Days ────────────────────────────────────────
              _card(
                label: 'VALID DAYS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('SELECT OPEN DAYS'),
                    SizedBox(height: size(10)),
                    _buildDayChips(),
                    Obx(() => dc.errorMessageDaySelection.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: size(6)),
                            child: Text(
                              dc.errorMessageDaySelection.value,
                              style: TextStyle(
                                  color: Colors.red, fontSize: size(12)),
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
              SizedBox(height: size(24)),

              // ── Save Button ───────────────────────────────────────────────
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: size(52),
                  child: ElevatedButton(
                    onPressed: dc.isLoadingCreateKupan.value ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dark,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size(10)),
                      ),
                      elevation: 0,
                    ),
                    child: dc.isLoadingCreateKupan.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            isEditMode ? 'Update Coupon' : 'Save Coupon',
                            style: TextStyle(
                              fontSize: size(16),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: _font,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _pageBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.all(size(10)),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _borderColor),
            ),
            child: Center(
              child: SvgPicture.asset(
                ImageConst.ic_back,
                width: size(18),
                height: size(18),
                colorFilter:
                    const ColorFilter.mode(_dark, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        isEditMode ? 'Edit coupon' : 'Add new coupon',
        style: TextStyle(
          fontSize: size(17),
          fontWeight: FontWeight.w700,
          color: _dark,
          fontFamily: _font,
        ),
      ),
    );
  }

  // ── Outlet Selector ─────────────────────────────────────────────────────────

  Widget _buildOutletSelector() {
    return Obx(() {
      if (oc.isLoading.value) {
        return _selectorShimmer('Loading outlets...');
      }

      // Pre-selected (edit mode or navigated from outlet)
      if (isOutletPreSelected && dc.selectedOutletId.value.isNotEmpty) {
        return _selectorField(
          label: 'SELECT OUTLET',
          value: dc.selectedOutletName.value,
          locked: true,
          error: dc.errorMessageOutletSelection.value,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('SELECT OUTLET'),
          SizedBox(height: size(8)),
          _dropdownContainer(
            hint: 'Select outlet',
            value: dc.selectedOutletId.value.isEmpty
                ? null
                : dc.selectedOutletId.value,
            items: oc.outletsList.map((o) {
              return DropdownMenuItem(
                value: o.id ?? '',
                child: Text(o.outletName ?? '',
                    style: TextStyle(
                        fontSize: size(14),
                        fontFamily: _font,
                        color: _dark)),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              final outlet = oc.outletsList
                  .firstWhere((o) => o.id == val);
              dc.selectedOutletId.value = val;
              dc.selectedOutletName.value = outlet.outletName ?? '';
              dc.errorMessageOutletSelection.value = '';
              oc.selectedOutletId.value = val;
              oc.selectedOutletName.value = outlet.outletName ?? '';
            },
          ),
          if (dc.errorMessageOutletSelection.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: size(4)),
              child: Text(dc.errorMessageOutletSelection.value,
                  style:
                      TextStyle(color: Colors.red, fontSize: size(12))),
            ),
        ],
      );
    });
  }

  // ── Coupon Type Selector ────────────────────────────────────────────────────

  Widget _buildCouponTypeSelector() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('SELECT COUPON TYPE'),
            SizedBox(height: size(8)),
            _dropdownContainer(
              hint: 'Select coupon type',
              value: dc.selectedKupanType.value.isEmpty
                  ? null
                  : dc.selectedKupanType.value,
              items: _kupanTypes.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t,
                      style: TextStyle(
                          fontSize: size(14),
                          fontFamily: _font,
                          color: _dark)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                dc.selectedKupanType.value = val;
                dc.errorMessageKupanType.value = '';
              },
            ),
            if (dc.errorMessageKupanType.value.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: size(4)),
                child: Text(dc.errorMessageKupanType.value,
                    style:
                        TextStyle(color: Colors.red, fontSize: size(12))),
              ),
          ],
        ));
  }

  // ── Image Upload Row ────────────────────────────────────────────────────────

  Widget _buildImageUploadRow() {
    return Obx(() {
      final newImages = dc.images ?? [];
      final existingUrls = (isEditMode &&
              widget.kupanToEdit?.kupanImages != null)
          ? (widget.kupanToEdit!.kupanImages as List).cast<String>()
          : <String>[];

      final totalCount = newImages.length + existingUrls.length;
      final canAddMore = totalCount < 4;

      return SizedBox(
        height: size(80),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Existing (network) images
            ...existingUrls.asMap().entries.map((e) {
              final idx = e.key;
              final url = e.value;
              return Padding(
                padding: EdgeInsets.only(right: size(10)),
                child: _imageThumbnail(
                  child: Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image)),
                  onRemove: () {
                    (widget.kupanToEdit!.kupanImages as List)
                        .removeAt(idx);
                    setState(() {});
                  },
                ),
              );
            }),
            // Newly picked local images
            ...newImages.asMap().entries.map((e) {
              final idx = e.key;
              final file = e.value;
              return Padding(
                padding: EdgeInsets.only(right: size(10)),
                child: _imageThumbnail(
                  child: Image.file(file, fit: BoxFit.cover),
                  onRemove: () {
                    dc.images?.removeAt(idx);
                  },
                ),
              );
            }),
            // Upload button
            if (canAddMore)
              GestureDetector(
                onTap: _showImagePickerSheet,
                child: Container(
                  width: size(80),
                  height: size(80),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorConst.primary.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(size(10)),
                    color:
                        ColorConst.primary.withValues(alpha: 0.04),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        ImageConst.icUpload,
                        width: size(24),
                        height: size(24),
                        colorFilter: ColorFilter.mode(
                            ColorConst.primary, BlendMode.srcIn),
                      ),
                      SizedBox(height: size(4)),
                      Text(
                        '$totalCount/4',
                        style: TextStyle(
                          fontSize: size(11),
                          color: ColorConst.primary,
                          fontFamily: _font,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _imageThumbnail(
      {required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size(10)),
          child: SizedBox(
            width: size(80),
            height: size(80),
            child: child,
          ),
        ),
        Positioned(
          top: size(4),
          left: size(4),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: size(22),
              height: size(22),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  ImageConst.icClose,
                  width: size(10),
                  height: size(10),
                  colorFilter: const ColorFilter.mode(
                      Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Title Field ─────────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return TextFormField(
      controller: dc.titleController,
      textCapitalization: TextCapitalization.sentences,
      style:
          TextStyle(fontSize: size(14), fontFamily: _font, color: _dark),
      decoration: _inputDecoration('Enter your offer title'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter offer title';
        if (v.trim().length < 2) return 'Title must be at least 2 characters';
        return null;
      },
    );
  }

  // ── Description Field ───────────────────────────────────────────────────────

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: dc.descriptionController,
      maxLines: 4,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      style:
          TextStyle(fontSize: size(14), fontFamily: _font, color: _dark),
      decoration: _inputDecoration('Enter coupon description'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter description';
        }
        if (v.trim().length < 2) {
          return 'Description must be at least 2 characters';
        }
        return null;
      },
    );
  }

  // ── Day Chips ───────────────────────────────────────────────────────────────

  Widget _buildDayChips() {
    return Obx(() => Wrap(
          spacing: size(8),
          runSpacing: size(8),
          children: List.generate(dc.daysList.length, (i) {
            final day = dc.daysList[i];
            final selected = day.isSelected;
            return GestureDetector(
              onTap: () => dc.daySelector(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                    horizontal: size(14), vertical: size(7)),
                decoration: BoxDecoration(
                  color: selected ? _dark : Colors.white,
                  borderRadius: BorderRadius.circular(size(20)),
                  border: Border.all(
                    color: selected ? _dark : _borderColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.day ?? '',
                      style: TextStyle(
                        fontSize: size(13),
                        fontWeight: FontWeight.w600,
                        fontFamily: _font,
                        color: selected ? Colors.white : _dark,
                      ),
                    ),
                    if (selected) ...[
                      SizedBox(width: size(4)),
                      Container(
                        width: size(14),
                        height: size(14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.close,
                              size: 10, color: _dark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ));
  }

  // ── Shared Widgets ──────────────────────────────────────────────────────────

  Widget _card({String? label, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(size(12)),
        border: Border.all(color: _borderColor, width: 1),
      ),
      padding: EdgeInsets.all(size(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: size(11),
                fontWeight: FontWeight.w700,
                color: _labelColor,
                fontFamily: _font,
                letterSpacing: 0.6,
              ),
            ),
            SizedBox(height: size(12)),
          ],
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size(11),
        fontWeight: FontWeight.w600,
        color: _labelColor,
        fontFamily: _font,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size(14)),
      child: const Divider(color: _borderColor, height: 1),
    );
  }

  Widget _dropdownContainer({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size(14)),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(size(10)),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
              fontSize: size(14),
              fontFamily: _font,
              color: const Color(0xFFAAAAAA)),
        ),
        icon: SvgPicture.asset(
          ImageConst.icDown,
          width: size(18),
          height: size(18),
          colorFilter:
              const ColorFilter.mode(Color(0xFFAAAAAA), BlendMode.srcIn),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _selectorField({
    required String label,
    required String value,
    bool locked = false,
    String error = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: size(8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: size(14), vertical: size(13)),
          decoration: BoxDecoration(
            border: Border.all(
              color: locked
                  ? ColorConst.primary.withValues(alpha: 0.4)
                  : _borderColor,
              width: locked ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(size(10)),
            color: locked
                ? ColorConst.primary.withValues(alpha: 0.04)
                : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: size(14),
                    fontFamily: _font,
                    color: _dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (locked)
                Icon(Icons.check_circle,
                    color: ColorConst.primary, size: size(18)),
            ],
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: size(4)),
            child: Text(error,
                style: TextStyle(color: Colors.red, fontSize: size(12))),
          ),
      ],
    );
  }

  Widget _selectorShimmer(String msg) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: size(13), horizontal: size(14)),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(size(10)),
      ),
      child: Row(
        children: [
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: size(10)),
          Text(msg,
              style: TextStyle(
                  fontSize: size(14),
                  fontFamily: _font,
                  color: _labelColor)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: size(14), fontFamily: _font, color: const Color(0xFFAAAAAA)),
      contentPadding: EdgeInsets.symmetric(
          horizontal: size(14), vertical: size(12)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(10)),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(10)),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(10)),
        borderSide: const BorderSide(color: _dark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(10)),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(10)),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
