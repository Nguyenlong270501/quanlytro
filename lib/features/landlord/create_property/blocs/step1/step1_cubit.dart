import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/property_quota_model.dart';
import '../../../../../core/services/local_location_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../data/models/picked_location.dart';
import 'step1_state.dart';

class Step1Cubit extends Cubit<Step1State> {
  Step1Cubit() : super(const Step1State());

  final _locationService = LocationService();
  final _firestore = FirebaseFirestore.instance;
  static final Set<String> _reservedQuotaIds = <String>{};

  void updateName(String value) => emit(state.copyWith(name: value));

  void togglePropertyType(String type) {
    final currentTypes = List<String>.from(state.propertyTypes);

    if (currentTypes.contains(type)) {
      currentTypes.remove(type);
    } else {
      currentTypes.add(type);
    }

    emit(state.copyWith(propertyTypes: currentTypes));
  }

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateMinimumRentalDuration(String value) =>
      emit(state.copyWith(minimumRentalDuration: value));

  void updateCity(String? value) {
    final previous = state.city;
    emit(
      state.copyWith(
        city: () => value,
        ward: previous != value ? '' : state.ward,
      ),
    );
  }

  void updateWard(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(ward: ''));
      return;
    }
    final display = LocalLocationService().wardDisplayName(
      city: state.city,
      value: trimmed,
    );
    emit(state.copyWith(ward: display));
  }

  void updateStreet(String value) => emit(state.copyWith(street: value));

  void updateElectricityPrice(String value) =>
      emit(state.copyWith(electricityPrice: value));

  void updateWaterPrice(String value) =>
      emit(state.copyWith(waterPrice: value));

  void updateWifiPrice(String value) => emit(state.copyWith(wifiPrice: value));

  void updateParkingFee(String value) =>
      emit(state.copyWith(parkingFee: value));

  void updateServiceFee(String value) =>
      emit(state.copyWith(serviceFee: value));

  void updateServiceDescription(String value) =>
      emit(state.copyWith(serviceDescription: value));

  void updatePinnedLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    emit(
      state.copyWith(
        latitude: () => latitude,
        longitude: () => longitude,
        pinnedAddress: address,
      ),
    );
  }

  void markShowErrors() => emit(state.copyWith(showErrors: true));

  void processPickedLocation(PickedLocation picked) {
    final loc = LocalLocationService();

    if (!_locationService.isPickedLocationSupported(picked)) {
      emit(
        state.copyWith(
          latitude: () => picked.latitude,
          longitude: () => picked.longitude,
          pinnedAddress: picked.address,
          ward: '',
        ),
      );
      return;
    }

    final cityRaw = _locationService.normalizeLocationName(picked.city);
    final wardRaw = _locationService.normalizeLocationName(picked.ward);
    final streetRaw = _locationService.normalizeLocationName(picked.street);
    final matchedCity = _locationService.matchSupportedCity(cityRaw);
    final cityForWard = matchedCity ?? state.city;

    final wardDisplay = wardRaw.isNotEmpty
        ? loc.wardDisplayName(city: cityForWard, value: wardRaw)
        : state.ward;

    emit(
      state.copyWith(
        latitude: () => picked.latitude,
        longitude: () => picked.longitude,
        pinnedAddress: picked.address,
        city: () => matchedCity ?? state.city,
        ward: wardRaw.isNotEmpty ? wardDisplay : state.ward,
        street: streetRaw.isNotEmpty ? streetRaw : state.street,
      ),
    );
  }

  void selectQuota(String quotaId) {
    if (state.quotaSelectionLocked) return;
    emit(state.copyWith(selectedQuotaId: () => quotaId));
  }

  void reserveQuota(String? quotaId) {
    final trimmed = quotaId?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }
    _reservedQuotaIds.add(trimmed);
  }

  static void releaseReservedQuota(String? quotaId) {
    final trimmed = quotaId?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }
    _reservedQuotaIds.remove(trimmed);
  }

  Future<void> loadUnusedQuotas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      emit(
        state.copyWith(
          quotaLoadStatus: PropertyQuotaLoadStatus.failure,
          quotaLoadError: () => 'Chưa đăng nhập.',
          availableQuotas: const [],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        quotaLoadStatus: PropertyQuotaLoadStatus.loading,
        quotaLoadError: () => null,
      ),
    );

    try {
      if (state.quotaSelectionLocked) {
        final qid = state.selectedQuotaId?.trim() ?? '';
        PropertyQuotaModel? snapshot;
        if (qid.isNotEmpty) {
          final doc = await _firestore
              .collection('users')
              .doc(uid)
              .collection('propertyQuotas')
              .doc(qid)
              .get();
          if (doc.exists && doc.data() != null) {
            snapshot = PropertyQuotaModel.fromMap(
              Map<String, dynamic>.from(doc.data()!),
              documentId: doc.id,
            );
          }
        }
        emit(
          state.copyWith(
            quotaLoadStatus: PropertyQuotaLoadStatus.loaded,
            availableQuotas: const [],
            lockedQuotaSnapshot: () => snapshot,
            quotaLoadError: () => null,
          ),
        );
        return;
      }

      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('propertyQuotas')
          .where('isUsed', isEqualTo: false)
          .get();

      final list = snap.docs
          .map(
            (d) => PropertyQuotaModel.fromMap(
              Map<String, dynamic>.from(d.data()),
              documentId: d.id,
            ),
          )
          .where((quota) => !_reservedQuotaIds.contains(quota.quotaId.trim()))
          .toList();

      emit(
        state.copyWith(
          quotaLoadStatus: PropertyQuotaLoadStatus.loaded,
          availableQuotas: list,
          lockedQuotaSnapshot: () => null,
          quotaLoadError: () => null,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          quotaLoadStatus: PropertyQuotaLoadStatus.failure,
          quotaLoadError: () => e.toString(),
          availableQuotas: const [],
        ),
      );
    }
  }

  void reset() => emit(const Step1State());

  void hydrate(Step1State initial) => emit(initial.copyWith(showErrors: false));
}
