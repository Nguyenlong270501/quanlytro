const {sendPushNotificationToUser, ANDROID_CHANNEL_ID} =
  require('./sendPushNotificationToUser');

/** @deprecated Use sendPushNotificationToUser */
const sendToUser = sendPushNotificationToUser;

module.exports = {sendToUser, sendPushNotificationToUser, ANDROID_CHANNEL_ID};
