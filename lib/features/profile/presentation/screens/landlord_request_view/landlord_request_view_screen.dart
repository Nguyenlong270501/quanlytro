import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../admin/approvals/data/models/landlord_request.dart';
import '../../../blocs/landlord_request_view/landlord_request_view_cubit.dart';
import '../../../blocs/landlord_request_view/landlord_request_view_state.dart';
import '../../widgets/section_card.dart';

class LandlordRequestViewScreen extends StatelessWidget {
  const LandlordRequestViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        centerTitle: true,
        title: Text(
          'Đơn đăng ký chủ trọ',
          style: AppTypography.bold18(color: AppColors.textPrimary),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.profileBodyGradient,
          ),
        ),
        child: SafeArea(
          child:
              BlocBuilder<LandlordRequestViewCubit, LandlordRequestViewState>(
                builder: (context, state) {
                  return switch (state) {
                    LandlordRequestViewLoading() => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    LandlordRequestViewEmpty() => const _EmptyBody(),
                    LandlordRequestViewError(:final message) => _ErrorBody(
                      message: message,
                    ),
                    LandlordRequestViewLoaded(:final request) => _RequestBody(
                      request: request,
                    ),
                  };
                },
              ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'Bạn chưa có đơn đăng ký chủ trọ trên hệ thống.',
          textAlign: TextAlign.center,
          style: AppTypography.medium16(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.medium16(color: AppColors.danger),
        ),
      ),
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({required this.request});

  final LandlordRequest request;

  String _statusLabel(LandlordRequestStatus s) {
    return switch (s) {
      LandlordRequestStatus.pending => 'Chờ duyệt',
      LandlordRequestStatus.approved => 'Đã duyệt',
      LandlordRequestStatus.rejected => 'Từ chối',
    };
  }

  Color _statusColor(LandlordRequestStatus s) {
    return switch (s) {
      LandlordRequestStatus.pending => AppColors.warning,
      LandlordRequestStatus.approved => AppColors.primary,
      LandlordRequestStatus.rejected => AppColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rejection = request.rejectionReason?.trim();
    final hasRejection = rejection != null && rejection.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _statusColor(request.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(request.status),
                  style: AppTypography.bold14(
                    color: _statusColor(request.status),
                  ),
                ),
              ),
            ],
          ),
          if (request.createdAt != null) ...[
            AppSizes.gapH8,
            Text(
              'Gửi lúc: ${request.createdAt}',
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
          ],
          if (request.updatedAt != null) ...[
            AppSizes.gapH4,
            Text(
              'Cập nhật: ${request.updatedAt}',
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
          ],
          if (hasRejection) ...[
            AppSizes.gapH16,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.danger,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Lý do từ chối: $rejection',
                      style: AppTypography.medium14(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSizes.gapH20,
          _ReadOnlyFieldCard(
            title: 'Thông tin liên hệ',
            children: [
              _ReadOnlyLine(label: 'Họ và tên', value: request.fullName),
              AppSizes.gapH12,
              _ReadOnlyLine(label: 'Số điện thoại', value: request.phone),
              AppSizes.gapH12,
              _ReadOnlyLine(label: 'Địa chỉ', value: request.address),
            ],
          ),
          AppSizes.gapH16,
          _SlotsCard(numOfRoomsList: request.numOfRoomsList),
          AppSizes.gapH16,
          SectionCard(
            title: 'CCCD / Căn cước',
            child: Row(
              children: [
                Expanded(
                  child: _ReadOnlyImageTile(
                    label: 'Mặt trước',
                    url: request.cccdFrontUrl,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ReadOnlyImageTile(
                    label: 'Mặt sau',
                    url: request.cccdBackUrl,
                  ),
                ),
              ],
            ),
          ),
          AppSizes.gapH16,
          SectionCard(
            title: 'Giấy tờ bổ sung',
            subtitle: request.optionalDocumentUrls.isEmpty
                ? 'Không có ảnh đính kèm.'
                : '${request.optionalDocumentUrls.length} ảnh',
            child: request.optionalDocumentUrls.isEmpty
                ? Text(
                    '—',
                    style: AppTypography.medium14(color: AppColors.textMuted),
                  )
                : _ReadOnlyImageGrid(urls: request.optionalDocumentUrls),
          ),
          AppSizes.gapH24,
        ],
      ),
    );
  }
}

class _ReadOnlyFieldCard extends StatelessWidget {
  const _ReadOnlyFieldCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
          AppSizes.gapH16,
          ...children,
        ],
      ),
    );
  }
}

class _ReadOnlyLine extends StatelessWidget {
  const _ReadOnlyLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.medium12(color: AppColors.textMuted)),
        AppSizes.gapH4,
        SelectableText(
          value.isEmpty ? '—' : value,
          style: AppTypography.medium14(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _SlotsCard extends StatelessWidget {
  const _SlotsCard({required this.numOfRoomsList});

  final List<int> numOfRoomsList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hạn mức đăng ký (số phòng / slot)',
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
          AppSizes.gapH12,
          if (numOfRoomsList.isEmpty)
            Text('—', style: AppTypography.medium14(color: AppColors.textMuted))
          else
            ...List.generate(numOfRoomsList.length, (i) {
              final n = numOfRoomsList[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < numOfRoomsList.length - 1 ? 8.h : 0,
                ),
                child: Text(
                  'Slot ${i + 1} — Tối đa: $n phòng',
                  style: AppTypography.medium14(color: AppColors.textSecondary),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ReadOnlyImageTile extends StatelessWidget {
  const _ReadOnlyImageTile({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.medium12(color: AppColors.textMuted)),
        AppSizes.gapH8,
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 3 / 3,
            child: url.isEmpty
                ? ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: Center(
                      child: Icon(
                        Icons.hide_image_outlined,
                        color: AppColors.textDisabled,
                        size: 32.sp,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () =>
                        FullScreenImageViewer.show(context, imageUrls: [url]),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textDisabled,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyImageGrid extends StatelessWidget {
  const _ReadOnlyImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10.w,
      crossAxisSpacing: 10.w,
      childAspectRatio: 1,
      children: [
        for (var i = 0; i < urls.length; i++)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: urls[i].trim().isEmpty
                ? ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: Icon(
                      Icons.hide_image_outlined,
                      color: AppColors.textDisabled,
                      size: 22.sp,
                    ),
                  )
                : GestureDetector(
                    onTap: () => FullScreenImageViewer.show(
                      context,
                      imageUrls: urls,
                      initialIndex: i,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: urls[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textDisabled,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
