const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {buildLandlordNewAppointmentNotification} =
  require('../notifications/appointmentMessages');
const {notifyUser} = require('../notifications/notifyUser');

module.exports = onDocumentCreated(
  {
    document: 'appointments/{appointmentId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const appointmentId = event.params.appointmentId;
    const snap = event.data;
    if (!snap?.exists) {
      return;
    }

    const data = snap.data() || {};
    const landlordId = (data.landlordId || '').toString().trim();
    const tenantId = (data.tenantId || '').toString().trim();

    if (!landlordId) {
      logger.warn('onAppointmentCreated: missing landlordId', {appointmentId});
      return;
    }
    if (landlordId === tenantId) {
      logger.info('onAppointmentCreated: skip self-booking', {appointmentId});
      return;
    }

    const payload = buildLandlordNewAppointmentNotification(data, appointmentId);
    if (!payload) {
      return;
    }

    const notificationId = await notifyUser({
      receiverId: landlordId,
      title: payload.title,
      content: payload.content,
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId,
      pushData: payload.pushData,
    });

    if (notificationId) {
      logger.info('onAppointmentCreated: landlord notified', {
        appointmentId,
        landlordId,
        tenantId,
        notificationId,
      });
    }
  },
);
