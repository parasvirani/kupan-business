import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kupan_business/screens/otp_screen.dart';

void main() {
  testWidgets('vendor OTP screen builds with args and renders 6 digit fields',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Get.to(
      () => const OtpScreen(),
      arguments: {
        'verificationId': 'vid-123',
        'mobile_number': '+919876543210'
      },
    );
    await tester.pumpAndSettle();

    expect(find.byType(OtpScreen), findsOneWidget);
    // Six OTP digit boxes, each backed by a TextField.
    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('vendor OTP screen does not crash when args are null',
      (tester) async {
    // The vendor screen null-guards Get.arguments — verify it still builds.
    await tester.pumpWidget(const GetMaterialApp(home: OtpScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(OtpScreen), findsOneWidget);
  });
}
