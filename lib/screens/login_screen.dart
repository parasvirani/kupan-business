import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../utils/appRoutesStrings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController _phoneController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendOTP() async {
    // setState(() => _isLoading = true);
    controller.isLoading(true);

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_phoneController.text.trim()}',
      timeout: const Duration(seconds: 60),

      // ✅ Auto OTP verify (Android only)
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        // _goToHome();
        String? idToken = await userCredential.user?.getIdToken();
        print("Auto Verified - ID Token:::$idToken");

        if (idToken != null) {
          // Step 3: Direct backend call karo — verificationId ni zaroorat nathi
          await controller.verifyOtpWithToken(idToken);
        }
        // Get.toNamed(AppRoutes.dashboard);
      },

      // ❌ Verification failed
      verificationFailed: (FirebaseAuthException e) {
        // setState(() => _isLoading = false);
        controller.isLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      },

      // 📩 OTP sent — OTP screen pe jao
      codeSent: (String verificationId, int? resendToken) {
        controller.isLoading(false);
        Get.toNamed(AppRoutes.otp, arguments: {"mobile_number" : '+91${_phoneController.text.trim()}', "verificationId": verificationId});
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => OTPScreen(verificationId: verificationId),
        //   ),
        // );
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Back button ──────────────────────────────────────────
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 22,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Logo row: icon + "KUPAN" ─────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Replace with your actual SVG/PNG asset
                        SvgPicture.asset(
                          'assets/images/kupan_icon.svg',
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF111827),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'KUPAN',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Heading ──────────────────────────────────────────────
                  const Center(
                    child: Text(
                      'Welcome to KUPAN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ─────────────────────────────────────────────
                  const Center(
                    child: Text(
                      'Sign in to unlock exclusive deals and start\nsaving instantly!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'Inter',
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Field label ──────────────────────────────────────────
                  const Text(
                    'PHONE NUMBER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Phone text field ─────────────────────────────────────
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFD1D5DB),
                        fontFamily: 'Inter',
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 10),
                        child: Icon(
                          Icons.phone_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF111827),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Enter valid Indian mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Send OTP button ──────────────────────────────────────
                  Obx(
                        () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _sendOTP();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          disabledBackgroundColor:
                          const Color(0xFF111827).withOpacity(0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Send to Otp',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Inter',
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}