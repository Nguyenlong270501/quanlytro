import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../blocs/step1/step1_cubit.dart';
import '../../../blocs/step1/step1_state.dart';
import '../../../data/models/picked_location.dart';
import 'widgets/basic_info_section.dart';
import 'widgets/cost_section.dart';
import 'widgets/location_section.dart';
import 'widgets/quota_section.dart';

class StepBasicInfoScreen extends StatefulWidget {
  const StepBasicInfoScreen({super.key});

  @override
  State<StepBasicInfoScreen> createState() => _StepBasicInfoScreenState();
}

class _StepBasicInfoScreenState extends State<StepBasicInfoScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minDurationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _wardCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _elecCtrl;
  late final TextEditingController _waterCtrl;
  late final TextEditingController _netCtrl;
  late final TextEditingController _parkCtrl;
  late final TextEditingController _svcCtrl;
  late final TextEditingController _svcDescCtrl;
  String _wardDisplayText(Step1State state) => state.ward;

  @override
  void initState() {
    super.initState();
    final state = context.read<Step1Cubit>().state;
    _nameCtrl = TextEditingController(text: state.name);
    _minDurationCtrl = TextEditingController(text: state.minimumRentalDuration);
    _descCtrl = TextEditingController(text: state.description);
    _wardCtrl = TextEditingController(text: _wardDisplayText(state));
    _streetCtrl = TextEditingController(text: state.street);
    _elecCtrl = TextEditingController(text: state.electricityPrice.toString());
    _waterCtrl = TextEditingController(text: state.waterPrice.toString());
    _netCtrl = TextEditingController(text: state.wifiPrice.toString());
    _parkCtrl = TextEditingController(text: state.parkingFee.toString());
    _svcCtrl = TextEditingController(text: state.serviceFee.toString());
    _svcDescCtrl = TextEditingController(text: state.serviceDescription);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<Step1Cubit>().loadUnusedQuotas();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minDurationCtrl.dispose();
    _descCtrl.dispose();
    _wardCtrl.dispose();
    _streetCtrl.dispose();
    _elecCtrl.dispose();
    _waterCtrl.dispose();
    _netCtrl.dispose();
    _parkCtrl.dispose();
    _svcCtrl.dispose();
    _svcDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker(Step1Cubit cubit, Step1State state) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await context.push<PickedLocation>(
      RouteNames.mapPicker,
      extra: {
        'initialLatitude': state.latitude,
        'initialLongitude': state.longitude,
        'initialAddress': state.pinnedAddress,
      },
    );

    if (!mounted || picked == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    cubit.processPickedLocation(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Step1Cubit, Step1State>(
      listenWhen: (previous, current) {
        return previous.ward != current.ward ||
            previous.street != current.street ||
            previous.city != current.city;
      },
      listener: (context, state) {
        final wardDisplay = _wardDisplayText(state);
        if (_wardCtrl.text != wardDisplay) _wardCtrl.text = wardDisplay;
        if (_streetCtrl.text != state.street) _streetCtrl.text = state.street;
      },
      builder: (context, state) {
        final cubit = context.read<Step1Cubit>();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuotaSection(cubit: cubit, state: state),
              AppSizes.gapH16,
              BasicInfoSection(
                cubit: cubit,
                state: state,
                nameController: _nameCtrl,
                minDurationController: _minDurationCtrl,
                descriptionController: _descCtrl,
                onUnfocusRequested: () => FocusScope.of(context).unfocus(),
              ),
              AppSizes.gapH16,
              LocationSection(
                cubit: cubit,
                state: state,
                wardController: _wardCtrl,
                streetController: _streetCtrl,
                coordinateText: _buildCoordinateText(state),
                onOpenMapPicker: () => _openMapPicker(cubit, state),
              ),
              AppSizes.gapH16,
              CostSection(
                cubit: cubit,
                state: state,
                electricityController: _elecCtrl,
                waterController: _waterCtrl,
                wifiController: _netCtrl,
                parkingController: _parkCtrl,
                serviceFeeController: _svcCtrl,
                serviceDescriptionController: _svcDescCtrl,
              ),
            ],
          ),
        );
      },
    );
  }

  String? _buildCoordinateText(Step1State state) {
    if (!state.isLocationPinned) return null;
    final latText = state.latitude!.toStringAsFixed(6);
    final lngText = state.longitude!.toStringAsFixed(6);
    return 'Đã ghim · $latText, $lngText';
  }
}
