import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../home_tab/blocs/landlord_navigation_cubit.dart';
import '../../blocs/create_property/create_property_cubit.dart';
import '../../blocs/step1/step1_cubit.dart';
import '../../blocs/step1/step1_state.dart';
import '../../blocs/step2/step2_cubit.dart';
import '../../blocs/step3/step3_cubit.dart';
import '../../blocs/step4/step4_cubit.dart';
import '../../room_quota_caps.dart';
import '../steps/step1/step1_basic_info_screen.dart';
import '../steps/step2/step2_amenities_images_screen.dart';
import '../steps/step3/step3_rooms_screen.dart';
import '../steps/step4/step4_review_screen.dart';
import '../shared_widgets/create_property_app_bar.dart';
import '../shared_widgets/primary_bottom_bar.dart';

typedef PropertyFlowSubmitFinalStep = Future<void> Function(BuildContext context);

enum PropertyFormFlowHost {
  landlordCreateTab,
  standaloneRoute,
}

class PropertyFormFlowView extends StatefulWidget {
  const PropertyFormFlowView({
    super.key,
    required this.host,
    required this.appBarTitle,
    required this.stepPrimaryLabels,
    required this.onSubmitFinalStep,
    this.onStandaloneCloseFromStepZero,
  }) : assert(stepPrimaryLabels.length == 4);

  final PropertyFormFlowHost host;
  final String appBarTitle;
  final List<String> stepPrimaryLabels;
  final PropertyFlowSubmitFinalStep onSubmitFinalStep;
  final VoidCallback? onStandaloneCloseFromStepZero;

  @override
  State<PropertyFormFlowView> createState() => _PropertyFormFlowViewState();
}

class _PropertyFormFlowViewState extends State<PropertyFormFlowView> {
  final PageController _pageController = PageController();

  static const _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep(int currentStep) {
    switch (currentStep) {
      case 0:
        final cubit = context.read<Step1Cubit>();
        final s = cubit.state;
        if (!s.isQuotaSelectionValid) {
          cubit.markShowErrors();
          final String msg;
          if (s.quotaSelectionLocked) {
            msg =
                'Bài đăng chưa gắn hạn mức hợp lệ. Vui lòng liên hệ hỗ trợ.';
          } else if (s.quotaLoadStatus == PropertyQuotaLoadStatus.failure) {
            msg = s.quotaLoadError ?? 'Không tải được danh sách hạn mức.';
          } else if (s.availableQuotas.isEmpty) {
            msg =
                'Bạn chưa có hạn mức trống. Vui lòng chờ admin duyệt đơn đăng ký chủ trọ.';
          } else {
            msg = 'Vui lòng chọn một hạn mức khu trọ (slot còn trống).';
          }
          Alerts.of(context).showWarning(msg);
          return false;
        }
        if (!s.isBasicFieldsValid) {
          cubit.markShowErrors();
          Alerts.of(context).showWarning(
            'Vui lòng nhập đầy đủ các trường có dấu * với giá trị phù hợp và ghim vị trí trên bản đồ.',
          );
          return false;
        }
        return true;
      case 1:
        final cubit = context.read<Step2Cubit>();
        if (!cubit.state.isValid) {
          cubit.markShowErrors();
          Alerts.of(context).showWarning(
            'Vui lòng chọn "Giờ giấc tự do" hoặc nhập giờ đóng cửa.',
          );
          return false;
        }
        return true;
      case 2:
        final step1 = context.read<Step1Cubit>().state;
        final step3 = context.read<Step3Cubit>();
        final state = step3.state;
        if (!state.isValid) {
          Alerts.of(
            context,
          ).showWarning('Vui lòng thêm ít nhất 1 phòng để tiếp tục.');
          return false;
        }
        final maxList = RoomQuotaCaps.maxListForStep3(
          step1: step1,
          initialRoomListLength: step3.roomsAtWizardOpen,
          isEditFlow: step1.quotaSelectionLocked,
        );
        if (state.rooms.length > maxList) {
          Alerts.of(context).showWarning(
            'Số phòng vượt quá giới hạn cho lượt này theo hạn mức (tối đa $maxList phòng).',
          );
          return false;
        }
        return true;
      case 3:
      default:
        return true;
    }
  }

