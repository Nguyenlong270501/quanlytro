import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  log("📬 [Background] Nhận tin nhắn: ${message.messageId}");
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _isLoggingOut = false;

  static const String _channelId = 'quan_ly_tro_notification_channel';
  static const String _channelName = 'Thông báo Quản lý trọ';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description:
            'Kênh nhận thông báo về lịch hẹn, bài đăng và hệ thống Quản lý trọ',
        importance: Importance.max,
        playSound: true,
      );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        log('👉 User CLICK (Foreground): ${details.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );


    _fcm.onTokenRefresh.listen((newToken) async {
      if (_isLoggingOut) {
        return;
      }
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return;
      }
      if (!await _hasNotificationPermission()) {
        return;
      }

      await syncTokenForUser(user.uid);
      log('FCM token refreshed and synced.');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📬 [Foreground] Incoming...');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('👉 User CLICK (Background): ${message.data}');
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log('👉 User CLICK (Terminated): ${initialMessage.data}');
    }
  }

  Future<void> requestNotificationPermission({String? uid}) async {
    final targetUid = uid ?? _firebaseAuth.currentUser?.uid;
    if (targetUid == null || targetUid.trim().isEmpty) {
      return;
    }

    try {
      final status = await _requestNotificationAuthorization();
      log('=== TRẠNG THÁI QUYỀN THÔNG BÁO HIỆN TẠI: $status ===');

      if (_isAuthorized(status)) {
        await syncTokenForUser(targetUid);
        return;
      }

      log('Skip FCM sync: notification permission denied');
    } catch (e, stackTrace) {
      log(
        '⚠️ requestNotificationPermission failed, ignored',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AuthorizationStatus> _requestNotificationAuthorization() async {
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.notification.request();
      if (permissionStatus.isGranted || permissionStatus.isLimited) {
        return AuthorizationStatus.authorized;
      }
      return AuthorizationStatus.denied;
    }

    final current = await _fcm.getNotificationSettings();
    if (_isAuthorized(current.authorizationStatus)) {
      return current.authorizationStatus;
    }

    if (current.authorizationStatus != AuthorizationStatus.notDetermined) {
      return current.authorizationStatus;
    }

    final result = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return result.authorizationStatus;
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  /// Xóa `fcmTokens` trên Firestore — gọi **trước** `signOut()` (còn đăng nhập).
  Future<void> clearUserFcmTokensOnFirestore(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    _isLoggingOut = true;
    try {
      await _firestore.collection('users').doc(normalizedUserId).set(
        {'fcmTokens': <String>[]},
        SetOptions(merge: true),
      );
      log('✅ Cleared all FCM tokens for user $normalizedUserId');
    } catch (e, stackTrace) {
      _isLoggingOut = false;
      log(
        '❌ clearUserFcmTokensOnFirestore failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Xóa token FCM trên thiết bị — gọi **sau** `signOut()` để tránh `onTokenRefresh` ghi lại.
  Future<void> deleteLocalMessagingToken() async {
    try {
      await _fcm.deleteToken();
      log('✅ Local FCM token deleted');
    } catch (e) {
      log('⚠️ deleteToken failed, ignored: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  /// ĐỒNG BỘ TOKEN CHỦ ĐỘNG: Đảm bảo an toàn, gọi sau khi đã kéo xong Data sạch từ Firestore về máy.
  Future<bool> _hasNotificationPermission() async {
    try {
      final settings = await _fcm.getNotificationSettings();
      return _isAuthorized(settings.authorizationStatus);
    } catch (e) {
      log('⚠️ getNotificationSettings failed: $e');
      return false;
    }
  }

  Future<void> syncTokenForUser(String uid) async {
    if (_isLoggingOut) {
      return;
    }

    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return;
    }

    if (!await _hasNotificationPermission()) {
      log('Skip FCM sync: notifications disabled or denied');
      return;
    }

    try {
      final token = await _fcm.getToken();

      if (token == null || token.trim().isEmpty) {
        log('❌ FCM token is null or empty');
        return;
      }

      final normalizedToken = token.trim();

      await _firestore.collection('users').doc(normalizedUid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([normalizedToken]),
        },
        SetOptions(merge: true),
      );

      log('✅ FCM token synced thành công cho user $normalizedUid');
    } catch (e) {
      log('❌ Lỗi chạy syncTokenForUser: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: _androidChannel.importance,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final String? payloadData = message.data.isNotEmpty
        ? message.data.toString()
        : null;

    await _localNotifications.show(
      id: notificationId,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payloadData,
    );
  }
}
