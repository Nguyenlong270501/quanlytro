const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {
  buildAppointmentNotification,
  buildLandlordTenantActionNotification,
  NOTIFY_STATUSES,
} = require('../notifications/appointmentMessages');
const {notifyUser} = require('../notifications/notifyUser');

module.exports = onDocumentUpdated(
  {
    document: 'appointments/{appointmentId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const appointmentId = event.params.appointmentId;
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
    if (afterStatus === 'pending' || !NOTIFY_STATUSES.has(afterStatus)) {
      return;
    }

    const tenantId = (after.tenantId || '').toString().trim();
    const landlordId = (after.landlordId || '').toString().trim();

    if (tenantId) {
      const tenantPayload = buildAppointmentNotification(after, appointmentId);
      if (tenantPayload) {
        const notificationId = await notifyUser({
          receiverId: tenantId,
          title: tenantPayload.title,
          content: tenantPayload.content,
          type: 'appointment',
          relatedType: 'appointment',
          relatedId: appointmentId,
          pushData: tenantPayload.pushData,
        });

        if (notificationId) {
          logger.info('onAppointmentUpdated: tenant notified', {
            appointmentId,
            tenantId,
            status: afterStatus,
            notificationId,
          });
        }
      }
    } else {
      logger.warn('onAppointmentUpdated: missing tenantId', {appointmentId});
    }

    if (landlordId && landlordId !== tenantId) {
      const landlordPayload = buildLandlordTenantActionNotification(
        after,
        appointmentId,
      );
      if (landlordPayload) {
        const landlordNotificationId = await notifyUser({
          receiverId: landlordId,
          title: landlordPayload.title,
          content: landlordPayload.content,
          type: 'appointment',
          relatedType: 'appointment',
          relatedId: appointmentId,
          pushData: landlordPayload.pushData,
        });

        if (landlordNotificationId) {
          logger.info('onAppointmentUpdated: landlord notified (tenant action)', {
            appointmentId,
            landlordId,
            status: afterStatus,
            notificationId: landlordNotificationId,
          });
        }
      }
    }
  },
);
