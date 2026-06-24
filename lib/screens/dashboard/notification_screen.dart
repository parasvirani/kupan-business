import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../common_view/common_text.dart';
import '../../const/color_const.dart';
import '../../const/image_const.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingRead = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return DateFormat('dd MMM').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        setState(() {
          _notifications = (data != null && data['notifications'] != null)
              ? data['notifications'] as List<dynamic>
              : [];
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications (${response.statusCode})';
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Something went wrong';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingRead = true);
    try {
      await _apiService.markAllNotificationsRead();
      await _fetchNotifications();
    } catch (_) {
      Get.snackbar('Error', 'Failed to mark notifications as read',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isMarkingRead = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConst.ic_back,
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
        title: CommonText(
          text: 'Notifications',
          fontSize: size(17),
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (_isMarkingRead)
            Padding(
              padding: EdgeInsets.only(right: size(16)),
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: ColorConst.primary,
                  fontSize: size(13),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: ColorConst.primary,
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? ListView.builder(
                padding: EdgeInsets.all(size(16)),
                itemCount: 6,
                itemBuilder: (_, __) => _buildShimmerItem(),
              )
            : _error != null
                ? ListView(
                    padding: EdgeInsets.all(size(16)),
                    children: [
                      SizedBox(height: size(60)),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: size(48), color: Colors.grey[300]),
                            SizedBox(height: size(12)),
                            CommonText(
                              text: _error!,
                              fontSize: size(14),
                              color: ColorConst.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _notifications.isEmpty
                    ? ListView(
                        padding: EdgeInsets.all(size(16)),
                        children: [
                          SizedBox(height: size(60)),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.notifications_none_outlined,
                                    size: size(52), color: Colors.grey[300]),
                                SizedBox(height: size(12)),
                                CommonText(
                                  text: 'No notifications yet',
                                  fontSize: size(15),
                                  color: ColorConst.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: size(6)),
                                CommonText(
                                  text:
                                      'You\'ll be notified when customers\nredeem your Kupans.',
                                  fontSize: size(13),
                                  color: Colors.grey[400]!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(size(16)),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: size(10)),
                        itemBuilder: (_, index) =>
                            _buildNotificationItem(_notifications[index]),
                      ),
      ),
    );
  }

  Widget _buildNotificationItem(dynamic n) {
    final type = n['type'] as String? ?? '';
    final title = n['title'] as String? ?? '';
    final message = n['message'] as String? ?? '';
    final time = _formatTime(n['createdAt'] as String?);
    final isRead = n['isRead'] as bool? ?? false;

    final config = _notificationConfig(type);

    return Container(
      padding: EdgeInsets.all(size(14)),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFF5F2),
        borderRadius: BorderRadius.circular(size(10)),
        border: Border.all(
          color: isRead
              ? Colors.grey.shade100
              : ColorConst.primary.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: size(44),
            height: size(44),
            decoration: BoxDecoration(
              color: config.bgColor,
              borderRadius: BorderRadius.circular(size(10)),
            ),
            child: Icon(config.icon, color: config.iconColor, size: size(22)),
          ),
          SizedBox(width: size(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        text: title,
                        fontSize: size(13),
                        fontWeight: FontWeight.w700,
                        color: ColorConst.dark,
                      ),
                    ),
                    SizedBox(width: size(6)),
                    CommonText(
                      text: time,
                      fontSize: size(11),
                      color: Colors.grey[400]!,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                SizedBox(height: size(3)),
                CommonText(
                  text: message,
                  fontSize: size(13),
                  color: ColorConst.grey,
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                ),
                // Redemption type chip
                if (type == 'VENDOR_KUPAN_REDEEMED') ...[
                  SizedBox(height: size(6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size(8), vertical: size(3)),
                    decoration: BoxDecoration(
                      color: ColorConst.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(size(4)),
                    ),
                    child: Text(
                      'Coupon Redeemed',
                      style: TextStyle(
                        fontSize: size(10),
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primary,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isRead)
            Padding(
              padding: EdgeInsets.only(left: size(6), top: size(2)),
              child: Container(
                width: size(7),
                height: size(7),
                decoration: BoxDecoration(
                  color: ColorConst.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _NotifConfig _notificationConfig(String type) {
    switch (type) {
      case 'VENDOR_KUPAN_REDEEMED':
        return _NotifConfig(
          icon: Icons.local_offer_rounded,
          iconColor: ColorConst.primary,
          bgColor: ColorConst.primary.withValues(alpha: 0.1),
        );
      case 'COIN_GENERATED':
        return _NotifConfig(
          icon: Icons.monetization_on_rounded,
          iconColor: Colors.amber[700]!,
          bgColor: Colors.amber.withValues(alpha: 0.12),
        );
      case 'SYSTEM':
        return _NotifConfig(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
      default:
        return _NotifConfig(
          icon: Icons.notifications_outlined,
          iconColor: Colors.grey[600]!,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.only(bottom: size(10)),
        padding: EdgeInsets.all(size(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size(44),
              height: size(44),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(size(10)),
              ),
            ),
            SizedBox(width: size(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: size(12), width: size(130), color: Colors.grey),
                  SizedBox(height: size(8)),
                  Container(
                      height: size(12),
                      width: double.infinity,
                      color: Colors.grey),
                  SizedBox(height: size(4)),
                  Container(
                      height: size(12), width: size(80), color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _NotifConfig(
      {required this.icon,
      required this.iconColor,
      required this.bgColor});
}
