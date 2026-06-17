const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const logger = require('firebase-functions/logger');

// Hardcoded for internal/test — use defineSecret / params in production.
const DEFAULT_PASSWORD = 'Media@123';

module.exports = onCall(
  {region: 'asia-southeast1'},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'Bạn cần đăng nhập để thực hiện thao tác này.',
      );
    }

    const callerUid = request.auth.uid;
    const callerSnap = await admin.firestore()
      .collection('users')
      .doc(callerUid)
      .get();

    if (!callerSnap.exists) {
      throw new HttpsError('permission-denied', 'Không tìm thấy hồ sơ người gọi.');
    }

    const callerRole = (callerSnap.data()?.role || '').toString().trim();
    if (callerRole !== 'admin') {
      throw new HttpsError(
        'permission-denied',
        'Chỉ quản trị viên mới được reset mật khẩu.',
      );
    }

    const email = (request.data?.email || '').toString().trim();
    const uid = (request.data?.uid || '').toString().trim();

    if (!email && !uid) {
      throw new HttpsError(
        'invalid-argument',
        'Cần cung cấp email hoặc uid.',
      );
    }

    let targetUser;
    try {
      targetUser = email ?
        await admin.auth().getUserByEmail(email) :
        await admin.auth().getUser(uid);
    } catch (error) {
      logger.warn('resetUserPasswordToDefault: user lookup failed', {
        email: email || undefined,
        uid: uid || undefined,
        error: error instanceof Error ? error.message : String(error),
      });
      throw new HttpsError('not-found', 'Không tìm thấy tài khoản.');
    }

    await admin.auth().updateUser(targetUser.uid, {
      password: DEFAULT_PASSWORD,
    });

    logger.info('resetUserPasswordToDefault: password updated', {
      adminId: callerUid,
      targetUid: targetUser.uid,
    });

    return {
      success: true,
      uid: targetUser.uid,
    };
  },
);
