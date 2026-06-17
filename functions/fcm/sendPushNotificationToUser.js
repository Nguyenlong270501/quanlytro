const admin = require('firebase-admin');
const logger = require('firebase-functions/logger');

const ANDROID_CHANNEL_ID = 'quan_ly_tro_notification_channel';

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/**
 * Gửi FCM multicast tới user. Push chỉ là realtime signal.
 *
 * @param {string} userId
 * @param {{ notification: { title: string, body: string }, data?: Record<string, string> }} payload
 * Firestore `content` → FCM `notification.body` (map tại notifyUser).
 */
async function sendPushNotificationToUser(userId, payload) {
  const trimmedUserId = (userId || '').trim();
  if (!trimmedUserId) {
    return;
  }

  const userRef = admin.firestore().collection('users').doc(trimmedUserId);
  const userSnap = await userRef.get();
  if (!userSnap.exists) {
    logger.warn('sendPushNotificationToUser: user not found', {userId: trimmedUserId});
    return;
  }

  const rawTokens = userSnap.data()?.fcmTokens;
  if (!Array.isArray(rawTokens) || rawTokens.length === 0) {
    logger.info('sendPushNotificationToUser: no fcmTokens', {userId: trimmedUserId});
    return;
  }

  const tokens = [...new Set(
    rawTokens
      .map((t) => (t || '').toString().trim())
      .filter((t) => t.length > 0),
  )];
  if (tokens.length === 0) {
    return;
  }

  const message = {
    tokens,
    notification: payload.notification,
    data: payload.data || {},
    android: {
      notification: {
        channelId: ANDROID_CHANNEL_ID,
      },
    },
  };

  const response = await admin.messaging().sendEachForMulticast(message);
  logger.info('sendPushNotificationToUser: multicast sent', {
    userId: trimmedUserId,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  if (response.failureCount > 0) {
    logger.warn('sendPushNotificationToUser: partial failures', {
      userId: trimmedUserId,
      failureCount: response.failureCount,
    });
  }

  const tokensToRemove = [];
  response.responses.forEach((res, index) => {
    if (res.success) {
      return;
    }
    const code = res.error?.code || '';
    if (INVALID_TOKEN_CODES.has(code)) {
      tokensToRemove.push(tokens[index]);
    }
  });

  if (tokensToRemove.length > 0) {
    await userRef.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
    });
    logger.info('sendPushNotificationToUser: pruned invalid tokens', {
      userId: trimmedUserId,
      count: tokensToRemove.length,
    });
  }
}

module.exports = {sendPushNotificationToUser, ANDROID_CHANNEL_ID};
