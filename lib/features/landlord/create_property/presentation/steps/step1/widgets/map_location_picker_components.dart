part of 'map_location_picker_screen.dart';

void _showLocationPermissionSettingsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cấp quyền vị trí',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn đã từ chối quyền vị trí trước đó. Vui lòng mở Cài đặt và cấp quyền cho ứng dụng.',
          style: AppTypography.medium14(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Để sau',
              style: AppTypography.bold14(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openAppSettings();
            },
            child: Text(
              'Mở Cài đặt',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ),
        ],
      );
    },
  );
}

class _MapSearchUiState {
  const _MapSearchUiState({
    this.isSearching = false,
    this.suggestions = const <GoongPlaceSuggestion>[],
  });

  final bool isSearching;
  final List<GoongPlaceSuggestion> suggestions;
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.initialLatLng,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onMapTap,
  });

  final LatLng initialLatLng;
  final MapCreatedCallback onMapCreated;
  final OnCameraMoveCallback onCameraMove;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString:
          'https://tiles.goong.io/assets/goong_map_web.json?api_key=${AppEnv.goongMaptilesKey}',
      initialCameraPosition: CameraPosition(target: initialLatLng, zoom: 16),
      trackCameraPosition: true,
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.none,
      compassEnabled: false,
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
      onMapClick: (_, __) => onMapTap(),
    );
  }
}

