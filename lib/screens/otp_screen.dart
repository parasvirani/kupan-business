// Firebase auth is handled inside the controller; remove direct dependency here
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

/// Pixel-perfect OTP Verification Screen
/// Matches the Kupan Business design exactly.
/// Dependencies needed in pubspec.yaml:
///   - google_fonts: ^6.1.0  (for Inter font)
///
/// Replace the controller.verifyOtp / Get.back() calls with your own logic.

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ── Config ──────────────────────────────────────────────────────────────
  static const int _otpLength = 6;
  static const String _mobileNumber = '+91 945 69 721 58'; // fallback

  // ── Colors (from design) ─────────────────────────────────────────────────
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF9E9E9E);
  static const Color _primary = Color(0xFF1A1A1A); // black CTA
  static const Color _borderIdle = Color(0xFFE0E0E0);
  static const Color _borderFocus = Color(0xFF1A1A1A);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _errorRed = Color(0xFFD32F2F);

  // ── State ────────────────────────────────────────────────────────────────
  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());
  final LoginController controller = Get.put(LoginController());
  String _errorMessage = '';
  bool _isLoading = false;

  String get _pin => _controllers.map((c) => c.text).join();

  bool get _isPinComplete => _pin.length == _otpLength;
  var args = Get.arguments;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // move to next field
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {
      _errorMessage = '';
    });
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  Future<void> _verifyOTP() async {
    setState(() => _isLoading = true);

    try {
      final String? verificationId = args != null ? args['verificationId'] : null;

      if (verificationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification ID not found. Please request OTP again.')),
        );
        return;
      }

      // Delegate full verification (Firebase + backend) to the controller.
      // Await it so we can correctly update this screen's loading state.
      await controller.verifyOtp(
        args != null && args['mobile_number'] != null ? args['mobile_number'] : _mobileNumber,
        _pin.trim(),
        verificationId,
      );
    } catch (e) {
      // Show any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _resendOtp() {
    // TODO: implement resend logic
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() => _errorMessage = '');
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildLogo(),
              const SizedBox(height: 28),
              _buildTitle(),
              const SizedBox(height: 10),
              _buildSubtitle(),
              const SizedBox(height: 32),
              _buildOtpFields(),
              const SizedBox(height: 6),
              _buildErrorText(),
              const SizedBox(height: 20),
              _buildResendRow(),
              const SizedBox(height: 36),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _borderIdle, width: 1.5),
          ),
          child: const Icon(Icons.chevron_left_rounded,
              color: _dark, size: 22),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Kupan bird icon – using a bookmark icon as placeholder.
        // Replace with: Image.asset('assets/icons/kupan_logo.svg') or SvgPicture
        const Icon(Icons.bookmark, color: _dark, size: 26),
        const SizedBox(width: 6),
        Text(
          'KUPAN',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _dark,
            letterSpacing: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Otp Verification',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _dark,
        fontFamily: 'Inter',
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Inter',
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: 'We will send you an one time password\non this ',
            style: TextStyle(
              color: _grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: args != null && args['mobile_number'] != null
                ? args['mobile_number']
                : _mobileNumber,
            style: const TextStyle(
              color: _dark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < _otpLength - 1 ? 10 : 0),
          child: _OtpDigitBox(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            onChanged: (v) => _onDigitChanged(i, v),
            onKeyEvent: (e) => _onKeyEvent(i, e),
            borderIdle: _borderIdle,
            borderFocus: _borderFocus,
            textColor: _dark,
            size: 50,
          ),
        );
      }),
    );
  }

  Widget _buildErrorText() {
    return AnimatedOpacity(
      opacity: _errorMessage.isNotEmpty ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          _errorMessage,
          style: const TextStyle(
            color: _errorRed,
            fontSize: 13,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't receive otp?",
          style: TextStyle(
            fontSize: 14,
            color: _grey,
            fontFamily: 'Inter',
          ),
        ),
        GestureDetector(
          onTap: _resendOtp,
          child: Text(
            ' Resend OTP',
            style: const TextStyle(
              fontSize: 14,
              color: _dark,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final bool disabled = !_isPinComplete;
    return AnimatedOpacity(
      opacity: disabled ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: disabled || _isLoading ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: _primary,
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
              color: _white,
              strokeWidth: 2.5,
            ),
          )
              : Text(
            'OTP Verify',
            style: TextStyle(
              fontSize: 16,
              color: disabled ? Colors.white60 : Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual OTP digit box ───────────────────────────────────────────────
class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.borderIdle,
    required this.borderFocus,
    required this.textColor,
    required this.size,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final Color borderIdle;
  final Color borderFocus;
  final Color textColor;
  final double size;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKeyEvent,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isFocused ? widget.borderFocus : widget.borderIdle,
              width: _isFocused ? 1.8 : 1.4,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.textColor,
              fontFamily: 'Inter',
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}