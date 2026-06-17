const NOTIFY_STATUSES = new Set(['approved', 'rejected']);

/**
 * @param {Record<string, unknown>} data
 * @param {string} userId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildLandlordRequestNotification(data, userId) {
  const status = (data.status || '').toString().trim();
  if (!NOTIFY_STATUSES.has(status)) {
    return null;
  }

  let title = 'Cập nhật hồ sơ chủ trọ';
  let content = 'Trạng thái hồ sơ của bạn đã được cập nhật.';

  if (status === 'approved') {
    title = 'Hồ sơ chủ trọ đã được duyệt';
    content = 'Chúc mừng! Bạn đã được cấp quyền đăng bài trọ.';
  } else if (status === 'rejected') {
    title = 'Hồ sơ chủ trọ bị từ chối';
    const rejectionReason = (data.rejectionReason || '').toString().trim();
    content = rejectionReason ?
      `Lý do: ${rejectionReason}` :
      'Hồ sơ của bạn chưa đạt yêu cầu. Vui lòng kiểm tra và gửi lại.';
  }

  return {
    title,
    content,
    pushData: {
      type: 'landlord_request',
      relatedType: 'landlord_request',
      relatedId: userId.toString(),
      status,
      audience: 'landlord',
    },
  };
}

/**
 * @param {Record<string, unknown>} data
 * @param {string} propertyId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildPropertyApprovalNotification(data, propertyId) {
  const status = (data.status || '').toString().trim();
  if (!NOTIFY_STATUSES.has(status)) {
    return null;
  }

  const propertyTitle = (data.title || 'Bài đăng').toString().trim();

  let title = 'Cập nhật bài đăng';
  let content = propertyTitle;

  if (status === 'approved') {
    title = 'Bài đăng đã được duyệt';
    content = propertyTitle;
  } else if (status === 'rejected') {
    title = 'Bài đăng bị từ chối';
    const rejectedReason = (data.rejectedReason || '').toString().trim();
    content = rejectedReason ?
      `${propertyTitle}. Lý do: ${rejectedReason}` :
      `${propertyTitle} chưa được duyệt. Vui lòng chỉnh sửa và gửi lại.`;
  }

  return {
    title,
    content,
    pushData: {
      type: 'property',
      relatedType: 'property',
      relatedId: propertyId.toString(),
      propertyId: propertyId.toString(),
      status,
      audience: 'landlord',
    },
  };
}

/**
 * Admin đã xử lý xong pendingUpdate (duyệt / từ chối chỉnh sửa).
 * @param {Record<string, unknown>} after
 * @param {string} propertyId
 * @param {'update_approved' | 'update_rejected'} outcome
 * @param {string} [rejectReason] — chỉ dùng khi outcome === update_rejected
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildPropertyPendingUpdateNotification(
  after,
  propertyId,
  outcome,
  rejectReason,
) {
  const propertyTitle = (after.title || 'Bài đăng').toString().trim();
  const reason = (rejectReason || '').toString().trim();

  let title = 'Cập nhật bài đăng';
  let content = propertyTitle;
  let status = 'update_approved';

  if (outcome === 'update_rejected') {
    title = 'Chỉnh sửa bài đăng bị từ chối';
    content = reason ?
      `${propertyTitle}. Lý do: ${reason}` :
      `${propertyTitle}. Chỉnh sửa chưa được duyệt.`;
    status = 'update_rejected';
  } else {
    title = 'Chỉnh sửa bài đăng đã được duyệt';
    content = propertyTitle;
    status = 'update_approved';
  }

  return {
    title,
    content,
    pushData: {
      type: 'property',
      relatedType: 'property',
      relatedId: propertyId.toString(),
      propertyId: propertyId.toString(),
      status,
      audience: 'landlord',
    },
  };
}

module.exports = {
  buildLandlordRequestNotification,
  buildPropertyApprovalNotification,
  buildPropertyPendingUpdateNotification,
  NOTIFY_STATUSES,
};
