import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/image_const.dart';
import '../controllers/dashboard_controller.dart';
import '../utils/appRoutesStrings.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Obx(() {
          final hasUnread = dashboardController.unreadNotificationCount.value > 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                ImageConst.notification2,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              if (hasUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
                    ),
                  ),
                ),
            ],
          );
        }),
        onPressed: () async {
          await Get.toNamed(AppRoutes.notification);
          // Refresh unread count when returning
          dashboardController.fetchUnreadNotificationsCount();
        },
      ),
    );
  }
}

