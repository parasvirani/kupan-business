// ============================================================
// details_screen.dart  –  Drop-in replacement for DetailsScreen
// ============================================================
// pubspec.yaml dependencies to add:
//   image_picker: ^1.0.7
//   cached_network_image: ^3.3.1   (optional, for loading existing avatar)
//
// Keep your existing:
//   get, kupan_business controllers, routes, etc.
// ============================================================

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/dashboard_controller.dart';
import '../../services/api_service.dart';
import '../../utils/appRoutesStrings.dart';

// ── Inline PersonalInfo widget (previously a separate file) ────────────────
// If you already have a separate personal_info.dart with API calls,
// replace the _PersonalInfoState body with your controller calls and keep
// the UI from this file.

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  var args = Get.arguments as Map<String, dynamic>?;
  DashboardController? dashboardController;

  @override
  void initState() {
    super.initState();
    if (args != null && args!['isEdit'] == true) {
      dashboardController = Get.put(DashboardController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _PersonalInfoForm(
        isEdit: args?['isEdit'] ?? false,
        mobileNumber: args?['mobile_number'] ?? '',
        dashboardController: dashboardController,
        onSuccess: () {
          Get.toNamed(AppRoutes.dashboard, arguments: {"initialIndex": 1});
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: const Icon(Icons.chevron_left_rounded,
              color: Colors.black, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PersonalInfoForm  –  contains the full form + image picker
// Mirrors your existing PersonalInfo widget; wire your controller here.
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalInfoForm extends StatefulWidget {
  const _PersonalInfoForm({
    required this.isEdit,
    required this.mobileNumber,
    required this.onSuccess,
    this.dashboardController,
  });

  final bool isEdit;
  final String mobileNumber;
  final VoidCallback onSuccess;
  final DashboardController? dashboardController;

  @override
  State<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<_PersonalInfoForm> {
  // ── Design tokens ──────────────────────────────────────────────────────
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF9E9E9E);
  static const Color _labelGrey = Color(0xFF6B6B6B);
  static const Color _borderColor = Color(0xFFE8E8E8);
  static const Color _fillColor = Color(0xFFFAFAFA);
  static const Color _primary = Color(0xFF1A1A1A);
  static const Color _white = Colors.white;
  static const String _fontFamily = 'Inter';

  // ── Controllers ────────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _referralCtrl = TextEditingController();

  // ── Image picker ───────────────────────────────────────────────────────
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.mobileNumber;

    // If editing, pre-fill from dashboardController
    if (widget.isEdit && widget.dashboardController != null) {
      // TODO: populate fields from dashboardController
      // e.g. _nameCtrl.text = widget.dashboardController!.userName.value;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  // ── Image picker bottom sheet ──────────────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Photo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                  fontFamily: _fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              _SheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _SheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_pickedImage != null) ...[
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                _SheetOption(
                  icon: Icons.delete_outline,
                  label: 'Remove photo',
                  iconColor: Colors.red,
                  labelColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _pickedImage = null);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file != null) {
        setState(() => _pickedImage = file);
      }
    } on PlatformException catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────
  Future<void> _onContinue() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      
      // Step 1: Upload image if selected and get URL
      String? imageUrl;
      if (_pickedImage != null) {
        print("Uploading image...");
        try {
          final imageFile = File(_pickedImage!.path);
          final uploadResponse = await apiService.uploadImage(imageFile: imageFile);
          
          if (uploadResponse.statusCode == 200) {
            final uploadData = jsonDecode(uploadResponse.body);
            // Backend returns: { "data": ["https://cloudinary-url..."] }
            final data = uploadData['data'];
            if (data is List && data.isNotEmpty) {
              imageUrl = data[0]?.toString();
            } else if (data is String && data.isNotEmpty) {
              imageUrl = data;
            }
            if (imageUrl == null || imageUrl.isEmpty) {
              throw Exception('No image URL in upload response');
            }
          } else {
            throw Exception('Image upload failed (${uploadResponse.statusCode})');
          }
        } catch (e) {
          print("Image upload error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image upload failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // Step 2: Prepare user update data
      final updateData = <String, dynamic>{
        'name': name,
        'email': email,
      };
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['profilePic'] = imageUrl;
      }
      
      final referral = _referralCtrl.text.trim();
      if (referral.isNotEmpty) {
        updateData['referralCode'] = referral;
      }

      print("Updating user with data: $updateData");

      // Step 3: Call update user API
      final updateResponse = await apiService.updateUser(updateData);

      if (updateResponse.statusCode == 200) {
        try {
          final responseData = jsonDecode(updateResponse.body);
          print("User update response: $responseData");
          
          if (responseData is Map && responseData['success'] == true) {
            print("✓ User updated successfully");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            widget.onSuccess();
          } else {
            final message = responseData is Map ? (responseData['message'] ?? 'Update failed') : 'Update failed';
            throw Exception(message);
          }
        } catch (e) {
          print("Response parsing error: $e");
          throw Exception('Failed to parse update response: $e');
        }
      } else {
        try {
          final errorData = jsonDecode(updateResponse.body);
          final message = errorData is Map ? (errorData['message'] ?? 'Update failed') : 'Update failed';
          throw Exception(message);
        } catch (e) {
          throw Exception('Update failed with status ${updateResponse.statusCode}: $e');
        }
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildAvatar(),
          const SizedBox(height: 36),
          _buildField(
            label: 'FULL NAME',
            controller: _nameCtrl,
            hint: 'Enter your name',
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'PHONE NUMBER',
            controller: _phoneCtrl,
            hint: 'Enter your phone number',
            inputType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            readOnly: !widget.isEdit, // phone is pre-filled from OTP
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'EMAIL ADDRESS',
            controller: _emailCtrl,
            hint: 'Enter your email address',
            inputType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 36),
          _buildContinueButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Avatar with edit badge ─────────────────────────────────────────────
  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F0F0),
                border: Border.all(color: _white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipOval(
                child: _pickedImage != null
                    ? Image.file(
                  File(_pickedImage!.path),
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                )
                    : const Icon(
                  Icons.person_outline_rounded,
                  size: 52,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),

          // Edit badge — bottom-right
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.drive_file_rename_outline_rounded,
                  size: 16,
                  color: _dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Labeled text field ─────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _labelGrey,
            letterSpacing: 0.8,
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 6),
        // Input
        Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor, width: 1.4),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: inputType,
            textCapitalization: capitalization,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _dark,
              fontFamily: _fontFamily,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _grey,
                fontFamily: _fontFamily,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: readOnly,
              fillColor: readOnly ? const Color(0xFFF5F5F5) : null,
            ),
          ),
        ),
      ],
    );
  }

  // ── Continue button ────────────────────────────────────────────────────
  Widget _buildContinueButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          foregroundColor: _white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: _fontFamily,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: Bottom-sheet option row
// ─────────────────────────────────────────────────────────────────────────────
class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = const Color(0xFF1A1A1A),
    this.labelColor = const Color(0xFF1A1A1A),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}