  Future<void> _handleNext(int currentStep) async {
    if (!_validateCurrentStep(currentStep)) return;

    if (currentStep < _totalSteps - 1) {
      context.read<CreatePropertyNavCubit>().nextStep();
    } else {
      await widget.onSubmitFinalStep(context);
    }
  }

  void _handleBack(int currentStep) {
    if (currentStep > 0) {
      context.read<CreatePropertyNavCubit>().changeStep(currentStep - 1);
      return;
    }

    switch (widget.host) {
      case PropertyFormFlowHost.landlordCreateTab:
        context.read<LandlordNavigationCubit>().changeTab(LandlordTab.home);
      case PropertyFormFlowHost.standaloneRoute:
        widget.onStandaloneCloseFromStepZero?.call();
    }
  }

  bool _popScopeCanPop(BuildContext context) {
    switch (widget.host) {
      case PropertyFormFlowHost.landlordCreateTab:
        final isCreateTab = context.select<LandlordNavigationCubit, bool>(
          (cubit) => cubit.state.currentTab == LandlordTab.createPost,
        );
        return !isCreateTab;
      case PropertyFormFlowHost.standaloneRoute:
        return false;
    }
  }

  void _reloadQuotaWhenStepOneIsVisible(int step) {
    if (widget.host != PropertyFormFlowHost.landlordCreateTab || step != 0) {
      return;
    }

    final step1Cubit = context.read<Step1Cubit>();
    if (step1Cubit.state.quotaSelectionLocked) {
      return;
    }

    unawaited(step1Cubit.loadUnusedQuotas());
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<Step4Cubit, bool>(
      (c) => c.state.isSubmitting,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: _popScopeCanPop(context),
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final currentStep = context.read<CreatePropertyNavCubit>().state;
          _handleBack(currentStep);
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Stack(
              children: [
                BlocListener<CreatePropertyNavCubit, int>(
                  listener: (context, step) {
                    _reloadQuotaWhenStepOneIsVisible(step);
                    if (_pageController.hasClients &&
                        _pageController.page?.round() != step) {
                      _pageController.animateToPage(
                        step,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                  child: BlocBuilder<CreatePropertyNavCubit, int>(
                    builder: (context, currentStep) {
                      if (_pageController.hasClients) {
                        final currentPage = _pageController.page?.round() ?? 0;

                        if (currentPage != currentStep) {
                          final jumpDistance = (currentStep - currentPage).abs();

                          if (jumpDistance > 1) {
                            _pageController.jumpToPage(currentStep);
                          } else {
                            _pageController.animateToPage(
                              currentStep,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        }
                      }
                      final navCubit = context.read<CreatePropertyNavCubit>();
                      final isEditingStep = navCubit.targetReturnStep != null;

                      return Column(
                        children: [
                          CreatePropertyAppBar(
                            title: widget.appBarTitle,
                            currentStep: currentStep + 1,
                            totalSteps: _totalSteps,
                            onBack: () => _handleBack(currentStep),
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: navCubit.changeStep,
                              children: const [
                                StepBasicInfoScreen(),
                                StepAmenitiesImagesScreen(),
                                StepRoomsScreen(),
                                StepReviewScreen(),
                              ],
                            ),
                          ),
                          PrimaryBottomBar(
                            label: widget.stepPrimaryLabels[currentStep],
                            onTap: () async {
                              navCubit.targetReturnStep = null;
                              FocusScope.of(context).unfocus();
                              await _handleNext(currentStep);
                            },
                            secondaryLabel: isEditingStep
                                ? 'Lưu & Quay về Xem lại'
                                : null,
                            onSecondaryTap: isEditingStep
                                ? () {
                                    if (!_validateCurrentStep(currentStep)) return;
                                    navCubit.nextStep();
                                    FocusScope.of(context).unfocus();
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (isSubmitting)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
