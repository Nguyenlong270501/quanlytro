import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../auth/data/models/user.dart';
import '../../../blocs/profile_edit/profile_edit_cubit.dart';
import '../../../blocs/profile_edit/profile_edit_state.dart';
import '../../../blocs/profile_image.dart/profile_image_cubit.dart';
import '../../../blocs/profile_image.dart/profile_image_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.user});

  final UserModel? user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user?.userName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileImageCubit, ProfileImageState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ProfileImageStatus.error &&
          !current.hasPendingAvatar,
      listener: (context, state) {
        Alerts.of(context).showError(
          state.errorMessage ?? 'Không thể chọn ảnh',
        );
        context.read<ProfileImageCubit>().clearStatus();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          // backgroundColor: AppColors.border,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          centerTitle: true,
          title: Text(
            'Thông tin cá nhân',
            style: AppTypography.bold20(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.profileBodyGradient,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: BlocBuilder<ProfileImageCubit, ProfileImageState>(
                builder: (context, imageState) {
                  final remoteAvatarUrl = imageState.avatarUrl.isNotEmpty
                      ? imageState.avatarUrl
                      : (widget.user?.avatarUrl ?? '');
                  final isPicking =
                      imageState.status == ProfileImageStatus.picking;

                  return Column(
                    children: [
                      _ProfileHeader(
                        localAvatarPath: imageState.localAvatarPath,
                        remoteAvatarUrl: remoteAvatarUrl,
                        isPicking: isPicking,
                        onTapEditAvatar: () {
                          context.read<ProfileImageCubit>().pickAvatar();
                        },
                      ),
                      AppSizes.gapH20,
                      MyAppTextfield(
                        label: 'Tên người dùng',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        onChanged: (value) {
                          context.read<ProfileEditCubit>().nameChanged(value);
                        },
                      ),
                      AppSizes.gapH16,
                      MyAppTextfield(
                        label: 'Email',
                        initialValue: widget.user?.email ?? '',
                        prefixIcon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      AppSizes.gapH16,
                      MyAppTextfield(
                        label: 'Số điện thoại',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_in_talk_outlined,
                        onChanged: (value) {
                          context.read<ProfileEditCubit>().phoneChanged(value);
                        },
                      ),
                      AppSizes.gapH32,
                      BlocBuilder<ProfileEditCubit, ProfileEditState>(
                        builder: (context, editState) {
                          final isSaving =
                              editState.status == ProfileEditStatus.saving;
                          final isUploading = imageState.status ==
                              ProfileImageStatus.uploading;
                          final canSave =
                              editState.canSave || imageState.hasPendingAvatar;

                          return _SaveButton(
                            isEnabled: canSave && !isSaving && !isUploading,
                            isLoading: isSaving || isUploading,
                            onTap: () => _onSaveChanges(
                              editState: editState,
                              imageState: imageState,
                            ),
                          );
                        },
                      ),
                      AppSizes.gapH12,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSaveChanges({
    required ProfileEditState editState,
    required ProfileImageState imageState,
  }) async {
    final canSave = editState.canSave || imageState.hasPendingAvatar;
    if (!canSave) {
      return;
    }

    FocusScope.of(context).unfocus();

    final imageCubit = context.read<ProfileImageCubit>();
    final editCubit = context.read<ProfileEditCubit>();

    if (imageState.hasPendingAvatar) {
      final uploaded = await imageCubit.uploadPendingAvatar();
      if (!mounted) {
        return;
      }
      if (!uploaded) {
        Alerts.of(context).showError(
          imageCubit.state.errorMessage ?? 'Upload ảnh thất bại',
        );
        imageCubit.clearStatus();
        return;
      }
    }

    if (editState.hasChanges) {
      await editCubit.saveProfile();
      if (!mounted) {
        return;
      }
      if (editCubit.state.status == ProfileEditStatus.error) {
        Alerts.of(context).showError(
          editCubit.state.errorMessage ?? 'Lưu thông tin thất bại',
        );
        editCubit.clearStatus();
        return;
      }
    }

    if (!mounted) {
      return;
    }

    Alerts.of(context).showSuccess('Lưu thay đổi thành công');
    imageCubit.clearStatus();
    editCubit.clearStatus();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.localAvatarPath,
    required this.remoteAvatarUrl,
    required this.onTapEditAvatar,
    required this.isPicking,
  });

  final String? localAvatarPath;
  final String remoteAvatarUrl;
  final VoidCallback onTapEditAvatar;
  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128.w,
      height: 128.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: 128.w, height: 128.w),
          Positioned.fill(
            child: Center(
              child: CircleAvatar(
                radius: 55.r,
                backgroundImage: _resolveAvatarImage(
                  localAvatarPath,
                  remoteAvatarUrl,
                ),
              ),
            ),
          ),
          if (isPicking)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 10.w,
            bottom: 1.h,
            child: InkWell(
              onTap: onTapEditAvatar,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ImageProvider _resolveAvatarImage(
  String? localAvatarPath,
  String remoteAvatarUrl,
) {
  final localPath = localAvatarPath?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    return FileImage(File(localPath));
  }
  if (remoteAvatarUrl.isNotEmpty) {
    return NetworkImage(remoteAvatarUrl);
  }
  return const AssetImage('assets/images/profile.png');
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180.w,
      child: AppButton(
        text: 'Lưu thay đổi',
        onPressed: onTap,
        isLoading: isLoading,
        isEnabled: isEnabled,
      ),
    );
  }
}
