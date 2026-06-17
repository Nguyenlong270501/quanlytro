/**
 * Cloud Functions — đồng bộ minRoomPrice / maxRoomPrice lên document property
 * khi chủ trọ tạo/sửa/xóa phòng: properties/{propertyId}/rooms/{roomId}
 */

const {setGlobalOptions} = require("firebase-functions");
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

setGlobalOptions({maxInstances: 10});

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const DEFAULT_RATING_DISTRIBUTION = {
  "1": 0,
  "2": 0,
  "3": 0,
  "4": 0,
  "5": 0,
};

function toValidRating(value) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return null;
  }
  const rating = Math.trunc(value);
  if (rating < 1 || rating > 5) {
    return null;
  }
  return rating;
}

function normalizeDistribution(value) {
  const result = {...DEFAULT_RATING_DISTRIBUTION};
  if (!value || typeof value !== "object") {
    return result;
  }
  for (const key of Object.keys(DEFAULT_RATING_DISTRIBUTION)) {
    const item = value[key];
    if (typeof item === "number" && Number.isFinite(item)) {
      result[key] = Math.max(0, Math.trunc(item));
    }
  }
  return result;
}

/**
 * Chỉ tính từ phòng isAvailable === true; giá lấy từ field price.
 * Nếu không còn phòng trống hợp lệ: xóa minRoomPrice / maxRoomPrice trên property.
 */
exports.syncPropertyRoomPriceBounds = onDocumentWritten(
  "properties/{propertyId}/rooms/{roomId}",
  async (event) => {
    const {propertyId} = event.params;

    try {
      const roomsSnap = await db
        .collection("properties")
        .doc(propertyId)
        .collection("rooms")
        .get();

      const prices = [];
      for (const doc of roomsSnap.docs) {
        const data = doc.data() || {};
        if (data.isAvailable !== true) {
          continue;
        }
        const raw = data.price;
        const n = typeof raw === "number" ? raw : Number(raw);
        if (Number.isFinite(n)) {
          prices.push(n);
        }
      }

      const propRef = db.collection("properties").doc(propertyId);

      if (prices.length === 0) {
        await propRef.update({
          minRoomPrice: FieldValue.delete(),
          maxRoomPrice: FieldValue.delete(),
        });
        logger.info("syncPropertyRoomPriceBounds: cleared", {propertyId});
        return;
      }

      const minRoomPrice = Math.min(...prices);
      const maxRoomPrice = Math.max(...prices);

      await propRef.update({
        minRoomPrice,
        maxRoomPrice,
      });

      logger.info("syncPropertyRoomPriceBounds: updated", {
        propertyId,
        minRoomPrice,
        maxRoomPrice,
        count: prices.length,
      });
    } catch (e) {
      logger.error("syncPropertyRoomPriceBounds failed", {
        propertyId,
        error: e instanceof Error ? e.message : String(e),
      });
      throw e;
    }
  },
);

exports.syncPropertyReviewAggregates = onDocumentWritten(
  "properties/{propertyId}/reviews/{userId}",
  async (event) => {
    const {propertyId, userId} = event.params;
    const beforeData = event.data?.before?.data() || null;
    const afterData = event.data?.after?.data() || null;
    const oldRating = toValidRating(beforeData?.rating);
    const newRating = toValidRating(afterData?.rating);

    if (!beforeData && !afterData) {
      return;
    }

    // Không đổi rating thì bỏ qua phần aggregate để tiết kiệm write.
    if (beforeData && afterData && oldRating === newRating) {
      logger.info("syncPropertyReviewAggregates: no rating delta", {
        propertyId,
        userId,
      });
      return;
    }

    const propertyRef = db.collection("properties").doc(propertyId);

    await db.runTransaction(async (tx) => {
      const propertySnap = await tx.get(propertyRef);
      if (!propertySnap.exists) {
        logger.warn("syncPropertyReviewAggregates: property not found", {
          propertyId,
          userId,
        });
        return;
      }

      const propertyData = propertySnap.data() || {};
      const distribution = normalizeDistribution(propertyData.ratingDistribution);
      let totalReviews = Number.isFinite(propertyData.totalReviews) ?
        Math.trunc(propertyData.totalReviews) : 0;
      let totalRatingPoints = Number.isFinite(propertyData.totalRatingPoints) ?
        Math.trunc(propertyData.totalRatingPoints) : 0;

      if (!beforeData && afterData && newRating != null) {
        totalReviews += 1;
        totalRatingPoints += newRating;
        distribution[String(newRating)] =
          (distribution[String(newRating)] || 0) + 1;
      } else if (beforeData && !afterData && oldRating != null) {
        totalReviews -= 1;
        totalRatingPoints -= oldRating;
        distribution[String(oldRating)] =
          (distribution[String(oldRating)] || 0) - 1;
      } else if (beforeData && afterData &&
        oldRating != null && newRating != null && oldRating !== newRating) {
        distribution[String(oldRating)] =
          (distribution[String(oldRating)] || 0) - 1;
        distribution[String(newRating)] =
          (distribution[String(newRating)] || 0) + 1;
        totalRatingPoints += (newRating - oldRating);
      }

      totalReviews = Math.max(0, totalReviews);
      totalRatingPoints = Math.max(0, totalRatingPoints);
      for (const key of Object.keys(DEFAULT_RATING_DISTRIBUTION)) {
        distribution[key] = Math.max(0, Math.trunc(distribution[key] || 0));
      }

      const ratingAverage = totalReviews > 0 ?
        totalRatingPoints / totalReviews : 0;

      tx.update(propertyRef, {
        totalReviews,
        totalRatingPoints,
        ratingAverage,
        ratingDistribution: distribution,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    logger.info("syncPropertyReviewAggregates: applied", {
      propertyId,
      userId,
      oldRating,
      newRating,
    });
  },
);

exports.onAppointmentCreated = require("./triggers/onAppointmentCreated");
exports.onAppointmentUpdated = require("./triggers/onAppointmentUpdated");
exports.onLandlordRequestUpdated =
  require("./triggers/onLandlordRequestUpdated");
exports.onPropertyApprovalStatusUpdated =
  require("./triggers/onPropertyApprovalStatusUpdated");
exports.onPropertyPendingUpdateResolved =
  require("./triggers/onPropertyPendingUpdateResolved");
exports.resetUserPasswordToDefault =
  require("./callables/resetUserPasswordToDefault");
