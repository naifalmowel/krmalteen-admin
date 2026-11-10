import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (!kIsWeb) {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _localNotificationsPlugin.initialize(initSettings);
    }

    // Request FCM / Browser notification permissions
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showLocalNotification(
            title: message.notification!.title ?? 'حجز جديد',
            body: message.notification!.body ?? 'وصل حجز جديد للمطعم',
          );
        }
      });
    } catch (_) {
      // FCM fallback or web fallback
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!kIsWeb) {
        const androidDetails = AndroidNotificationDetails(
          'krmalteen_bookings_channel',
          'الحجوزات الجديدة',
          channelDescription: 'إشعارات عند وصول حجوزات جديدة للمطعم',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

        const darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _localNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title,
          body,
          notificationDetails,
        );
      }
    } catch (_) {
      // Fallback
    }
  }
}
