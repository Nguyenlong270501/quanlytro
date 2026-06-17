import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/upload_worker_service.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../auth/blocs/authentication/auth_cubit.dart';
import '../../../home_tab/blocs/landlord_navigation_cubit.dart';
import '../../blocs/create_property/create_property_cubit.dart';
import '../../blocs/step1/step1_cubit.dart';
import '../../blocs/step2/step2_cubit.dart';
import '../../blocs/step3/step3_cubit.dart';
import '../../blocs/step4/step4_cubit.dart';
import '../../blocs/step4/step4_state.dart';
import '../../data/repositories/create_property_repository.dart';
import '../flow/property_form_flow_view.dart';

class CreatePropertyScreen extends StatelessWidget {
  const CreatePropertyScreen({super.key});

  static const _ctaLabels = <String>[
    'Tiếp tục: Tiện ích & Hình ảnh →',
    'Tiếp tục: Thêm phòng →',
    'Tiếp tục: Xem lại →',
    'Hoàn tất & Đăng tin ngay 🚀',
  ];

  Future<void> _onSubmitFinalStep(BuildContext context) async {
    final step4 = context.read<Step4Cubit>();
    final user = context.read<AuthenticationCubit>().currentUser;
    if (user == null) {
      Alerts.of(context).showError('Vui lòng đăng nhập để tạo khu trọ mới.');
      return;
    }
    await step4.submit(
      currentUser: user,
      step1: context.read<Step1Cubit>().state,
      step2: context.read<Step2Cubit>().state,
      step3: context.read<Step3Cubit>().state,
    );
    if (!context.mounted) return;
    final state = step4.state;
    if (state.isSuccess) {
      context.read<LandlordNavigationCubit>().changeTab(LandlordTab.home);

      final step1Cubit = context.read<Step1Cubit>();
      step1Cubit.reserveQuota(step1Cubit.state.selectedQuotaId);
      step1Cubit.reset();
      context.read<Step2Cubit>().reset();
      context.read<Step3Cubit>().reset();
      step4.reset();
      context.read<CreatePropertyNavCubit>().changeStep(0);
      Alerts.of(context).showSuccess(
        'Đăng bài thành công! Bài đăng của bạn đang được tải, vui lòng không tắt ứng dụng và chờ trong giây lát.',
      );

      final repo = context.read<CreatePropertyRepository>();
      UploadWorkerService.checkAndUploadDraft(
        repo,
        onSuccess: (title) {
          if (!context.mounted) return;
          Alerts.of(
            context,
          ).showSuccess('Bài đăng "$title" đã tải lên thành công! 🎉');
        },
      );
    } else if (state.status == SubmitStatus.failure) {
      Alerts.of(
        context,
      ).showError(state.errorMessage ?? 'Đăng tin thất bại, vui lòng thử lại.');
    }
  }

  void _reloadQuotaWhenStepOneIsVisible(BuildContext context) {
    final navCubit = context.read<CreatePropertyNavCubit>();
    if (navCubit.state != 0) {
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreatePropertyNavCubit()),
        BlocProvider(create: (_) => Step1Cubit()),
        BlocProvider(create: (_) => Step2Cubit()),
        BlocProvider(create: (_) => Step3Cubit()),
        BlocProvider(create: (_) => Step4Cubit()),
      ],
      child: BlocListener<LandlordNavigationCubit, LandlordNavigationState>(
        listenWhen: (previous, current) =>
            previous.currentTab != current.currentTab &&
            current.currentTab == LandlordTab.createPost,
        listener: (context, state) => _reloadQuotaWhenStepOneIsVisible(context),
        child: PropertyFormFlowView(
          host: PropertyFormFlowHost.landlordCreateTab,
          appBarTitle: 'Tạo khu trọ mới',
          stepPrimaryLabels: _ctaLabels,
          onSubmitFinalStep: _onSubmitFinalStep,
        ),
      ),
    );
  }
}
