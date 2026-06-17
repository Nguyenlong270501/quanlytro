import '../../../../core/services/pending_storage_cleanup.dart';
import '../blocs/step1/step1_state.dart';
import '../blocs/step2/step2_state.dart';
import '../blocs/step3/step3_state.dart';
import '../data/datasources/property_update_data_source.dart';
import '../data/models/pending_property_update.dart';
import '../data/models/property_model.dart';
import 'property_edit_diff.dart';
import 'property_edit_diff_service.dart';

class PropertyEditModerationService {
  PropertyEditModerationService({
    PropertyEditDiffService? diffService,
    PropertyUpdateDataSource? updateDataSource,
  })  : _diffService = diffService ?? PropertyEditDiffService(),
        _updateDataSource = updateDataSource;

  final PropertyEditDiffService _diffService;
  final PropertyUpdateDataSource? _updateDataSource;

  PropertyEditDiff computeDiff({
    required PropertyModel baseline,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
    required String requestedBy,
    required String Function(Step1State step1) wardCodeResolver,
  }) {
    return _diffService.compare(
      baseline: baseline,
      step1: step1,
      step2: step2,
      step3: step3,
      requestedBy: requestedBy,
      wardCodeResolver: wardCodeResolver,
    );
  }

  Future<void> applyAutoPass({
    required String propertyId,
    required PropertyEditDiff diff,
  }) async {
    final dataSource = _requireDataSource();
    if (diff.autoPropertyPatch.isNotEmpty) {
      await dataSource.patchPropertyFields(propertyId, diff.autoPropertyPatch);
    }
    for (final entry in diff.autoRoomChanges.entries) {
      await dataSource.patchRoomFields(propertyId, entry.key, entry.value);
    }
    if (diff.autoRoomDeletes.isNotEmpty) {
      await dataSource.deleteRooms(
        propertyId: propertyId,
        roomIds: diff.autoRoomDeletes,
      );
    }
  }

  Future<void> applyPendingUpdate({
    required PropertyModel baseline,
    required PendingPropertyUpdate pendingUpdate,
  }) async {
    final dataSource = _requireDataSource();
    if (baseline.hasPendingUpdate) {
      await PendingStorageCleanup.deleteUnusedOnOverwrite(
        oldPending: baseline.pendingUpdate,
        newPending: pendingUpdate,
      );
    }
    await dataSource.setPendingUpdate(
      propertyId: baseline.propertyId,
      pendingUpdate: pendingUpdate,
    );
  }

  Future<PropertyModel> applyDiff({
    required PropertyModel baseline,
    required PropertyEditDiff diff,
  }) async {
    if (diff.isEmpty) {
      return baseline;
    }

    await applyAutoPass(propertyId: baseline.propertyId, diff: diff);

    if (diff.pendingUpdate != null) {
      await applyPendingUpdate(
        baseline: baseline,
        pendingUpdate: diff.pendingUpdate!,
      );
    } else if (baseline.hasPendingUpdate) {
      await _requireDataSource().clearPendingUpdate(baseline.propertyId);
    }

    return _optimisticProperty(baseline, diff);
  }

  PropertyUpdateDataSource _requireDataSource() {
    final dataSource = _updateDataSource;
    if (dataSource == null) {
      throw StateError('PropertyUpdateDataSource is required');
    }
    return dataSource;
  }

  PropertyModel optimisticAfterQueue({
    required PropertyModel baseline,
    required PropertyEditDiff diff,
  }) {
    return _optimisticProperty(baseline, diff);
  }

  PropertyModel _optimisticProperty(PropertyModel baseline, PropertyEditDiff diff) {
    var next = baseline;

    for (final entry in diff.autoPropertyPatch.entries) {
      next = _applyPropertyPatchField(next, entry.key, entry.value);
    }

    next = _applyOptimisticRooms(next, diff);

    if (diff.pendingUpdate != null) {
      return next.copyWith(
        hasPendingUpdate: true,
        pendingUpdate: diff.pendingUpdate,
        updatedAt: DateTime.now(),
      );
    }

    if (baseline.hasPendingUpdate) {
      return next.copyWith(
        hasPendingUpdate: false,
        clearPendingUpdate: true,
        updatedAt: DateTime.now(),
      );
    }

    return next.copyWith(updatedAt: DateTime.now());
  }

  PropertyModel _applyOptimisticRooms(PropertyModel property, PropertyEditDiff diff) {
    if (diff.autoRoomDeletes.isEmpty && diff.autoRoomChanges.isEmpty) {
      return property;
    }

    var rooms = List<RoomModel>.from(property.rooms ?? const []);
    if (diff.autoRoomDeletes.isNotEmpty) {
      final deleteSet = diff.autoRoomDeletes.toSet();
      rooms = rooms.where((r) => !deleteSet.contains(r.roomId)).toList();
    }

    for (final entry in diff.autoRoomChanges.entries) {
      final index = rooms.indexWhere((r) => r.roomId == entry.key);
      if (index < 0) continue;
      rooms[index] = _mergeRoomPatch(rooms[index], entry.value);
    }

    return property.copyWith(rooms: rooms);
  }

  RoomModel _mergeRoomPatch(RoomModel base, Map<String, dynamic> patch) {
    var next = base;
    patch.forEach((key, value) {
      next = switch (key) {
        'roomName' => next.copyWith(roomName: value?.toString() ?? ''),
        'roomLocation' => next.copyWith(roomLocation: value?.toString() ?? ''),
        'isAvailable' => next.copyWith(isAvailable: value == true),
        'price' => next.copyWith(price: (value as num?)?.toInt() ?? next.price),
        _ => next,
      };
    });
    return next;
  }

  PropertyModel _applyPropertyPatchField(
    PropertyModel property,
    String field,
    dynamic value,
  ) {
    return switch (field) {
      'electricityPrice' => property.copyWith(
        electricityPrice: (value as num?)?.toInt() ?? property.electricityPrice,
      ),
      'waterPrice' => property.copyWith(
        waterPrice: (value as num?)?.toInt() ?? property.waterPrice,
      ),
      'wifiPrice' => property.copyWith(
        wifiPrice: (value as num?)?.toInt() ?? property.wifiPrice,
      ),
      'parkingFee' => property.copyWith(
        parkingFee: (value as num?)?.toInt() ?? property.parkingFee,
      ),
      'minimumRentalDuration' => property.copyWith(
        minimumRentalDuration:
            (value as num?)?.toInt() ?? property.minimumRentalDuration,
      ),
      'serviceDescription' => property.copyWith(
        serviceDescription: value?.toString(),
      ),
      'curfewTime' => property.copyWith(curfewTime: value?.toString()),
      _ => property,
    };
  }
}
