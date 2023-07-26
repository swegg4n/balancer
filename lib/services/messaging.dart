import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Balancer/services/permission_manager.dart';

class MessagingService {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future initialize() async {
    debugPrint('FCM token: ' + await _getToken());
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await PermissionManager.requestPermission(Permission.notification);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   // await Firebase.initializeApp();
  //   debugPrint('Handling a background message ${message.messageId}');
  // }

  Future<String> _getToken() async {
    return await FirebaseMessaging.instance.getToken() ?? 'error-no-token';
  }
}
