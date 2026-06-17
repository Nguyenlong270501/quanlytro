import 'package:maplibre_gl/maplibre_gl.dart';

const LatLng kMapPickerFallbackLocation = LatLng(
  21.0368,
  105.8348,
);

const int kMapPickerSearchMinLength = 3;

const Duration kMapPickerSearchDebounce = Duration(
  milliseconds: 600,
);

const Duration kMapPickerReverseGeocodeDebounce = Duration(
  milliseconds: 700,
);

const int kMapPickerMaxSuggestionCacheEntries = 30;