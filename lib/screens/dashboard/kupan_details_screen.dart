import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/color_const.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/kupans_list_res.dart';
import '../../utils/utils.dart';
import 'add_kupan_view.dart';

/// Read-only details for a single kupan. Opened by tapping a list item.
/// Editing routes to [AddKupanView]; because an edit sends the coupon back for
/// admin re-review, the screen refreshes to reflect the new (Pending) status.
class KupanDetailsScreen extends StatefulWidget {
  final KupanData kupan;
  const KupanDetailsScreen({super.key, required this.kupan});

  @override
  State<KupanDetailsScreen> createState() => _KupanDetailsScreenState();
}

class _KupanDetailsScreenState extends State<KupanDetailsScreen> {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  static const Color _dark = Color(0xFF1A1A1A);
  static const List<String> _weekOrder = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  late KupanData kupan;

  @override
  void initState() {
    super.initState();
    kupan = widget.kupan;
  }

  ({String label, Color color}) _status() {
    if (kupan.isCancelled == true) {
      return (label: 'Cancelled', color: const Color(0xFFEF4444));
    } else if (kupan.isPaused == true) {
      return (label: 'Paused', color: const Color(0xFFF59E0B));
    } else if (kupan.isVerified == true) {
      return (label: 'Approved', color: const Color(0xFF12B76A));
    }
    return (label: 'Pending', color: const Color(0xFFF59E0B));
  }

  Future<void> _onEdit() async {
    final result = await Get.to(() => AddKupanView(kupanToEdit: kupan));
    if (result == true) {
      // Edit went to admin for re-review; leave details so the refreshed list
      // (now showing the Pending badge) is visible.
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _status();
    final imageUrl =
        kupan.kupanImages?.isNotEmpty == true ? kupan.kupanImages![0] : null;
    final address = kupan.getOutletAddress() ?? kupan.outletAddress ?? '';
    final outletName = kupan.getOutletName() ?? kupan.outletName ?? '';
    final days = kupan.kupanDays ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Coupon Details',
          style: TextStyle(
            fontSize: size(18),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(size(16), size(16), size(16), size(100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + status
            ClipRRect(
              borderRadius: BorderRadius.circular(size(14)),
              child: SizedBox(
                height: size(190),
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl != null
                        ? Image.network(imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                    Positioned(
                      top: size(10),
                      left: size(10),
                      child: _pill(s.label, s.color),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size(16)),

            // Title
            Text(
              kupan.title ?? 'Coupon',
              style: TextStyle(
                fontSize: size(20),
                fontWeight: FontWeight.w700,
                color: _dark,
                fontFamily: 'Urbanist',
              ),
            ),
            if ((kupan.description ?? '').trim().isNotEmpty) ...[
              SizedBox(height: size(6)),
              Text(
                kupan.description!.trim(),
                style: TextStyle(
                  fontSize: size(14),
                  color: ColorConst.grey,
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
            SizedBox(height: size(16)),

            // Info card
            _card(
              child: Column(
                children: [
                  if (outletName.isNotEmpty)
                    _infoRow(Icons.store_outlined, 'Outlet', outletName),
                  if (address.isNotEmpty)
                    _infoRow(Icons.location_on_outlined, 'Address', address),
                ],
              ),
            ),
            SizedBox(height: size(14)),

            // Offer days
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OFFER DAYS',
                      style: TextStyle(
                        fontSize: size(12),
                        fontWeight: FontWeight.w700,
                        color: ColorConst.grey,
                        letterSpacing: 0.5,
                        fontFamily: 'Urbanist',
                      )),
                  SizedBox(height: size(10)),
                  Wrap(
                    spacing: size(8),
                    runSpacing: size(8),
                    children: _weekOrder.map((d) {
                      final on = days.any((x) =>
                          x.toLowerCase().startsWith(d.toLowerCase()));
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size(12), vertical: size(6)),
                        decoration: BoxDecoration(
                          color: on
                              ? ColorConst.primary.withValues(alpha: 0.12)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(size(8)),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: size(12),
                            fontWeight: FontWeight.w600,
                            color: on ? ColorConst.primary : ColorConst.grey,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Pending-review note after an edit or new creation
            if (kupan.isVerified != true &&
                kupan.isCancelled != true &&
                kupan.isPaused != true) ...[
              SizedBox(height: size(14)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size(14)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(size(12)),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFFB45309), size: 22),
                        SizedBox(width: size(8)),
                        Expanded(
                          child: Text(
                            'Coupon Approval Pending',
                            style: TextStyle(
                              fontSize: size(14.5),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size(8)),
                    Text(
                      'Your coupon has been submitted successfully and is currently awaiting review by the KUPAN admin team. Once approved, it will become visible to customers in the KUPAN app.',
                      style: TextStyle(
                        fontSize: size(12.5),
                        color: const Color(0xFF92400E),
                        fontFamily: 'Urbanist',
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: size(10)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size(10),
                        vertical: size(4),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(size(6)),
                      ),
                      child: Text(
                        'Status: Awaiting Kupan Approval',
                        style: TextStyle(
                          fontSize: size(11.5),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF78350F),
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size(16)),
          child: SizedBox(
            height: size(52),
            child: ElevatedButton.icon(
              onPressed: _onEdit,
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size(12)),
                ),
              ),
              label: Text(
                'Edit Coupon',
                style: TextStyle(
                  fontSize: size(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFEDEDED),
        child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD)),
      );

  Widget _pill(String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: size(10), vertical: size(5)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: size(12),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Urbanist',
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(size(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size(14)),
          border: Border.all(color: const Color(0x1A1A1A1A)),
        ),
        child: child,
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: size(6)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: size(18), color: ColorConst.grey),
            SizedBox(width: size(10)),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: size(13.5),
                fontWeight: FontWeight.w600,
                color: ColorConst.grey,
                fontFamily: 'Urbanist',
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: size(13.5),
                  fontWeight: FontWeight.w600,
                  color: _dark,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ],
        ),
      );
}
