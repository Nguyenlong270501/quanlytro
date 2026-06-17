import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/services/local_location_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_approvals_helper.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../data/models/landlord_summary.dart';
import '../../approvals_tab/widgets/approval_quick_actions_row.dart';

/// Email hiển thị: snapshot nhúng trước, sau đó fetch `users`.
String? _resolvedEmail(PropertyModel p, LandlordSummary? fetched) {
  final e = p.landlordSummary?.email?.trim();
  if (e != null && e.isNotEmpty) return e;
  final fe = fetched?.email.trim();
  if (fe != null && fe.isNotEmpty) return fe;
  return null;
}

/// Điện thoại: snapshot nhúng trước, sau đó fetch `users`.
String? _resolvedPhone(PropertyModel p, LandlordSummary? fetched) {
  final pe = p.landlordSummary?.phoneNumber?.trim();
  if (pe != null && pe.isNotEmpty) return pe;
  final fp = fetched?.phoneNumber?.trim();
  if (fp != null && fp.isNotEmpty) return fp;
  return null;
}

class PropertyApprovalCard extends StatelessWidget {
  const PropertyApprovalCard({
    super.key,
    required this.property,
    this.landlordSummary,
    this.showPendingEditBadge = false,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  final PropertyModel property;
  final LandlordSummary? landlordSummary;
  final bool showPendingEditBadge;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  bool get _showActions => onApprove != null && onReject != null;

  @override
  Widget build(BuildContext context) {
    final wardName = LocalLocationService().wardDisplayName(
      city: property.city,
      value: property.ward,
    );
    final emailLine = _resolvedEmail(property, landlordSummary);
    final phoneLine = _resolvedPhone(property, landlordSummary);
    final showEmail = emailLine != null && emailLine.isNotEmpty;
    final showPhone = phoneLine != null && phoneLine.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title.isEmpty
                                ? 'Không tiêu đề'
                                : property.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bold14(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSizes.gapH8,
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                              AppSizes.gapW6,
                              Expanded(
                                child: Text(
                                  [
                                    property.streetAddress,
                                    wardName,
                                    property.city,
                                  ].where((e) => e.isNotEmpty).join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.medium12(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSizes.gapH6,
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                              AppSizes.gapW6,
                              Text(
                                'Chủ trọ: ${PropertyApprovalsHelper.getLandlordDisplayName(
                                  landlordId: property.landlordId,
                                  embedded: property.landlordSummary,
                                  summary: landlordSummary,
                                )}',
                                style: AppTypography.medium12(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (showEmail) ...[
                            AppSizes.gapH4,
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                                AppSizes.gapW6,
                                Expanded(
                                  child: Text(
                                    emailLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.medium12(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (showPhone) ...[
                            AppSizes.gapH4,
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                                AppSizes.gapW6,
                                Expanded(
                                  child: Text(
                                    phoneLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.medium12(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSizes.gapW8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusChip(status: property.status),
                        if (showPendingEditBadge) ...[
                          AppSizes.gapH6,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pendingEditSoft,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.pendingEditBorder,
                              ),
                            ),
                            child: Text(
                              'Chỉnh sửa chờ',
                              style: AppTypography.bold10(
                                color: AppColors.pendingEditText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (_showActions) ...[
                  AppSizes.gapH12,
                  ApprovalQuickActionsRow(
                    onReject: onReject!,
                    onApprove: onApprove!,
                  ),
                ],
                AppSizes.gapH10,
                Text(
                  'Chi tiết phòng xem trong bài đăng',
                  style: AppTypography.medium12(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case PropertyStatus.pending:
        bg = AppColors.warningSoft;
        fg = AppColors.warningStrongText;
        label = 'CHỜ';
        break;
      case PropertyStatus.approved:
        bg = AppColors.successSoft;
        fg = AppColors.primary;
        label = 'ĐÃ DUYỆT';
        break;
      case PropertyStatus.rejected:
        bg = AppColors.errorSoft;
        fg = AppColors.danger;
        label = 'TỪ CHỐI';
        break;
      case PropertyStatus.hidden:
        bg = AppColors.mutedSoft;
        fg = AppColors.textMuted;
        label = 'ẨN';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label, style: AppTypography.bold10(color: fg)),
    );
  }
}
