import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/data/models/property_quota_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../property_tab/data/repositories/property_repository.dart';
import '../../data/landlord_stat_data.dart';

class LandlordStatsGrid extends StatelessWidget {
  const LandlordStatsGrid({super.key, required this.stats, this.landlordId});

  final List<LandlordStatData> stats;
  final String? landlordId;

  @override
  Widget build(BuildContext context) {
    final uid = landlordId?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.35,
          children: stats.map((stat) => _LandlordStatCard(data: stat)).toList(),
        ),
        if (uid != null && uid.isNotEmpty) ...[
          AppSizes.gapH20,
          Text(
            'Slot khu trọ của bạn',
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
          AppSizes.gapH12,
          _LandlordQuotasLiveSection(landlordId: uid),
        ],
      ],
    );
  }
}

class _LandlordQuotasLiveSection extends StatefulWidget {
  const _LandlordQuotasLiveSection({required this.landlordId});

  final String landlordId;

  @override
  State<_LandlordQuotasLiveSection> createState() =>
      _LandlordQuotasLiveSectionState();
}

class _LandlordQuotasLiveSectionState
    extends State<_LandlordQuotasLiveSection> {
  late final Stream<Either<String, List<PropertyQuotaModel>>> _quotaStream;

  @override
  void initState() {
    super.initState();
    _quotaStream = context.read<PropertyRepository>().watchPropertyQuotas(
      widget.landlordId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Either<String, List<PropertyQuotaModel>>>(
      stream: _quotaStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        return snapshot.data!.fold(
          (message) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              message,
              style: AppTypography.medium14(color: AppColors.danger),
            ),
          ),
          (quotas) => _QuotaSlotsList(quotas: quotas),
        );
      },
    );
  }
}

class _QuotaSlotsList extends StatelessWidget {
  const _QuotaSlotsList({required this.quotas});

  final List<PropertyQuotaModel> quotas;

  @override
  Widget build(BuildContext context) {
    if (quotas.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          'Chưa có hạn mức nào.',
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quotas.length,
      separatorBuilder: (_, __) => AppSizes.gapH10,
      itemBuilder: (context, index) {
        final q = quotas[index];
        final slot = index + 1;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textMuted.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Slot $slot',
                      style: AppTypography.bold14(color: AppColors.textPrimary),
                    ),
                  ),
                  if (q.isUsed)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Đang dùng',
                        style: AppTypography.medium10(color: AppColors.primary),
                      ),
                    )
                  else
                    Text(
                      'Trống',
                      style: AppTypography.medium12(color: AppColors.textMuted),
                    ),
                ],
              ),
              AppSizes.gapH8,
              Text(
                'Tối đa: ${q.maxRooms} phòng',
                style: AppTypography.medium14(color: AppColors.textSecondary),
              ),
              AppSizes.gapH4,
              Text(
                'Đã dùng: ${q.usedRooms} phòng',
                style: AppTypography.medium14(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LandlordStatCard extends StatelessWidget {
  const _LandlordStatCard({required this.data});

  final LandlordStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: AppTypography.medium12(color: AppColors.textMuted),
              ),
              AppSizes.gapH6,
              Text(
                data.value,
                style: AppTypography.bold24(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
