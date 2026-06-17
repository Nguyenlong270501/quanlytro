import '../../core/services/local_location_service.dart';
import '../../features/landlord/create_property/blocs/step1/step1_state.dart';
import '../../features/landlord/create_property/data/models/property_model.dart';
import '../constants/property_constants.dart';


class PropertyToStepMapper {
  PropertyToStepMapper._();

  static Step1State step1FromProperty(PropertyModel p) {
    final types = p.propertyTypes
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final loc = p.location;
    final addressLine = [
      p.streetAddress,
      p.ward,
      p.city,
    ].where((e) => e.isNotEmpty).join(', ');

    final quotaId = p.quotaId.trim();

    final city = p.city.isNotEmpty ? p.city : null;
    final wardLabel = LocalLocationService().wardDisplayName(
      city: city,
      value: p.ward,
    );

    return Step1State(
      name: p.title,
      propertyTypes: types,
      description: p.description,
      minimumRentalDuration: p.minimumRentalDuration != null && p.minimumRentalDuration! > 0
          ? p.minimumRentalDuration.toString()
          : '',
      city: city,
      ward: wardLabel,
      street: p.streetAddress,
      electricityPrice: p.electricityPrice.toString(),
      waterPrice: p.waterPrice.toString(),
      wifiPrice: p.wifiPrice != null ? p.wifiPrice.toString() : '',
      parkingFee: p.parkingFee != null ? p.parkingFee.toString() : '',
      serviceFee: p.serviceFee != null ? p.serviceFee.toString() : '',
      serviceDescription: p.serviceDescription ?? '',
      latitude: loc?.latitude,
      longitude: loc?.longitude,
      pinnedAddress: addressLine,
      showErrors: false,
      quotaSelectionLocked: true,
      selectedQuotaId: quotaId.isEmpty ? null : quotaId,
      quotaLoadStatus: PropertyQuotaLoadStatus.initial,
    );
  }

  static Set<String> amenitiesFromProperty(PropertyModel p) =>
      Set<String>.from(p.facilities ?? []);

  static Set<String> rulesFromProperty(PropertyModel p) {
    final ruleSet = Set<String>.from(p.rules ?? []);
    final curfew = (p.curfewTime ?? '').trim();
    if (!ruleSet.contains(RuleKeys.freeTime) && curfew.isEmpty) {
      ruleSet.add(RuleKeys.freeTime);
    }
    return ruleSet;
  }

  static String curfewFromProperty(PropertyModel p) =>
      (p.curfewTime ?? '').trim();

  static String ruleNotesFromProperty(PropertyModel p) =>
      (p.rulesDescription ?? '').trim();

  static List<String> imageUrlsFromProperty(PropertyModel p) =>
      List<String>.from(p.imageUrls ?? []);
}
