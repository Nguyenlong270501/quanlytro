import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../services/fcm_service.dart';

mixin NotificationPermissionLifecycleMixin<T extends StatefulWidget>
    on State<T> {
  bool _isSyncingFcmToken = false;
  bool _shouldRecheckNotificationOnResume = false;

  AppLifecycleListener? _fcmLifecycleListener;

  @override
  void initState() {
    super.initState();

    _fcmLifecycleListener = AppLifecycleListener(
      onResume: () {
        if (!_shouldRecheckNotificationOnResume) return;

        _shouldRecheckNotificationOnResume = false;
        recheckNotificationPermissionAndSyncToken();
      },
    );
  }

  @override
  void dispose() {
    _fcmLifecycleListener?.dispose();
    _fcmLifecycleListener = null;
    super.dispose();
  }

  void markShouldRecheckNotificationOnResume() {
    _shouldRecheckNotificationOnResume = true;
  }

  Future<void> recheckNotificationPermissionAndSyncToken() async {
    if (_isSyncingFcmToken) return;

    _isSyncingFcmToken = true;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.trim().isEmpty) return;

      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      final isAllowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAllowed) return;

      await Future.delayed(const Duration(milliseconds: 500));

      await FCMService().syncTokenForUser(uid);

      log('✅ Notification permission rechecked and token synced.');
    } catch (e, stackTrace) {
      log(
        '❌ Failed to recheck notification permission',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isSyncingFcmToken = false;
    }
  }
}