class _MapSearchOverlay extends StatefulWidget {
  const _MapSearchOverlay({
    super.key,
    required this.controller,
    required this.centerLatLng,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final LatLng? Function() centerLatLng;
  final ValueChanged<GoongPlaceSuggestion> onSuggestionTap;

  @override
  State<_MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends State<_MapSearchOverlay> {
  final GoongService _goongService = GoongService();
  final Map<String, List<GoongPlaceSuggestion>> _suggestionCache = {};
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<_MapSearchUiState> _searchState = ValueNotifier(
    const _MapSearchUiState(),
  );

  Timer? _searchDebounceTimer;
  bool _hasSearchFocus = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    widget.controller.removeListener(_onSearchChanged);
    _searchState.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (_hasSearchFocus == _searchFocusNode.hasFocus) return;

    setState(() => _hasSearchFocus = _searchFocusNode.hasFocus);
  }

  void _cacheSuggestions(String keyword, List<GoongPlaceSuggestion> items) {
    if (_suggestionCache.length > kMapPickerMaxSuggestionCacheEntries) {
      _suggestionCache.clear();
    }
    _suggestionCache[keyword] = items;
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(kMapPickerSearchDebounce, _runSearch);
  }

  Future<void> _runSearch() async {
    if (!mounted) return;

    final keyword = widget.controller.text.trim().toLowerCase();
    if (keyword.length < kMapPickerSearchMinLength) {
      _searchState.value = const _MapSearchUiState();
      return;
    }

    final cachedSuggestions = _suggestionCache[keyword];
    if (cachedSuggestions != null) {
      _searchState.value = _MapSearchUiState(suggestions: cachedSuggestions);
      return;
    }

    _searchState.value = _MapSearchUiState(
      isSearching: true,
      suggestions: _searchState.value.suggestions,
    );
    final center = widget.centerLatLng();
    final results = await _goongService.autocomplete(
      widget.controller.text.trim(),
      locationLat: center?.latitude,
      locationLng: center?.longitude,
    );
    if (!mounted || widget.controller.text.trim().toLowerCase() != keyword) {
      return;
    }

    _cacheSuggestions(keyword, results);
    _searchState.value = _MapSearchUiState(suggestions: results);
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    widget.controller.clear();
    _searchState.value = const _MapSearchUiState();
  }

  void _handleSuggestionTap(GoongPlaceSuggestion suggestion) {
    _searchDebounceTimer?.cancel();
    _searchState.value = const _MapSearchUiState();
    widget.onSuggestionTap(suggestion);
  }

  void hideSuggestions() {
    _searchDebounceTimer?.cancel();
    _searchState.value = const _MapSearchUiState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_MapSearchUiState>(
      valueListenable: _searchState,
      builder: (context, state, _) {
        final showSuggestions =
            state.isSearching || state.suggestions.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MapSearchBar(
              controller: widget.controller,
              focusNode: _searchFocusNode,
              isSearching: state.isSearching,
              onClear: _clearSearch,
            ),
            if (_hasSearchFocus && showSuggestions) ...[
              SizedBox(height: 4.h),
              _MapSuggestionsOverlay(
                isSearching: state.isSearching,
                suggestions: state.suggestions,
                onSuggestionTap: _handleSuggestionTap,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MapPickerCubit, MapPickerState, bool>(
      selector: (state) => state.isLoadingCurrentLocation,
      builder: (context, isLoadingCurrentLocation) {
        return FloatingActionButton.small(
          heroTag: 'my_location_button',
          backgroundColor: AppColors.surface,
          onPressed: isLoadingCurrentLocation
              ? null
              : context.read<MapPickerCubit>().moveToCurrentLocation,
          child: isLoadingCurrentLocation
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.my_location_rounded, color: AppColors.primary),
        );
      },
    );
  }
}

class _MapConfirmCardConnector extends StatelessWidget {
  const _MapConfirmCardConnector({
    required this.isConfirmingListenable,
    required this.onConfirm,
  });

  final ValueListenable<bool> isConfirmingListenable;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MapPickerCubit, MapPickerState, _MapConfirmViewState>(
      selector: (state) => _MapConfirmViewState(
        isResolvingAddress: state.isResolvingAddress,
        isLoadingCurrentLocation: state.isLoadingCurrentLocation,
        hasPickedLocation: state.pickedLocation != null,
        address: state.pickedLocation?.address,
      ),
      builder: (context, state) {
        return ValueListenableBuilder<bool>(
          valueListenable: isConfirmingListenable,
          builder: (context, isConfirming, _) {
            final isBusy =
                state.isResolvingAddress ||
                state.isLoadingCurrentLocation ||
                isConfirming;
            return _MapConfirmCard(
              isResolvingAddress: isBusy,
              address: state.address,
              onConfirm: isBusy || !state.hasPickedLocation ? null : onConfirm,
            );
          },
        );
      },
    );
  }
}

class _MapConfirmViewState {
  const _MapConfirmViewState({
    required this.isResolvingAddress,
    required this.isLoadingCurrentLocation,
    required this.hasPickedLocation,
    required this.address,
  });

  final bool isResolvingAddress;
  final bool isLoadingCurrentLocation;
  final bool hasPickedLocation;
  final String? address;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _MapConfirmViewState &&
            other.isResolvingAddress == isResolvingAddress &&
            other.isLoadingCurrentLocation == isLoadingCurrentLocation &&
            other.hasPickedLocation == hasPickedLocation &&
            other.address == address;
  }

  @override
  int get hashCode => Object.hash(
        isResolvingAddress,
        isLoadingCurrentLocation,
        hasPickedLocation,
        address,
      );
}

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: AppColors.shadowSoft,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.surface,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm địa chỉ ...',
              hintStyle: AppTypography.medium14(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: isSearching
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : (controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: onClear,
                          )
                        : null),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapSuggestionsOverlay extends StatelessWidget {
  const _MapSuggestionsOverlay({
    required this.isSearching,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final bool isSearching;
  final List<GoongPlaceSuggestion> suggestions;
  final ValueChanged<GoongPlaceSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: AppColors.shadowSoft,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.4.sh),
        child: isSearching && suggestions.isEmpty
            ? Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Đang tìm...',
                      style: AppTypography.medium14(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 4.h),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      item.description,
                      style: AppTypography.medium14(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSuggestionTap(item),
                  );
                },
              ),
      ),
    );
  }
}

class _MapConfirmCard extends StatelessWidget {
  const _MapConfirmCard({
    required this.isResolvingAddress,
    required this.address,
    required this.onConfirm,
  });

  final bool isResolvingAddress;
  final String? address;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí đã chọn',
            style: AppTypography.bold14(color: AppColors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            isResolvingAddress
                ? 'Đang lấy địa chỉ...'
                : (address ?? 'Đang tải...'),
            style: AppTypography.medium12(color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 11.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Xác nhận vị trí',
                style: AppTypography.bold14(color: AppColors.surface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
