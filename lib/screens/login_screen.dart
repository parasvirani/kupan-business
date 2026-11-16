import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/phone_utils.dart';

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

    final phone = normalizePhone(_phoneController.text);

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      // ✅ Auto OTP verify (Android only)
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        // _goToHome();
        String? idToken = await userCredential.user?.getIdToken();

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
        Get.toNamed(AppRoutes.otp, arguments: {
          "mobile_number": phone,
          "verificationId": verificationId,
          "resendToken": resendToken,
        });
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

                  // ── Logo: KUPAN ─────────────────────────────
                  Center(
                    child: Image.asset(
                      'assets/icon/kupan_hori.png',
                      width: Get.width * 0.65,
                      fit: BoxFit.contain,
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
                      'Connect with more customers and grow your business\nwith exclusive offers.',
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
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '98765 43210',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFD1D5DB),
                        fontFamily: 'Inter',
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              height: 18,
                              child: VerticalDivider(
                                color: Color(0xFFD1D5DB),
                                thickness: 1.2,
                                width: 1,
                              ),
                            ),
                            SizedBox(width: 4),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 90,
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
                                'Send Otp',
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
