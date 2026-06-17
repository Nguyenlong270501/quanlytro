class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.ward,
    this.street,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? ward;
  final String? street;

  PickedLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? ward,
    String? street,
  }) {
    return PickedLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      ward: ward ?? this.ward,
      street: street ?? this.street,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'ward': ward,
      'street': street,
    };
  }
}