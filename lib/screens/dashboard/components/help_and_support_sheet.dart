import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../const/color_const.dart';
import '../../../utils/utils.dart';

class HelpAndSupportSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SupportContent(),
    );
  }
}

class _SupportContent extends StatelessWidget {
  const _SupportContent({Key? key}) : super(key: key);

  Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'KUPAN Partner / Vendor Support Request',
      },
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyToClipboard(email, 'Email copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(email, 'Email copied to clipboard');
    }
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _copyToClipboard(url, 'Link copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(url, 'Link copied to clipboard');
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.symmetric(horizontal: size(20), vertical: size(18)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: size(44),
                height: size(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: size(16)),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(size(10)),
                  decoration: BoxDecoration(
                    color: ColorConst.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(size(12)),
                  ),
                  child: Icon(Icons.headset_mic_rounded,
                      color: ColorConst.primary, size: size(24)),
                ),
                SizedBox(width: size(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Help & Support",
                        style: TextStyle(
                          fontSize: size(18),
                          fontWeight: FontWeight.w700,
                          color: ColorConst.dark,
                        ),
                      ),
                      SizedBox(height: size(2)),
                      Text(
                        "We are here to assist our merchant partners",
                        style: TextStyle(
                          fontSize: size(12),
                          color: ColorConst.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: size(20)),
            // Partner Desk Card
            _contactTile(
              icon: Icons.business_center_outlined,
              title: "Partner Inquiry & Onboarding",
              subtitle: "inquiry@kupanapp.com",
              badge: "Partner Desk",
              onTap: () => _launchEmail("inquiry@kupanapp.com"),
              onCopy: () => _copyToClipboard("inquiry@kupanapp.com", "Partner email copied"),
            ),
            SizedBox(height: size(12)),
            // Customer & Technical Support
            _contactTile(
              icon: Icons.support_agent_outlined,
              title: "Vendor Technical Support",
              subtitle: "support@kupanapp.com",
              badge: "General",
              onTap: () => _launchEmail("support@kupanapp.com"),
              onCopy: () => _copyToClipboard("support@kupanapp.com", "Support email copied"),
            ),
            SizedBox(height: size(12)),
            // Official Website
            _contactTile(
              icon: Icons.language_outlined,
              title: "Official Website",
              subtitle: "https://kupanapp.com",
              badge: "Web",
              onTap: () => _launchWebsite("https://kupanapp.com"),
              onCopy: () => _copyToClipboard("https://kupanapp.com", "Website link copied"),
            ),
            SizedBox(height: size(24)),
            // Note
            Container(
              padding: EdgeInsets.all(size(12)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(size(10)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey.shade600, size: size(18)),
                  SizedBox(width: size(10)),
                  Expanded(
                    child: Text(
                      "Support response time: Usually within 24 to 48 business hours.",
                      style: TextStyle(
                        fontSize: size(12),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size(12)),
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size(12)),
      child: Container(
        padding: EdgeInsets.all(size(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size(12)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size(10)),
              decoration: BoxDecoration(
                color: ColorConst.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(size(10)),
              ),
              child: Icon(icon, color: ColorConst.primary, size: size(20)),
            ),
            SizedBox(width: size(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: size(14),
                            fontWeight: FontWeight.w600,
                            color: ColorConst.dark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: size(6)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: size(6), vertical: size(2)),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(size(4)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: size(10),
                            fontWeight: FontWeight.w600,
                            color: ColorConst.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size(3)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: size(12),
                      color: ColorConst.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy_rounded, size: size(18), color: Colors.grey.shade500),
              tooltip: "Copy",
              onPressed: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}
