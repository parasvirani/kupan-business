import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../const/color_const.dart';
import '../../utils/utils.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            color: Colors.black,
            fontSize: size(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size(20), vertical: size(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(size(14)),
              decoration: BoxDecoration(
                color: ColorConst.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(size(10)),
                border: Border.all(color: ColorConst.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: ColorConst.primary, size: size(22)),
                  SizedBox(width: size(10)),
                  Expanded(
                    child: Text(
                      "By registering and using the KUPAN Vendor App, you agree to these terms.",
                      style: TextStyle(
                        fontSize: size(13),
                        color: ColorConst.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size(20)),
            _section(
              number: "1",
              title: "Accurate Information & Onboarding",
              content:
                  "Vendors must provide genuine, complete, and up-to-date business details, outlet locations, contact information, and valid business registration/tax documents during registration and profile updates.",
            ),
            _section(
              number: "2",
              title: "Verification & Admin Approval",
              content:
                  "All vendor profiles, outlets, and created coupons are subject to prior review, verification, and approval by the KUPAN Admin team. Only approved outlets and verified coupons will be published and made visible to customers on the KUPAN platform.",
            ),
            _section(
              number: "3",
              title: "Genuine Offers & Transparency",
              content:
                  "Vendors must provide the advertised discount, freebie, or promotional offer exactly as specified in the approved coupon. Misleading pricing, hidden mandatory charges, or altering terms at the outlet without prior notice is strictly prohibited.",
            ),
            _section(
              number: "4",
              title: "Coupon Redemption & Acceptance",
              content:
                  "• Vendors and their staff must honour active and valid coupons presented by customers through the official KUPAN app during the stated validity period, active days, and opening hours.\n• Coupons have no cash value and cannot be exchanged for physical currency.\n• Redemptions must be verified strictly using the designated in-app scanning mechanism.",
            ),
            _section(
              number: "5",
              title: "Taxes & Statutory Compliance",
              content:
                  "Vendors are solely responsible for calculating, collecting, and remitting any applicable government taxes (including GST and local levies) on the final discounted bill amount. KUPAN operates solely as a discovery and promotional technology platform.",
            ),
            _section(
              number: "6",
              title: "Product & Service Responsibility",
              content:
                  "Vendors bear full legal and operational responsibility for their products, services, quality, food safety, pricing, hygienic standards, licensing (such as FSSAI, Shop & Establishment, etc.), and customer service. KUPAN shall not be liable for any claims, damages, or disputes arising between vendors and customers.",
            ),
            _section(
              number: "7",
              title: "Fair Usage & Anti-Fraud Policy",
              content:
                  "Any form of fraudulent activity—including self-redemption, artificial inflation of redemptions, collusion, misuse of customer contact data, or unauthorized access to the platform—is strictly prohibited and may result in immediate suspension and legal action.",
            ),
            _section(
              number: "8",
              title: "Right to Audit, Suspension & Termination",
              content:
                  "KUPAN reserves the unconditional right to reject, restrict, pause, or permanently terminate any vendor account, or remove specific coupons without prior notice, if the vendor breaches these terms, engages in fraudulent behavior, or receives repetitive customer complaints.",
            ),
            _section(
              number: "9",
              title: "Platform Updates & Amendments",
              content:
                  "KUPAN reserves the right to modify or update these terms at any time. Continued use of the KUPAN Business App after such updates constitutes acceptance of the modified terms.",
            ),
            _section(
              number: "10",
              title: "Contact & Support",
              content:
                  "For questions, disputes, or vendor support:\n• Email: support@kupanapp.com / inquiry@kupanapp.com\n• Website: www.kupanapp.com",
            ),
            SizedBox(height: size(20)),
            Center(
              child: Text(
                "KUPAN – SPEND LESS. SAVE MORE.",
                style: TextStyle(
                  fontSize: size(14),
                  fontWeight: FontWeight.w700,
                  color: ColorConst.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: size(30)),
          ],
        ),
      ),
    );
  }

  Widget _section({required String number, required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: size(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size(24),
                height: size(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorConst.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: size(12),
                    fontWeight: FontWeight.w700,
                    color: ColorConst.primary,
                  ),
                ),
              ),
              SizedBox(width: size(10)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: size(15),
                    fontWeight: FontWeight.w700,
                    color: ColorConst.dark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size(6)),
          Padding(
            padding: EdgeInsets.only(left: size(34)),
            child: Text(
              content,
              style: TextStyle(
                fontSize: size(13),
                height: 1.5,
                color: ColorConst.textGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
