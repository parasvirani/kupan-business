import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/approval_controller.dart';

class VendorApprovalHelper {
  /// Checks if the vendor's account is approved by admin.
  /// If not approved (pending or rejected), shows a descriptive dialog informing
  /// the vendor that their account verification is pending review.
  /// Returns `true` if approved, `false` if pending/rejected.
  static Future<bool> checkApprovalAndProceed({
    required BuildContext context,
    String? customMessage,
  }) async {
    final approvalCtrl = Get.isRegistered<ApprovalController>()
        ? Get.find<ApprovalController>()
        : Get.put(ApprovalController());

    // Show quick loading if checking
    final status = await approvalCtrl.checkStatus();

    if (status == 'approved') {
      return true;
    }

    // If pending or rejected, show informative dialog
    final bool isRejected = status == 'rejected';
    final String reason = approvalCtrl.rejectionReason.value;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRejected
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRejected ? Icons.error_outline : Icons.access_time_rounded,
                  color: isRejected
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFD97706),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRejected
                    ? 'Verification Rejected'
                    : 'Business Verification Pending',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isRejected
                    ? (reason.isNotEmpty
                        ? 'Your account has been rejected: $reason\nPlease correct the details and submit again.'
                        : 'Your account has been rejected. Please contact support.')
                    : (customMessage ??
                        'Your business verification is currently under review by the KUPAN team. You will be able to add and manage coupons once your business is approved.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return false;
  }
}

