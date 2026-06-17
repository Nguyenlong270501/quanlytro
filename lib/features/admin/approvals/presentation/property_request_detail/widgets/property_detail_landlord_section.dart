import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../landlord/create_property/presentation/shared_widgets/section_card.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/widgets/info_row.dart';
import '../../../blocs/admin_property_detail/admin_property_detail_cubit.dart';
import '../../../blocs/admin_property_detail/admin_property_detail_state.dart';

class PropertyDetailLandlordSection extends StatelessWidget {
  const PropertyDetailLandlordSection({
    super.key,
    required this.landlordId,
  });

  final String landlordId;

  String _fallback(String value, String placeholder) =>
      value.trim().isEmpty ? placeholder : value;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPropertyDetailCubit, AdminPropertyDetailState>(
      buildWhen: (prev, curr) =>
          prev.landlordProfileStatus != curr.landlordProfileStatus ||
          prev.displayLandlord != curr.displayLandlord ||
          prev.landlordProfileError != curr.landlordProfileError,
      builder: (context, state) {
        final landlord = state.displayLandlord;
        final nameLine = _fallback(landlord?.displayName ?? '', landlordId);
        final emailLine = _fallback(landlord?.email ?? '', '—');
        final phoneLine = _fallback(landlord?.phoneNumber ?? '', '—');
        final profileStatus = state.landlordProfileStatus;

        return SectionCard(
          emoji: '👤',
          title: 'Chủ trọ',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Column(
              key: ValueKey(profileStatus),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (profileStatus) {
                  LandlordProfileStatus.loading => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSizes.gapW8,
                        Text(
                          'Đang cập nhật hồ sơ chủ trọ...',
                          style: AppTypography.medium12(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LandlordProfileStatus.failure => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      state.landlordProfileError ??
                          'Không thể tải hồ sơ mới nhất.',
                      style: AppTypography.medium12(color: AppColors.warning),
                    ),
                  ),
                  _ => const SizedBox.shrink(),
                },
                InfoRow(label: 'Tên:', value: nameLine),
                InfoRow(label: 'Email:', value: emailLine),
                InfoRow(label: 'Số điện thoại:', value: phoneLine),
                InfoRow(label: 'ID:', value: _fallback(landlordId, '—')),
              ],
            ),
          ),
        );
      },
    );
  }
}
