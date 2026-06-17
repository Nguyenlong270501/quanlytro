import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../../create_property/blocs/step1/step1_cubit.dart';
import '../../../../create_property/data/models/property_model.dart';
import '../../../../create_property/data/repositories/create_property_repository.dart';
import '../../../data/repositories/property_repository.dart';

class PropertyBottom extends StatefulWidget {
  const PropertyBottom({super.key, required this.property});

  final PropertyModel property;

  @override
  State<PropertyBottom> createState() => _PropertyBottomState();
}

class _PropertyBottomState extends State<PropertyBottom> {
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  bool get _canToggleVisibility {
    final s = widget.property.status;
    return s == PropertyStatus.approved || s == PropertyStatus.hidden;
  }

  bool get _showEditInsteadOfHide =>
      widget.property.status == PropertyStatus.pending ||
      widget.property.status == PropertyStatus.rejected;

  bool get _isHidden => widget.property.status == PropertyStatus.hidden;

  Future<void> _openEdit() async {
    await context.push<bool>(RouteNames.editProperty, extra: widget.property);
  }

  Future<void> _toggleVisibility() async {
    if (!_canToggleVisibility || _busy.value) return;

    final willHide = widget.property.status == PropertyStatus.approved;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willHide ? 'Ẩn bài đăng?' : 'Hiện bài đăng?'),
        content: Text(
          willHide
              ? 'Bài đăng sẽ không hiển thị với người tìm phòng (ví dụ khi đã đủ phòng). Bạn có thể hiện lại bất cứ lúc nào.'
              : 'Bài đăng sẽ hiển thị lại công khai như khi đã được duyệt.',
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(willHide ? 'Ẩn' : 'Hiện'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _busy.value = true;

    final result = await context
        .read<PropertyRepository>()
        .updatePropertyStatus(
          propertyId: widget.property.propertyId,
          status: willHide ? PropertyStatus.hidden : PropertyStatus.approved,
        );
    if (!mounted) return;
    result.fold(
      (message) => Alerts.of(
        context,
      ).showError('Không cập nhật được trạng thái: $message'),
      (_) => Alerts.of(
        context,
      ).showSuccess(willHide ? 'Đã ẩn bài đăng.' : 'Đã hiển thị lại bài đăng.'),
    );
    _busy.value = false;
  }

  Future<void> _confirmAndDeleteProperty() async {
    if (_busy.value) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Xóa bài đăng?',
          style: AppTypography.bold18(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bài đăng này? Thao tác không thể hoàn tác: '
          'toàn bộ phòng và dữ liệu bài sẽ bị xóa. Hạn mức (slot) sẽ được trả lại '
          '(có thể dùng cho bài khác).',
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text('Hủy', style: AppTypography.medium14()),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(
              'Xóa',
              style: AppTypography.bold14(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _busy.value = true;

    final repo = context.read<CreatePropertyRepository>();
    final result = await repo.deletePropertyAndReleaseQuota(
      landlordId: widget.property.landlordId,
      propertyId: widget.property.propertyId,
      quotaId: widget.property.quotaId,
    );

    final alertContext = AppRoutes.rootNavigatorKey.currentContext;
    final effectiveContext = alertContext?.mounted == true
        ? alertContext
        : (mounted ? context : null);

    result.fold(
      (message) {
        if (effectiveContext != null) {
          Alerts.of(effectiveContext).showError('Không xóa được: $message');
        }
      },
      (_) {
        Step1Cubit.releaseReservedQuota(widget.property.quotaId);
        if (effectiveContext != null) {
          Alerts.of(effectiveContext).showSuccess('Đã xóa bài đăng.');
        }
      },
    );
    if (mounted) {
      _busy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _busy,
      builder: (context, isBusy, child) {
        return Row(
          children: [
            if (_showEditInsteadOfHide)
              _buildIconButton(
                title: 'Sửa',
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                onPressed: isBusy ? null : _openEdit,
              )
            else
              _buildIconButton(
                title: _isHidden ? 'Hiện bài' : 'Ẩn bài',
                icon: _isHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _canToggleVisibility
                    ? AppColors.mutedSoft
                    : AppColors.textMuted.withValues(alpha: 0.35),
                onPressed: !_canToggleVisibility || isBusy
                    ? null
                    : _toggleVisibility,
              ),
            Container(
              height: 24.h,
              width: 1,
              color: AppColors.textMuted.withValues(alpha: 0.2),
            ),
            _buildIconButton(
              title: 'Xóa',
              icon: Icons.delete_outline,
              color: AppColors.danger,
              onPressed: isBusy ? null : _confirmAndDeleteProperty,
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton({
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp, color: color),
        label: Text(title, style: AppTypography.bold14(color: color)),
      ),
    );
  }
}
