import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common_view/common_button.dart';
import '../common_view/common_text.dart';
import '../const/color_const.dart';
import '../controllers/approval_controller.dart';
import '../utils/appRoutesStrings.dart';
import '../utils/utils.dart';

/// Shown to a vendor whose account is not yet approved. Polls the backend and,
/// once approved, forwards to the dashboard. Handles the rejected state with a
/// reason and an "update details & resubmit" path back to pending.
class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  final ApprovalController controller = Get.put(ApprovalController());

  static const Color _dark = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    // Redirect to the dashboard as soon as the status flips to approved.
    ever(controller.status, (String s) {
      if (s == 'approved' && mounted) {
        controller.stopPolling();
        Get.offAllNamed(AppRoutes.dashboard);
      }
    });
    // Initial check, then light polling.
    controller.checkStatus();
    controller.startPolling();
  }

  Future<void> _resubmit() async {
    // Reopen the profile form pre-filled; saving resets the account to pending
    // server-side and returns to this waiting screen.
    controller.stopPolling();
    await Get.toNamed(
      AppRoutes.details,
      arguments: {"isEdit": true, "resubmit": true},
    );
    controller.startPolling();
    controller.checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size(28)),
          child: Obx(() {
            final rejected = controller.isRejected;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon badge
                Container(
                  width: size(96),
                  height: size(96),
                  decoration: BoxDecoration(
                    color: (rejected ? ColorConst.primary : ColorConst.secondary)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rejected
                        ? Icons.info_outline_rounded
                        : Icons.hourglass_top_rounded,
                    color: rejected ? ColorConst.primary : ColorConst.secondary,
                    size: size(46),
                  ),
                ),
                SizedBox(height: size(28)),

                // Title
                CommonText(
                  text: rejected
                      ? 'Account not approved'
                      : 'Waiting for admin approval',
                  textAlign: TextAlign.center,
                  fontSize: size(22),
                  color: ColorConst.white,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: size(12)),

                // Subtext
                CommonText(
                  text: rejected
                      ? 'An admin has reviewed your account and it wasn’t approved. You can update your details and resubmit for another review.'
                      : 'Your account has been created and is under review. An admin will approve it shortly — you’ll get access to the app as soon as that’s done.',
                  textAlign: TextAlign.center,
                  fontSize: size(14),
                  color: ColorConst.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),

                // Rejection reason (if any)
                if (rejected && controller.rejectionReason.value.isNotEmpty) ...[
                  SizedBox(height: size(20)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size(14)),
                    decoration: BoxDecoration(
                      color: ColorConst.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorConst.primary.withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: 'REASON',
                          fontSize: size(11),
                          color: ColorConst.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: size(6)),
                        CommonText(
                          text: controller.rejectionReason.value,
                          fontSize: size(14),
                          color: ColorConst.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ],

                // Inline error (e.g. network) — non-blocking
                if (controller.errorMessage.value.isNotEmpty) ...[
                  SizedBox(height: size(16)),
                  CommonText(
                    text: controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    fontSize: size(12),
                    color: ColorConst.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                ],

                SizedBox(height: size(36)),

                // Primary action
                SizedBox(
                  width: double.infinity,
                  child: rejected
                      ? CommonButton(
                          text: 'Update details & resubmit',
                          onPressed: _resubmit,
                        )
                      : CommonButton(
                          isLoading: controller.isChecking.value,
                          text: 'Refresh',
                          onPressed: () => controller.checkStatus(),
                        ),
                ),

                // Secondary: manual refresh for the rejected view too
                if (rejected) ...[
                  SizedBox(height: size(12)),
                  TextButton(
                    onPressed: controller.isChecking.value
                        ? null
                        : () => controller.checkStatus(),
                    child: CommonText(
                      text: controller.isChecking.value
                          ? 'Checking…'
                          : 'Refresh status',
                      fontSize: size(14),
                      color: ColorConst.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
