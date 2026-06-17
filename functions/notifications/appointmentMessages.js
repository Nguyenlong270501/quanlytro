const NOTIFY_STATUSES = new Set([
  'accepted',
  'rejected',
  'cancelled',
  'rescheduled',
  'success',
]);

const LANDLORD_NOTIFY_STATUSES = new Set(['rejected', 'cancelled', 'accepted']);

/**
 * @param {Record<string, unknown>} data
 * @param {'landlord' | 'tenant'} side
 * @returns {string}
 */
function pickCancelReason(data, side) {
  const by = (data.cancelledBy || '').toString().trim();
  const legacy = (data.cancelReason || '').toString().trim();
  const landlord = (data.landlordCancelReason || '').toString().trim();
  const tenant = (data.tenantCancelReason || '').toString().trim();

  if (by === 'landlord') return landlord || legacy;
  if (by === 'tenant') return tenant || legacy;

  if (side === 'landlord') {
    return landlord || legacy;
  }
  return tenant || legacy;
}

/**
 * @param {FirebaseFirestore.Timestamp | Date | string | undefined} value
 * @returns {Date | null}
 */
function toDate(value) {
  if (!value) {
    return null;
  }
  if (typeof value.toDate === 'function') {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

/**
 * @param {FirebaseFirestore.Timestamp | Date | string | undefined} value
 * @returns {string}
 */
function formatAppointmentDateTime(value) {
  const date = toDate(value);
  if (!date) {
    return '';
  }
  return date.toLocaleString('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
}

/**
 * Thông báo cho tenant khi trạng thái lịch hẹn đổi (chủ trọ xử lý).
 *
 * @param {Record<string, unknown>} data
 * @param {string} appointmentId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildAppointmentNotification(data, appointmentId) {
  const status = (data.status || '').toString().trim();
  if (!NOTIFY_STATUSES.has(status)) {
    return null;
  }

  const by = (data.cancelledBy || '').toString().trim();
  if (by === 'tenant' && (status === 'cancelled' || status === 'rejected')) {
    return null;
  }

  const acceptedBy = (data.acceptedBy || '').toString().trim();
  if (acceptedBy === 'tenant' && status === 'accepted') {
    return null;
  }

  const propertyTitle = (data.propertyTitle || 'Bài đăng').toString().trim();
  const propertyId = (data.propertyId || '').toString().trim();
  const dateLabel = formatAppointmentDateTime(data.appointmentDate);
  const landlordReason = pickCancelReason(data, 'landlord');

  let title = 'Cập nhật lịch hẹn';
  let content = propertyTitle;

  switch (status) {
  case 'accepted':
    title = 'Đã xác nhận lịch hẹn';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  case 'rejected':
    title = 'Lịch hẹn bị từ chối';
    content = landlordReason ?
      `${propertyTitle}. Lý do: ${landlordReason}` :
      propertyTitle;
    break;
  case 'cancelled':
    title = 'Lịch hẹn đã hủy';
    content = landlordReason ?
      `${propertyTitle}. Lý do: ${landlordReason}` :
      propertyTitle;
    break;
  case 'rescheduled':
    title = 'Lịch đã được đổi';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  case 'success':
    title = 'Lịch hẹn hoàn thành';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  default:
    break;
  }

  return {
    title,
    content,
    pushData: {
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId.toString(),
      appointmentId: appointmentId.toString(),
      status,
      propertyId,
      audience: 'tenant',
    },
  };
}

/**
 * Thông báo cho chủ trọ khi người thuê từ chối / hủy (có tenantCancelReason).
 *
 * @param {Record<string, unknown>} data
 * @param {string} appointmentId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildLandlordTenantActionNotification(data, appointmentId) {
  const status = (data.status || '').toString().trim();
  if (!LANDLORD_NOTIFY_STATUSES.has(status)) {
    return null;
  }

  const by = (data.cancelledBy || '').toString().trim();
  const acceptedBy = (data.acceptedBy || '').toString().trim();

  if (status === 'accepted') {
    if (acceptedBy !== 'tenant') {
      return null;
    }
  } else {
    if (by === 'landlord') {
      return null;
    }
  }

  const tenantReason = pickCancelReason(data, 'tenant');
  const rawTenant = (data.tenantCancelReason || '').toString().trim();
  if (status !== 'accepted' && !by && !rawTenant && !tenantReason) {
    return null;
  }

  const propertyTitle = (data.propertyTitle || 'Bài đăng').toString().trim();
  const propertyId = (data.propertyId || '').toString().trim();
  const tenantName = (data.tenantName || 'Người thuê').toString().trim();

  let title = 'Cập nhật lịch hẹn';
  let content = propertyTitle;

  if (status === 'accepted') {
    title = 'Người thuê đồng ý lịch hẹn';
    content = `${tenantName} — ${propertyTitle}`;
  } else if (status === 'rejected') {
    title = 'Người thuê từ chối lịch hẹn';
    content = tenantReason ?
      `${tenantName} — ${propertyTitle}. Lý do: ${tenantReason}` :
      `${tenantName} — ${propertyTitle}`;
  } else if (status === 'cancelled') {
    title = 'Người thuê đã hủy lịch hẹn';
    content = tenantReason ?
      `${tenantName} — ${propertyTitle}. Lý do: ${tenantReason}` :
      `${tenantName} — ${propertyTitle}`;
  }

  return {
    title,
    content,
    pushData: {
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId.toString(),
      appointmentId: appointmentId.toString(),
      status,
      propertyId,
      audience: 'landlord',
    },
  };
}

/**
 * Thông báo cho chủ trọ khi người thuê vừa tạo lịch hẹn (status pending).
 *
 * @param {Record<string, unknown>} data
 * @param {string} appointmentId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildLandlordNewAppointmentNotification(data, appointmentId) {
  const status = (data.status || '').toString().trim();
  if (status !== 'pending') {
    return null;
  }

  const propertyTitle = (data.propertyTitle || 'Bài đăng').toString().trim();
  const propertyId = (data.propertyId || '').toString().trim();
  const tenantName = (data.tenantName || 'Người thuê').toString().trim();
  const purpose = (data.purpose || '').toString().trim();
  const dateLabel = formatAppointmentDateTime(data.appointmentDate);

  let content = tenantName;
  if (propertyTitle) {
    content += ` — ${propertyTitle}`;
  }
  if (dateLabel) {
    content += ` (${dateLabel})`;
  }
  if (purpose) {
    content += `. Mục đích: ${purpose}`;
  }

  return {
    title: 'Lịch hẹn xem phòng mới',
    content,
    pushData: {
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId.toString(),
      audience: 'landlord',
      appointmentId: appointmentId.toString(),
      status,
      propertyId,
    },
  };
}

module.exports = {
  buildAppointmentNotification,
  buildLandlordNewAppointmentNotification,
  buildLandlordTenantActionNotification,
  pickCancelReason,
  NOTIFY_STATUSES,
};
