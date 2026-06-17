const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {
  buildPropertyApprovalNotification,
  NOTIFY_STATUSES,
} = require('../notifications/approvalMessages');
const {notifyUser} = require('../notifications/notifyUser');

module.exports = onDocumentUpdated(
  {
    document: 'properties/{propertyId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const propertyId = event.params.propertyId;
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

    const landlordId = (after.landlordId || '').toString().trim();
    if (!landlordId) {
      logger.warn('onPropertyApprovalStatusUpdated: missing landlordId', {
        propertyId,
      });
      return;
    }

    const payload = buildPropertyApprovalNotification(after, propertyId);
    if (!payload) {
      return;
    }

    const notificationId = await notifyUser({
      receiverId: landlordId,
      title: payload.title,
      content: payload.content,
      type: 'property',
      relatedType: 'property',
      relatedId: propertyId,
      pushData: payload.pushData,
    });

    if (notificationId) {
      logger.info('onPropertyApprovalStatusUpdated: notification sent', {
        propertyId,
        landlordId,
        status: afterStatus,
        notificationId,
      });
    }
  },
);
