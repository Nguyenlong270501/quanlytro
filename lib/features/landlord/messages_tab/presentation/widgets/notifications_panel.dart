import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/utils/property_helper.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../appointment/data/repositories/appointment_repository.dart';
import '../../../property_tab/data/repositories/property_repository.dart';
import '../../blocs/notifications_feed/notifications_feed_cubit.dart';
import '../../blocs/notifications_feed/notifications_feed_state.dart';
import '../../data/models/notification_model.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 120;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) {
      return;
    }
    final cubit = context.read<NotificationsFeedCubit>();
    final state = cubit.state;
    if (state.isLoadingMore || !state.canLoadMore) {
      return;
    }
    cubit.loadMore();
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    final notificationsCubit = context.read<NotificationsFeedCubit>();

    if (!notification.isRead) {
      await notificationsCubit.markAsRead(notification.notificationId);
    }

    if (!mounted) {
      return;
    }

    if (notification.isAppointmentNotification) {
      await _openAppointmentDetail(notification);
      return;
    }

    if (notification.isLandlordRequestNotification) {
      context.push(RouteNames.landlordRequestPage);
      return;
    }

    if (notification.isPropertyApprovalNotification) {
      await _openPropertyDetail(notification);
    }
  }

  Future<void> _openAppointmentDetail(NotificationModel notification) async {
    final appointmentRepository = context.read<AppointmentRepository>();
    final appointmentId = notification.resolvedAppointmentId;
    if (appointmentId == null) {
      if (!mounted) {
        return;
      }
      Alerts.of(context).showError('Không có mã lịch hẹn');
      return;
    }

    final result = await appointmentRepository.getAppointmentById(
      appointmentId,
    );
    if (!mounted) {
      return;
    }
    result.fold(
      (message) => Alerts.of(context).showError(message),
      (appointment) => context.push(
        RouteNames.landlordAppointmentDetail,
        extra: appointment,
      ),
    );
  }

  Future<void> _openPropertyDetail(NotificationModel notification) async {
    final propertyRepository = context.read<PropertyRepository>();
    final propertyId = notification.resolvedPropertyId;
    if (propertyId == null) {
      if (!mounted) {
        return;
      }
      Alerts.of(context).showError('Không có mã bài đăng');
      return;
    }

    final result = await propertyRepository.getPropertyById(propertyId);
    if (!mounted) {
      return;
    }
    result.fold(
      (message) => Alerts.of(context).showError(message),
      (property) => context.push(RouteNames.propertyDetail, extra: property),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsFeedCubit, NotificationsFeedState>(
      builder: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            state.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                state.errorMessage!,
                style: AppTypography.medium14(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return Center(
            child: Text(
              'Chưa có thông báo',
              style: AppTypography.medium14(color: AppColors.textMuted),
            ),
          );
        }

        final showFooter = state.isLoadingMore;
        final itemCount = state.items.length + (showFooter ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final notification = state.items[index];
            return _NotificationItem(
              notification: notification,
              onTap: () => _onNotificationTap(notification),
            );
          },
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14.r),
          border: isUnread
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: AppTypography.bold14(
                color: isUnread
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              notification.content,
              style: AppTypography.medium12(
                color: isUnread ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Đã gửi ${PropertyHelper.formatTimeAgo(notification.createdAt)}',
              style: AppTypography.medium10(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
