import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../auth/blocs/authentication/auth_cubit.dart';
import '../../../../auth/blocs/authentication/auth_state.dart';
import '../../data/repositories/messages_repository.dart';
import '../../blocs/appointments_feed/appointments_feed_cubit.dart';
import '../../blocs/notifications_feed/notifications_feed_cubit.dart';
import '../widgets/appointments_panel.dart';
import '../widgets/conversations_panel.dart';
import '../widgets/messages_tabs.dart';
import '../widgets/messages_top_bar.dart';
import '../widgets/notifications_panel.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationCubit>().state;
    final userId = (authState as AuthenticationSuccessState).user.userId;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(150.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [MessagesTopBar(), MessagesTabs()],
            ),
          ),
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    AppointmentsFeedCubit(context.read<MessagesRepository>())
                      ..watch(userId),
              ),
              BlocProvider(
                create: (context) =>
                    NotificationsFeedCubit(context.read<MessagesRepository>())
                      ..watch(userId),
              ),
            ],
            child: const TabBarView(
              children: [
                ConversationsPanel(),
                NotificationsPanel(),
                AppointmentsPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
