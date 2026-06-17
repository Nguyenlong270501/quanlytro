const admin = require('firebase-admin');
const logger = require('firebase-functions/logger');
const {sendPushNotificationToUser} = require('../fcm/sendPushNotificationToUser');

const MAX_TITLE_LENGTH = 100;
const MAX_CONTENT_LENGTH = 300;

const PUSH_DATA_KEYS = new Set([
  'type',
  'relatedType',
  'relatedId',
  'appointmentId',
  'propertyId',
  'status',
  'audience',
]);

/**
 * @param {Record<string, unknown>} obj
 * @returns {Record<string, string>}
 */
function stringifyPushData(obj) {
  const result = {};
  if (!obj || typeof obj !== 'object') {
    return result;
  }
  for (const [key, value] of Object.entries(obj)) {
    if (value === undefined || value === null) {
      continue;
    }
    result[key] = String(value);
  }
  return result;
}

/**
 * @param {string} title
 * @param {string} content
 * @returns {{ title: string, content: string } | null}
 */
function normalizeTitleContent(title, content) {
  let normalizedTitle = (title || '').toString().trim();
  let normalizedContent = (content || '').toString().trim();

  if (!normalizedTitle || !normalizedContent) {
    logger.warn('notifyUser: empty title or content after trim');
    return null;
  }

  if (normalizedTitle.length > MAX_TITLE_LENGTH) {
    logger.warn('notifyUser: title truncated', {
      originalLength: normalizedTitle.length,
      max: MAX_TITLE_LENGTH,
    });
    normalizedTitle = normalizedTitle.slice(0, MAX_TITLE_LENGTH);
  }

  if (normalizedContent.length > MAX_CONTENT_LENGTH) {
    logger.warn('notifyUser: content truncated', {
      originalLength: normalizedContent.length,
      max: MAX_CONTENT_LENGTH,
    });
    normalizedContent = normalizedContent.slice(0, MAX_CONTENT_LENGTH);
  }

  return {title: normalizedTitle, content: normalizedContent};
}

/**
 * @param {{
 *   receiverId: string,
 *   title: string,
 *   content: string,
 *   type: string,
 *   relatedType: string,
 *   relatedId: string,
 *   pushData?: Record<string, string>,
 * }} params
 * Firestore field `content` → FCM `notification.body`.
 * @returns {Promise<string | null>} notificationId
 */
async function notifyUser({
  receiverId,
  title,
  content,
  type,
  relatedType,
  relatedId,
  pushData = {},
}) {
  const trimmedReceiverId = (receiverId || '').toString().trim();
  if (!trimmedReceiverId) {
    logger.warn('notifyUser: missing receiverId');
    return null;
  }

  const normalized = normalizeTitleContent(title, content);
  if (!normalized) {
    return null;
  }

  const stringPushData = stringifyPushData(pushData);
  const expiresAt = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 1000 * 60 * 60 * 24 * 30),
  );
  const docData = {
    receiverId: trimmedReceiverId,
    title: normalized.title,
    content: normalized.content,
    type: (type || '').toString().trim(),
    relatedType: (relatedType || '').toString().trim(),
    relatedId: (relatedId || '').toString().trim(),
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  };

  for (const key of PUSH_DATA_KEYS) {
    if (stringPushData[key] !== undefined) {
      docData[key] = stringPushData[key];
    }
  }

  const docRef = await admin.firestore().collection('notifications').add(docData);
  const notificationId = docRef.id;

  const fcmData = {
    notificationId,
    ...stringPushData,
  };

  try {
    await sendPushNotificationToUser(trimmedReceiverId, {
      notification: {
        title: normalized.title,
        body: normalized.content,
      },
      data: fcmData,
    });
  } catch (error) {
    logger.error('notifyUser: push failed', {
      receiverId: trimmedReceiverId,
      notificationId,
      error: error instanceof Error ? error.message : String(error),
    });
  }

  return notificationId;
}

module.exports = {notifyUser, stringifyPushData, normalizeTitleContent};
