import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:kupan_business/services/notification_service.dart';

// Background/terminated: FCM shows the notification natively (notification field present).
// No need to use flutter_local_notifications here — it's not initialized in this isolate.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // no-op: system tray notification is handled by FCM automatically
}

class PushService {
  PushService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Returns the FCM token, or null if unavailable.
  static Future<String?> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await NotificationService.initialize();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification != null) {
        await NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    try {
      final token = await _messaging.getToken();
      if (kDebugMode) print('Vendor FCM Token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) print('Error getting vendor FCM token: $e');
      return null;
    }
  }

  static Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }
}
