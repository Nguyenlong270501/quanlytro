import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/services/local_location_service.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../../core/utils/vietnamese_search.dart';
import '../../../shared_widgets/filled_text_field.dart';

class WardAutocompleteField extends StatefulWidget {
  const WardAutocompleteField({
    super.key,
    required this.controller,
    required this.city,
    required this.onChanged,
    this.hasError = false,
    this.hintText,
  });

  final TextEditingController controller;
  final String? city;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final String? hintText;

  @override
  State<WardAutocompleteField> createState() => _WardAutocompleteFieldState();
}

class _WardAutocompleteFieldState extends State<WardAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LocalLocationService().loadData();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Iterable<WardModel> _optionsFor(String query) {
    final loc = LocalLocationService();
    final key = loc.cityKeyForName(widget.city);
    if (key.isEmpty) return const Iterable<WardModel>.empty();

    final wards = loc.getWardsByCityKey(key);
    final q = query.trim();
    if (q.isEmpty) {
      return wards.take(24);
    }
    return wards.where((w) => vietnameseContainsNormalized(w.name, q)).take(50);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        final bool isReady = snapshot.connectionState == ConnectionState.done;

        return RawAutocomplete<WardModel>(
          focusNode: _focusNode,
          textEditingController: widget.controller,
          displayStringForOption: (w) => w.name,
          optionsBuilder: (textEditingValue) {
            if (!isReady) return const Iterable<WardModel>.empty();
            return _optionsFor(textEditingValue.text);
          },
          onSelected: (w) => widget.onChanged(w.name),
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return FilledTextField(
              controller: controller,
              focusNode: focusNode,
              hintText: isReady
                  ? (widget.hintText ?? 'Gõ để tìm phường/xã...')
                  : 'Đang tải dữ liệu...',
              hasError: widget.hasError,
              readOnly: !isReady,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final list = options.toList();
            if (list.isEmpty) return const SizedBox.shrink();
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxW =
                    constraints.maxWidth.isFinite && constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : (MediaQuery.sizeOf(context).width - 32.w - 12.w) / 2;
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surface,
                    child: SizedBox(
                      width: maxW,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 220.h),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final w = list[index];
                            return InkWell(
                              onTap: () => onSelected(w),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 10.h,
                                ),
                                child: Text(
                                  w.name,
                                  style: AppTypography.medium14(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
