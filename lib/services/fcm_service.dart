import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription? _notificationSub;

  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'Emergency Alert';
      final body =
          message.notification?.body ?? 'You have a new emergency update.';

      showLocalNotification(title: title, body: body);
    });

    _messaging.onTokenRefresh.listen((token) async {
      await saveUserToken();
    });

    await saveUserToken();
    await startInAppNotificationListener();
  }

  static Future<void> saveUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> startInAppNotificationListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _notificationSub?.cancel();

    _notificationSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() ?? {};

              final title = (data['title'] ?? 'Emergency Alert').toString();

              final body =
                  (data['shortMessage'] ??
                          data['message'] ??
                          'You have a new emergency update.')
                      .toString();

              showLocalNotification(title: title, body: body);
            }
          }
        });
  }

  static Future<void> stopInAppNotificationListener() async {
    await _notificationSub?.cancel();
    _notificationSub = null;
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'emergency_alerts_channel',
      'Emergency Alerts',
      channelDescription: 'Emergency AI App urgent alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
