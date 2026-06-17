import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../auth/blocs/authentication/auth_cubit.dart';
import '../../../auth/blocs/authentication/auth_state.dart';
import '../../../auth/data/models/user.dart';
import '../../property_tab/blocs/property_list/property_list_cubit.dart';
import '../../property_tab/blocs/property_list/property_list_state.dart';
import '../blocs/landlord_navigation_cubit.dart';
import 'widgets/landlord_header.dart';
import 'widgets/landlord_home_stats_mapper.dart';
import 'widgets/landlord_stats_grid.dart';
import 'widgets/rooms_section.dart';

class LandlordHomeTab extends StatelessWidget {
  const LandlordHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthenticationCubit, UserModel?>((cubit) {
      final state = cubit.state;
      return state is AuthenticationSuccessState ? state.user : null;
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LandlordHeader(
              name: user?.userName ?? '',
              avatarUrl: user?.avatarUrl,
            ),
            AppSizes.gapH16,
            BlocBuilder<PropertyListCubit, PropertyListState>(
              builder: (context, listState) {
                return LandlordStatsGrid(
                  stats: landlordHomeStats(listState),
                  landlordId: user?.userId,
                );
              },
            ),
            AppSizes.gapH20,
            RoomsSection(
              onSeeAll: () {
                context.read<LandlordNavigationCubit>().changeTab(
                  LandlordTab.posts,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
