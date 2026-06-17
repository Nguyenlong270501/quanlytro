import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../create_property/data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';
import 'property_list_state.dart';

class PropertyListCubit extends Cubit<PropertyListState> {
  PropertyListCubit({required this.repository}) : super(PropertyListLoading());

  final PropertyRepository repository;

  StreamSubscription<Either<String, List<PropertyModel>>>? _subscription;
  final Map<String, PropertyModel> _localOverrides = {};
  String? _activeLandlordId;

  /// Optimistic UI sau edit (trước khi upload queue ghi Firestore).
  void applyLocalPropertyUpdate(PropertyModel updated) {
    _localOverrides[updated.propertyId] = updated;
    final current = state;
    if (current is PropertyListLoaded) {
      emit(PropertyListLoaded(_mergeWithOverrides(current.properties)));
      return;
    }
    emit(PropertyListLoaded([updated]));
  }

  List<PropertyModel> _mergeWithOverrides(List<PropertyModel> fromServer) {
    if (_localOverrides.isEmpty) {
      return fromServer;
    }
    return fromServer
        .map((p) => _localOverrides[p.propertyId] ?? p)
        .toList(growable: false);
  }

  void _reconcileOverrides(List<PropertyModel> fromServer) {
    if (_localOverrides.isEmpty) {
      return;
    }
    final serverById = {for (final p in fromServer) p.propertyId: p};
    _localOverrides.removeWhere((id, local) {
      final server = serverById[id];
      if (server == null) {
        return false;
      }
      return !server.updatedAt.isBefore(local.updatedAt);
    });
  }

  Future<void> fetchProperties(String landlordId) async {
    final normalizedId = landlordId.trim();
    if (normalizedId.isEmpty) {
      return;
    }

    if (_activeLandlordId == normalizedId &&
        _subscription != null &&
        state is PropertyListLoaded) {
      return;
    }

    _activeLandlordId = normalizedId;
    await _subscription?.cancel();
    _subscription = null;

    if (state is! PropertyListLoaded) {
      emit(PropertyListLoading());
    }

    _subscription = repository.watchProperties(normalizedId).listen(
      (result) {
        result.fold(
          (message) => emit(PropertyListError(message)),
          (properties) {
            _reconcileOverrides(properties);
            emit(PropertyListLoaded(_mergeWithOverrides(properties)));
          },
        );
      },
      onError: (Object e, StackTrace stackTrace) {
        emit(PropertyListError('Không thể tải danh sách nhà: $e'));
      },
    );
  }

  void resetAfterLogout() {
    stopListening();
    _localOverrides.clear();
    _activeLandlordId = null;
    emit(PropertyListLoading());
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
