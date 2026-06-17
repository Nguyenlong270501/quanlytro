const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {
  buildLandlordRequestNotification,
  NOTIFY_STATUSES,
} = require('../notifications/approvalMessages');
const {notifyUser} = require('../notifications/notifyUser');

module.exports = onDocumentUpdated(
  {
    document: 'landlord_requests/{userId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const userId = event.params.userId;
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap?.exists || !afterSnap?.exists) {
      return;
    }

    const before = beforeSnap.data() || {};
    const after = afterSnap.data() || {};
    const beforeStatus = (before.status || '').toString().trim();
    const afterStatus = (after.status || '').toString().trim();

    if (beforeStatus === afterStatus) {
      return;
    }
    if (!NOTIFY_STATUSES.has(afterStatus)) {
      return;
    }

    const receiverId = (userId || '').toString().trim();
    if (!receiverId) {
      logger.warn('onLandlordRequestUpdated: missing userId');
      return;
    }

    const payload = buildLandlordRequestNotification(after, receiverId);
    if (!payload) {
      return;
    }

    const notificationId = await notifyUser({
      receiverId,
      title: payload.title,
      content: payload.content,
      type: 'landlord_request',
      relatedType: 'landlord_request',
      relatedId: receiverId,
      pushData: payload.pushData,
    });

    if (notificationId) {
      logger.info('onLandlordRequestUpdated: notification sent', {
        userId: receiverId,
        status: afterStatus,
        notificationId,
      });
    }
  },
);
