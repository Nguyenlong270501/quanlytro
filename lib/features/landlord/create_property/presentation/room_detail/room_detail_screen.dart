import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/services/image_picker_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../blocs/room_detail/room_detail_cubit.dart';
import '../../blocs/room_detail/room_detail_state.dart';
import '../../data/models/room_model.dart';
import '../shared_widgets/filled_text_field.dart';
import '../shared_widgets/section_card.dart';
import '../shared_widgets/form_field_label.dart';
import '../shared_widgets/text_field_with_suffix.dart';
import '../steps/step2/widgets/amenity_picker.dart';
import '../steps/step2/widgets/image_grid_picker.dart';
import 'widgets/room_detail_app_bar.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, this.initialRoom});
  final RoomModel? initialRoom;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final initialAmenities =
            initialRoom?.amenities.map((e) => e.label).toSet() ??
            PropertyConstants.roomAmenities
                .where((e) => e.initiallyActive)
                .map((e) => e.label)
                .toSet();

        return RoomDetailCubit(
          ImagePickerService(),
          initialAmenities: initialAmenities,
          initialImages: initialRoom?.imageUrls.toList(),
          initialIsAvailable: initialRoom?.isAvailable ?? true,
        );
      },
      child: _RoomDetailView(initialRoom: initialRoom),
    );
  }
}

class _RoomDetailView extends StatefulWidget {
  const _RoomDetailView({this.initialRoom});
  final RoomModel? initialRoom;

  @override
  State<_RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<_RoomDetailView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _depositCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _occupancyCtrl;
  bool get _isEdit => widget.initialRoom != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRoom;
    _nameCtrl = TextEditingController(text: initial?.roomName ?? '');
    _locationCtrl = TextEditingController(text: initial?.roomLocation ?? '');
    _priceCtrl = TextEditingController(
      text: initial != null ? initial.price.toString() : '',
    );
    _depositCtrl = TextEditingController(
      text: initial != null ? initial.priceDeposit.toString() : '',
    );
    _areaCtrl = TextEditingController(
      text: initial != null ? initial.area.toStringAsFixed(0) : '',
    );
    _occupancyCtrl = TextEditingController(
      text: initial != null ? initial.maxTenants.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _areaCtrl.dispose();
    _occupancyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đóng form?'),
        content: const Text('Các thay đổi chưa lưu sẽ bị mất.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.pop();
  }

  void _handleSave() {
    final cubit = context.read<RoomDetailCubit>();

    final resultRoom = cubit.validateAndCreate(
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      deposit: _depositCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      occupancy: _occupancyCtrl.text.trim(),
      identity: widget.initialRoom,
    );

    if (resultRoom == null) {
      final isImagesMissing =
          cubit.state.imageUrls.length < RoomDetailCubit.minImages;
      final message = isImagesMissing
          ? 'Phòng cần tối thiểu ${RoomDetailCubit.minImages} ảnh.'
          : 'Vui lòng nhập đầy đủ các trường có dấu *';
      Alerts.of(context).showWarning(message);
    } else {
      context.pop(resultRoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              RoomDetailAppBar(
                isEdit: _isEdit,
                onClose: _handleClose,
                onSave: _handleSave,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  child: BlocBuilder<RoomDetailCubit, RoomDetailState>(
                    builder: (context, state) {
                      final cubit = context.read<RoomDetailCubit>();
                      final showErr = state.showErrors;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionCard(
                            title: 'Trạng thái phòng',
                            child: SwitchListTile(
                              value: state.isAvailable,
                              onChanged: cubit.updateAvailability,
                              title: Text(
                                state.isAvailable
                                    ? 'Phòng đang trống'
                                    : 'Đã cho thuê',
                              ),
                              subtitle: Text(
                                state.isAvailable
                                    ? 'Hiển thị công khai để tìm khách'
                                    : 'Tạm ẩn khỏi danh sách cho thuê',
                              ),
                              activeThumbColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          AppSizes.gapH16,
                          _buildBasicSection(cubit, showErr),
                          AppSizes.gapH16,
                          SectionCard(
                            title: 'Nội thất & Tiện ích riêng',
                            child: AmenityPicker(
                              options: PropertyConstants.roomAmenities,
                              activeLabels: state.activeAmenities,
                              onToggle: cubit.toggleAmenity,
                            ),
                          ),
                          AppSizes.gapH16,
                          SectionCard(
                            title: 'Ảnh chụp phòng',
                            required: true,
                            subtitle:
                                'Tối thiểu ${RoomDetailCubit.minImages} — tối đa ${RoomDetailCubit.maxImages} ảnh '
                                '(${state.imageUrls.length}/${RoomDetailCubit.maxImages}).',
                            child: ImageGridPicker(
                              urls: state.imageUrls,
                              onAdd: () async {
                                final errorMsg = await cubit.pickImages();
                                if (errorMsg != null && context.mounted) {
                                  Alerts.of(context).showWarning(errorMsg);
                                }
                              },
                              onRemoveAt: cubit.removeImageAt,
                              maxCount: RoomDetailCubit.maxImages,
                              hasError:
                                  showErr &&
                                  state.imageUrls.length <
                                      RoomDetailCubit.minImages,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicSection(RoomDetailCubit cubit, bool showErr) {
    final digitsOnly = [FilteringTextInputFormatter.digitsOnly];
    void onChanged(_) => cubit.clearErrors();

    return SectionCard(
      title: 'Thông tin cơ bản',
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
                    const FormFieldLabel(
                      label: 'Tên / Số phòng',
                      required: true,
                    ),
                    AppSizes.gapH8,
                    FilledTextField(
                      controller: _nameCtrl,
                      hintText: 'VD: Phòng 101',
                      onChanged: onChanged,
                      hasError: showErr && _nameCtrl.text.trim().isEmpty,
                    ),
                  ],
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Vị trí', required: true),
                    AppSizes.gapH8,
                    FilledTextField(
                      controller: _locationCtrl,
                      hintText: 'VD: Tầng 1',
                      onChanged: onChanged,
                      hasError: showErr && _locationCtrl.text.trim().isEmpty,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Giá thuê', required: true),
          AppSizes.gapH8,
          TextFieldWithSuffix(
            controller: _priceCtrl,
            suffix: 'đ/tháng',
            hintText: '4.000.000',
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onChanged,
            hasError: showErr && _priceCtrl.text.trim().isEmpty,
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Tiền cọc', required: true),
          AppSizes.gapH8,
          TextFieldWithSuffix(
            controller: _depositCtrl,
            suffix: 'đ',
            hintText: '2.000.000',
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onChanged,
            hasError: showErr && _depositCtrl.text.trim().isEmpty,
          ),
          AppSizes.gapH16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Diện tích', required: true),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: _areaCtrl,
                      suffix: 'm²',
                      hintText: '25',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: onChanged,
                      hasError: showErr && _areaCtrl.text.trim().isEmpty,
                    ),
                  ],
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(
                      label: 'Số người tối đa',
                      required: true,
                    ),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: _occupancyCtrl,
                      suffix: 'người',
                      hintText: '2',
                      keyboardType: TextInputType.number,
                      inputFormatters: digitsOnly,
                      onChanged: onChanged,
                      hasError: showErr && _occupancyCtrl.text.trim().isEmpty,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
