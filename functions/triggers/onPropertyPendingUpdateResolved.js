const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {
  buildPropertyPendingUpdateNotification,
} = require('../notifications/approvalMessages');
const {notifyUser} = require('../notifications/notifyUser');

/**
 * Gửi thông báo khi admin duyệt / từ chối chỉnh sửa bài (pendingUpdate).
 * Khác với onPropertyApprovalStatusUpdated: luồng này không đổi status.
 */
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

    const hadPending = before.hasPendingUpdate === true;
    const hasPendingAfter = after.hasPendingUpdate === true;
    if (!hadPending || hasPendingAfter) {
      return;
    }

    const beforeStatus = (before.status || '').toString().trim();
    const afterStatus = (after.status || '').toString().trim();
    if (beforeStatus !== afterStatus) {
      // Duyệt/từ chối bài mới — để trigger onPropertyApprovalStatusUpdated xử lý
      return;
    }

    const pendingBefore = before.pendingUpdate;
    if (
      pendingBefore == null ||
      (typeof pendingBefore === 'object' &&
        Object.keys(pendingBefore).length === 0)
    ) {
      return;
    }

    const landlordId = (after.landlordId || '').toString().trim();
    if (!landlordId) {
      logger.warn('onPropertyPendingUpdateResolved: missing landlordId', {
        propertyId,
      });
      return;
    }

    const beforeReason = (before.lastPendingRejectReason || '')
      .toString()
      .trim();
    const afterReason = (after.lastPendingRejectReason || '')
      .toString()
      .trim();
    // Reject luôn ghi lastPendingRejectReason mới; approve không đụng field này.
    // Edge: từ chối lần 2 với đúng cùng chuỗi lý do đã lưu → có thể nhận nhầm "duyệt"
    // (hiếm). Có thể xóa lastPendingRejectReason khi landlord gửi pending mới (Dart).
    const rejectReasonUpdated =
      afterReason.length > 0 && afterReason !== beforeReason;
    const outcome = rejectReasonUpdated ? 'update_rejected' : 'update_approved';

    const payload = buildPropertyPendingUpdateNotification(
      after,
      propertyId,
      outcome,
      rejectReasonUpdated ? afterReason : '',
    );
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
      logger.info('onPropertyPendingUpdateResolved: notification sent', {
        propertyId,
        landlordId,
        outcome,
        notificationId,
      });
    }
  },
);
