import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _androidChannelId = 'elezaby_default_channel';
  static const String _androidChannelName = 'General notifications';
  static const String _androidChannelDescription =
      'Order and prescription updates';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _cachedToken;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
      ),
    );
    await androidImpl?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    _messaging.onTokenRefresh.listen((token) async {
      _cachedToken = token;
      final uid = _currentUid;
      if (uid != null) await _saveToken(uid, token);
    });
  }

  String? _currentUidOverride;
  String? get _currentUid => _currentUidOverride;

  Future<void> registerTokenForUser(String uid) async {
    _currentUidOverride = uid;
    final token = _cachedToken ?? await _messaging.getToken();
    if (token == null) return;
    _cachedToken = token;
    await _saveToken(uid, token);
  }

  Future<void> unregisterTokenForUser(String uid) async {
    final token = _cachedToken ?? await _messaging.getToken();
    _currentUidOverride = null;
    if (token == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete()
        .catchError((_) {});
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    debugPrint(
      'FCM foreground: ${notification.title} - ${notification.body}',
    );
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['orderId'] as String?,
    );
  }

  Future<void> _saveToken(String uid, String token) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
