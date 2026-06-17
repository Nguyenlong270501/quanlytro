import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/route/app_routes.dart';
import '../../../../../core/services/upload_worker_service.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../property_tab/blocs/property_list/property_list_cubit.dart';
import '../../blocs/create_property/create_property_cubit.dart';
import '../../blocs/step1/step1_cubit.dart';
import '../../blocs/step2/step2_cubit.dart';
import '../../blocs/step3/step3_cubit.dart';
import '../../blocs/step4/step4_cubit.dart';
import '../../blocs/step4/step4_state.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/create_property_repository.dart';
import '../../../../../core/utils/property_to_step_mapper.dart';
import '../flow/property_form_flow_view.dart';

class EditPropertyScreen extends StatelessWidget {
  const EditPropertyScreen({super.key, required this.property});

  final PropertyModel property;

  List<String> get _ctaLabels => [
    'Tiếp tục: Tiện ích & Hình ảnh →',
    'Tiếp tục: Thêm phòng →',
    'Tiếp tục: Xem lại →',
    property.status == PropertyStatus.rejected ? 'Gửi lại' : 'Lưu thay đổi',
  ];

  Future<void> _onSubmit(BuildContext context) async {
    final step4 = context.read<Step4Cubit>();
    final updatedProperty = await step4.submitEdit(
      baseline: property,
      step1: context.read<Step1Cubit>().state,
      step2: context.read<Step2Cubit>().state,
      step3: context.read<Step3Cubit>().state,
    );
    if (!context.mounted) return;

    final submitState = step4.state;
    if (submitState.status == SubmitStatus.failure) {
      Alerts.of(context).showError(
        submitState.errorMessage ?? 'Lưu thất bại, vui lòng thử lại.',
      );
      return;
    }

    if (!submitState.isSuccess) {
      return;
    }

    final propertyListCubit = context.read<PropertyListCubit>();
    final repo = context.read<CreatePropertyRepository>();

    if (updatedProperty != null) {
      propertyListCubit.applyLocalPropertyUpdate(updatedProperty);
    }

    if (context.canPop()) {
      context.pop(true);
    } else {
      final rootCtx = AppRoutes.rootNavigatorKey.currentContext;
      if (rootCtx != null && rootCtx.mounted) {
        rootCtx.go('${RouteNames.homepage}?tab=posts');
      }
    }

    final rootCtx = AppRoutes.rootNavigatorKey.currentContext;
    if (rootCtx == null || !rootCtx.mounted) {
      return;
    }

    Alerts.of(rootCtx).showSuccess(
      'Chỉnh sửa bài thành công! Bài đăng của bạn đang được tải, vui lòng không tắt ứng dụng và chờ trong giây lát.',
    );

    unawaited(
      UploadWorkerService.checkAndUploadDraft(
        repo,
        onSuccess: (title) {
          final ctx = AppRoutes.rootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            Alerts.of(ctx).showSuccess('Bài đăng "$title" đã tải lên thành công! 🎉');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = property.rooms ?? [];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreatePropertyNavCubit()),
        BlocProvider(
          create: (_) =>
              Step1Cubit()
                ..hydrate(PropertyToStepMapper.step1FromProperty(property)),
        ),
        BlocProvider(
          create: (_) => Step2Cubit(
            initialAmenities: PropertyToStepMapper.amenitiesFromProperty(
              property,
            ),
            initialRules: PropertyToStepMapper.rulesFromProperty(property),
            initialImages: PropertyToStepMapper.imageUrlsFromProperty(property),
            initialCurfew: PropertyToStepMapper.curfewFromProperty(property),
            initialRuleNotes: PropertyToStepMapper.ruleNotesFromProperty(
              property,
            ),
          ),
        ),
        BlocProvider(create: (_) => Step3Cubit(initialRooms: rooms)),
        BlocProvider(create: (_) => Step4Cubit()),
      ],
      child: PropertyFormFlowView(
        host: PropertyFormFlowHost.standaloneRoute,
        appBarTitle: 'Chỉnh sửa khu trọ',
        stepPrimaryLabels: _ctaLabels,
        onStandaloneCloseFromStepZero: () => context.pop(),
        onSubmitFinalStep: _onSubmit,
      ),
    );
  }
}
