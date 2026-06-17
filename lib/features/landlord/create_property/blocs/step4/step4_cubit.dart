import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/local_location_service.dart';
import '../../../../../core/services/upload_worker_service.dart';
import '../../../../auth/data/models/user.dart';
import '../../data/datasources/property_update_data_source_impl.dart';
import '../../data/models/landlord_summary_model.dart';
import '../../data/models/property_model.dart';
import '../../domain/property_edit_moderation_service.dart';
import '../step1/step1_state.dart';
import '../step2/step2_state.dart';
import '../step3/step3_state.dart';
import 'step4_state.dart';

class Step4Cubit extends Cubit<Step4State> {
  Step4Cubit() : super(const Step4State());

  String _wardCodeFromStep1(Step1State step1) {
    return LocalLocationService().resolveWardCodename(
      city: step1.city,
      raw: step1.ward,
    );
  }

  Future<void> submit({
    required UserModel currentUser,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: SubmitStatus.submitting));

    try {
      final now = DateTime.now();
      final propertyId = FirebaseFirestore.instance
          .collection('properties')
          .doc()
          .id;

      final property = PropertyModel(
        propertyId: propertyId,
        landlordId: currentUser.userId,
        quotaId: step1.selectedQuotaId ?? '',
        title: step1.name,
        description: step1.description,
        propertyTypes: step1.propertyTypes,
        minimumRentalDuration: int.tryParse(step1.minimumRentalDuration) ?? 0,
        city: step1.city ?? '',
        ward: _wardCodeFromStep1(step1),
        streetAddress: step1.street,
        location: step1.latitude != null && step1.longitude != null
            ? GeoPoint(step1.latitude!, step1.longitude!)
            : null,
        latitude: step1.latitude,
        longitude: step1.longitude,
        electricityPrice: int.tryParse(step1.electricityPrice) ?? 0,
        waterPrice: int.tryParse(step1.waterPrice) ?? 0,
        wifiPrice: int.tryParse(step1.wifiPrice ?? '') ?? 0,
        parkingFee: int.tryParse(step1.parkingFee ?? '') ?? 0,
        serviceFee: int.tryParse(step1.serviceFee ?? '') ?? 0,
        serviceDescription: step1.serviceDescription,
        facilities: step2.activeAmenities.toList(),
        rules: step2.activeRules.toList(),
        rulesDescription: step2.ruleNotes,
        curfewTime: step2.curfew,
        imageUrls: step2.imageUrls,
        createdAt: now,
        updatedAt: now,
        deletedAt: now.add(const Duration(days: 365)),
        rejectedReason: '',
        totalReviews: 0,
        ratingAverage: 0,
        totalRatingPoints: 0,
        ratingDistribution: const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
        landlordSummary: LandlordSummaryModel(
          userName: currentUser.userName,
          email: currentUser.email,
          createdAt: currentUser.createdAt,
          avatarUrl: currentUser.avatarUrl,
          phoneNumber: currentUser.phoneNumber,
        ),
      );

      final roomsData = <Map<String, dynamic>>[];
      for (final room in step3.rooms) {
        final roomId = FirebaseFirestore.instance
            .collection('properties')
            .doc(propertyId)
            .collection('rooms')
            .doc()
            .id;

        final updatedRoom = room.copyWith(
          roomId: roomId,
          propertyId: propertyId,
        );
        roomsData.add(updatedRoom.toMap());
      }

      await UploadWorkerService.saveDraftToQueue(
        propertyData: property.toMap(),
        roomsData: roomsData,
      );

      log('Đã save draft vào Hive queue, user có thể làm việc khác');

      emit(
        state.copyWith(status: SubmitStatus.success, errorMessage: () => null),
      );
    } on Exception catch (e) {
      log('Save draft failed: $e');
      emit(
        state.copyWith(
          status: SubmitStatus.failure,
          errorMessage: () => e.toString(),
        ),
      );
    }
  }



  Future<PropertyModel?> submitEdit({
    required PropertyModel baseline,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
  }) async {
    if (state.isSubmitting) return null;
    emit(state.copyWith(status: SubmitStatus.submitting));

    try {
      final now = DateTime.now();
      if (baseline.status == PropertyStatus.approved ||
          baseline.status == PropertyStatus.hidden) {
        return _submitModeratedEdit(
          baseline: baseline,
          step1: step1,
          step2: step2,
          step3: step3,
        );
      }

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final effectiveLandlordId = baseline.landlordId.trim().isNotEmpty
          ? baseline.landlordId.trim()
          : uid;
      if (uid.isEmpty || uid != effectiveLandlordId) {
        throw Exception('Không có quyền chỉnh sửa bài đăng này.');
      }

      final propId = baseline.propertyId;
      if (propId.isEmpty) {
        throw Exception('Thiếu mã nhà trọ.');
      }

      final roomsRef = FirebaseFirestore.instance
          .collection('properties')
          .doc(propId)
          .collection('rooms');

      final editedRooms = <RoomModel>[];
      final roomsData = <Map<String, dynamic>>[];
      for (final room in step3.rooms) {
        var effectiveRoomId = room.roomId;
        if (effectiveRoomId.isEmpty) {
          effectiveRoomId = roomsRef.doc().id;
        }
        final updatedRoom = room.copyWith(
          roomId: effectiveRoomId,
          propertyId: propId,
          updatedAt: now,
        );
        editedRooms.add(updatedRoom);
        roomsData.add(updatedRoom.toMap());
      }

      final editedStatus = baseline.status == PropertyStatus.rejected
          ? PropertyStatus.pending
          : baseline.status;
      final property = PropertyModel(
        propertyId: propId,
        landlordId: effectiveLandlordId,
        quotaId: baseline.quotaId,
        title: step1.name,
        description: step1.description,
        propertyTypes: step1.propertyTypes,
        minimumRentalDuration: int.tryParse(step1.minimumRentalDuration) ?? 0,
        city: step1.city ?? '',
        ward: _wardCodeFromStep1(step1),
        streetAddress: step1.street,
        location: step1.latitude != null && step1.longitude != null
            ? GeoPoint(step1.latitude!, step1.longitude!)
            : null,
        latitude: step1.latitude,
        longitude: step1.longitude,
        electricityPrice: int.tryParse(step1.electricityPrice) ?? 0,
        waterPrice: int.tryParse(step1.waterPrice) ?? 0,
        wifiPrice: int.tryParse(step1.wifiPrice ?? '') ?? 0,
        parkingFee: int.tryParse(step1.parkingFee ?? '') ?? 0,
        serviceFee: int.tryParse(step1.serviceFee ?? '') ?? 0,
        serviceDescription: step1.serviceDescription,
        facilities: step2.activeAmenities.toList(),
        rules: step2.activeRules.toList(),
        rulesDescription: step2.ruleNotes,
        curfewTime: step2.curfew,
        imageUrls: step2.imageUrls,
        status: editedStatus,
        rejectedReason: baseline.rejectedReason,
        ratingAverage: baseline.ratingAverage,
        totalReviews: baseline.totalReviews,
        totalRatingPoints: baseline.totalRatingPoints,
        ratingDistribution: baseline.ratingDistribution,
        landlordSummary: baseline.landlordSummary,
        rooms: editedRooms,
        createdAt: baseline.createdAt,
        updatedAt: now,
        deletedAt: now.add(const Duration(days: 365)),
      );

      final editedRoomIds = editedRooms
          .map((r) => r.roomId.trim())
          .where((id) => id.isNotEmpty)
          .toSet();

      final deletedRoomIds = <String>[
        for (final r in baseline.rooms ?? const <RoomModel>[])
          if (r.roomId.trim().isNotEmpty &&
              !editedRoomIds.contains(r.roomId.trim()))
            r.roomId.trim(),
      ];

      final previousRoomImages = <String, dynamic>{
        for (final r in baseline.rooms ?? const <RoomModel>[])
          if (r.roomId.isNotEmpty) r.roomId: List<String>.from(r.imageUrls),
      };

      final deletedRoomImages = <String, dynamic>{
        for (final r in baseline.rooms ?? const <RoomModel>[])
          if (deletedRoomIds.contains(r.roomId.trim()))
            r.roomId: List<String>.from(r.imageUrls),
      };

      final editSyncMeta = <String, dynamic>{
        'previousPropertyImageUrls': List<String>.from(
          baseline.imageUrls ?? const <String>[],
        ),
        'previousRoomImages': previousRoomImages,
        'deletedRoomIds': deletedRoomIds,
        'deletedRoomImages': deletedRoomImages,
      };

      await UploadWorkerService.saveDraftToQueue(
        propertyData: property.toMap(),
        roomsData: roomsData,
        editSyncMeta: editSyncMeta,
      );

      log('Đã save edit draft vào Hive queue');

      emit(
        state.copyWith(status: SubmitStatus.success, errorMessage: () => null),
      );
      return property;
    } on Exception catch (e) {
      log('submitEdit save queue failed: $e');
      emit(
        state.copyWith(
          status: SubmitStatus.failure,
          errorMessage: () => e.toString(),
        ),
      );
      return null;
    }
  }

  Future<PropertyModel?> _submitModeratedEdit({
    required PropertyModel baseline,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('Vui lòng đăng nhập lại.');
    }

    final now = DateTime.now();
    final deletedAt = now.add(const Duration(days: 365));
    final updateDataSource = PropertyUpdateDataSourceImpl();
    final moderation = PropertyEditModerationService(
      updateDataSource: updateDataSource,
    );

    final diff = moderation.computeDiff(
      baseline: baseline,
      step1: step1,
      step2: step2,
      step3: step3,
      requestedBy: uid,
      wardCodeResolver: _wardCodeFromStep1,
    );

    await updateDataSource.patchPropertyFields(
      baseline.propertyId,
      {'deletedAt': deletedAt},
    );

    if (diff.isEmpty) {
      emit(
        state.copyWith(status: SubmitStatus.success, errorMessage: () => null),
      );
      return baseline.copyWith(deletedAt: deletedAt, updatedAt: now);
    }

    if (diff.hasAutoPass) {
      await moderation.applyAutoPass(
        propertyId: baseline.propertyId,
        diff: diff,
      );
    }

    if (diff.hasMustReview && diff.pendingUpdate != null) {
      if (diff.needsImageUpload) {
        await UploadWorkerService.saveModerationEditToQueue(
          propertyId: baseline.propertyId,
          autoPropertyPatch: const {},
          autoRoomChanges: const {},
          pendingUpdate: diff.pendingUpdate!,
          previousPending: baseline.pendingUpdate,
        );
      } else {
        await moderation.applyPendingUpdate(
          baseline: baseline,
          pendingUpdate: diff.pendingUpdate!,
        );
      }
    } else if (baseline.hasPendingUpdate) {
      await updateDataSource.clearPendingUpdate(baseline.propertyId);
    }

    final optimistic = moderation.optimisticAfterQueue(
      baseline: baseline,
      diff: diff,
    ).copyWith(deletedAt: deletedAt);

    emit(
      state.copyWith(status: SubmitStatus.success, errorMessage: () => null),
    );
    return optimistic;
  }

  void reset() => emit(const Step4State());
}
