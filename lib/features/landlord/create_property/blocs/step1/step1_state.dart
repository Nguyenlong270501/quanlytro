import 'package:equatable/equatable.dart';

import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/data/models/property_quota_model.dart';
import '../../../../../core/services/location_service.dart';

enum PropertyQuotaLoadStatus {
  initial,
  loading,
  loaded,
  failure,
}

class Step1State extends Equatable {
  const Step1State({
    this.name = '',
    this.propertyTypes = const [],
    this.description = '',
    this.minimumRentalDuration = '',
    this.city,
    this.ward = '',
    this.street = '',
    this.electricityPrice = '',
    this.waterPrice = '',
    this.wifiPrice = '',
    this.serviceFee = '',
    this.parkingFee = '',
    this.serviceDescription = '',
    this.latitude,
    this.longitude,
    this.pinnedAddress = '',
    this.showErrors = false,
    this.quotaSelectionLocked = false,
    this.quotaLoadStatus = PropertyQuotaLoadStatus.initial,
    this.availableQuotas = const [],
    this.selectedQuotaId,
    this.lockedQuotaSnapshot,
    this.quotaLoadError,
  });

  final String name;
  final List<String> propertyTypes;
  final String description;
  final String minimumRentalDuration;
  final String? city;
  final String ward;
  final String street;
  final String electricityPrice;
  final String waterPrice;
  final String? wifiPrice;
  final String? serviceFee;
  final String? parkingFee;
  final String? serviceDescription;
  final double? latitude;
  final double? longitude;
  final String pinnedAddress;
  final bool showErrors;

  /// Create: false. Edit property: true — không đổi quota trên UI.
  final bool quotaSelectionLocked;
  final PropertyQuotaLoadStatus quotaLoadStatus;
  final List<PropertyQuotaModel> availableQuotas;
  final String? selectedQuotaId;
  /// Chỉ dùng khi [quotaSelectionLocked]: doc quota để hiển thị read-only.
  final PropertyQuotaModel? lockedQuotaSnapshot;
  final String? quotaLoadError;

  bool get isNameValid =>
      name.trim().isNotEmpty && name.trim().length <= 50;
  bool get isPropertyTypeValid => propertyTypes.isNotEmpty;
  bool get isDescriptionValid =>
      description.trim().isNotEmpty && description.trim().length <= 200;
  bool get isCityValid =>
      city != null &&
      city!.isNotEmpty &&
      PropertyConstants.cities.contains(city);

  bool get isWardValid =>
      ward.trim().isNotEmpty && ward.trim().length <= 50;
  bool get isStreetValid =>
      street.trim().isNotEmpty && street.trim().length <= 100;
  bool get isElectricityPriceValid =>
      electricityPrice.trim().isNotEmpty &&
      int.tryParse(electricityPrice) != null &&
      int.tryParse(electricityPrice)! < 100000 &&
      int.parse(electricityPrice) >= 0;
  bool get isWaterPriceValid =>
      waterPrice.trim().isNotEmpty &&
      int.tryParse(waterPrice) != null &&
      int.tryParse(waterPrice)! < 100000 &&
      int.parse(waterPrice) >= 0;
  bool get isLocationPinned =>
      latitude != null &&
      longitude != null &&
      LocationService.isInSupportedRegion(latitude!, longitude!);

  bool get hasServiceFee =>
      serviceFee != null &&
      serviceFee! != '' &&
      int.tryParse(serviceFee!) != null &&
      int.parse(serviceFee!) > 0 &&
      int.parse(serviceFee!) < 10000000;

  bool get isServiceDescriptionValid =>
      !hasServiceFee ||
      (serviceDescription!.trim().isNotEmpty &&
          serviceDescription!.trim().length <= 200);

  bool get isQuotaSelectionValid {
    if (quotaSelectionLocked) {
      return selectedQuotaId != null && selectedQuotaId!.trim().isNotEmpty;
    }
    if (quotaLoadStatus != PropertyQuotaLoadStatus.loaded) {
      return false;
    }
    if (availableQuotas.isEmpty) return false;
    final id = selectedQuotaId?.trim();
    if (id == null || id.isEmpty) return false;
    return availableQuotas.any((q) => q.quotaId == id);
  }

  bool get isBasicFieldsValid =>
      isNameValid &&
      isPropertyTypeValid &&
      isDescriptionValid &&
      isCityValid &&
      isWardValid &&
      isStreetValid &&
      isElectricityPriceValid &&
      isWaterPriceValid &&
      isLocationPinned &&
      isServiceDescriptionValid;

  bool get isValid => isBasicFieldsValid && isQuotaSelectionValid;

  Step1State copyWith({
    String? name,
    List<String>? propertyTypes,
    String? description,
    String? minimumRentalDuration,
    String? Function()? city,
    String? ward,
    String? street,
    String? electricityPrice,
    String? waterPrice,
    String? wifiPrice,
    String? parkingFee,
    String? serviceFee,
    String? serviceDescription,
    double? Function()? latitude,
    double? Function()? longitude,
    String? pinnedAddress,
    bool? showErrors,
    bool? quotaSelectionLocked,
    PropertyQuotaLoadStatus? quotaLoadStatus,
    List<PropertyQuotaModel>? availableQuotas,
    String? Function()? selectedQuotaId,
    PropertyQuotaModel? Function()? lockedQuotaSnapshot,
    String? Function()? quotaLoadError,
  }) {
    return Step1State(
      name: name ?? this.name,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      description: description ?? this.description,
      minimumRentalDuration: minimumRentalDuration ?? this.minimumRentalDuration,
      city: city != null ? city() : this.city,
      ward: ward ?? this.ward,
      street: street ?? this.street,
      electricityPrice: electricityPrice ?? this.electricityPrice,
      waterPrice: waterPrice ?? this.waterPrice,
      wifiPrice: wifiPrice ?? this.wifiPrice,
      parkingFee: parkingFee ?? this.parkingFee,
      serviceFee: serviceFee ?? this.serviceFee,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      pinnedAddress: pinnedAddress ?? this.pinnedAddress,
      showErrors: showErrors ?? this.showErrors,
      quotaSelectionLocked: quotaSelectionLocked ?? this.quotaSelectionLocked,
      quotaLoadStatus: quotaLoadStatus ?? this.quotaLoadStatus,
      availableQuotas: availableQuotas ?? this.availableQuotas,
      selectedQuotaId:
          selectedQuotaId != null ? selectedQuotaId() : this.selectedQuotaId,
      lockedQuotaSnapshot: lockedQuotaSnapshot != null
          ? lockedQuotaSnapshot()
          : this.lockedQuotaSnapshot,
      quotaLoadError:
          quotaLoadError != null ? quotaLoadError() : this.quotaLoadError,
    );
  }

  @override
  List<Object?> get props => [
        name,
        propertyTypes,
        description,
        minimumRentalDuration,
        city,
        ward,
        street,
        electricityPrice,
        waterPrice,
        wifiPrice,
        parkingFee,
        serviceFee,
        serviceDescription,
        latitude,
        longitude,
        pinnedAddress,
        showErrors,
        quotaSelectionLocked,
        quotaLoadStatus,
        availableQuotas,
        selectedQuotaId,
        lockedQuotaSnapshot,
        quotaLoadError,
      ];
}
