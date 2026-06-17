import '../../../create_property/data/models/property_model.dart';

abstract class PropertyListState {}

class PropertyListLoading extends PropertyListState {}

class PropertyListLoaded extends PropertyListState {
  final List<PropertyModel> properties;

  PropertyListLoaded(this.properties);

  List<PropertyModel> get pendingItems =>
      properties.where((p) => p.status == PropertyStatus.pending).toList();

  List<PropertyModel> get approvedItems =>
      properties.where((p) => p.status == PropertyStatus.approved).toList();

  List<PropertyModel> get rejectedItems =>
      properties.where((p) => p.status == PropertyStatus.rejected).toList();

  List<PropertyModel> get hiddenItems =>
      properties.where((p) => p.status == PropertyStatus.hidden).toList();
}

class PropertyListError extends PropertyListState {
  final String message;

  PropertyListError(this.message);
}
