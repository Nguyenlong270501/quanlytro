import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/route/app_routes.dart';
import 'core/route/go_router_refresh_stream.dart';
import 'core/services/fcm_service.dart';
import 'core/services/local_location_service.dart';
import 'features/admin/approvals/data/datasources/landlord_request/landlord_request_data_source_impl.dart';
import 'features/admin/approvals/data/repositories/landlord_request/landlord_request_repository_impl.dart';
import 'features/admin/approvals/data/datasources/admin_property_approvals/admin_property_approval_data_source_impl.dart';
import 'features/admin/approvals/data/repositories/admin_property_approvals/admin_property_approval_repository_impl.dart';
import 'features/admin/dashboard/data/datasources/admin_dashboard_data_source_impl.dart';
import 'features/admin/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'features/admin/dashboard/data/repositories/admin_dashboard_repository_impl.dart';
import 'features/admin/user_management/data/datasources/admin_user_management_remote_data_source_impl.dart';
import 'features/admin/user_management/data/repositories/admin_user_management_repository.dart';
import 'features/admin/user_management/data/repositories/admin_user_management_repository_impl.dart';
import 'features/auth/blocs/authentication/auth_cubit.dart';
import 'features/auth/blocs/authentication/auth_state.dart';
import 'features/auth/data/datasources/firebase_auth_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/landlord/create_property/data/datasources/create_property_data_source_impl.dart';
import 'features/landlord/create_property/data/repositories/create_property_repository.dart';
import 'features/landlord/create_property/data/repositories/create_property_repository_impl.dart';
import 'features/landlord/appointment/data/datasources/appointment_remote_data_source.dart';
import 'features/landlord/appointment/data/datasources/firebase_appointment_remote_data_source.dart';
import 'features/landlord/appointment/data/repositories/appointment_repository.dart';
import 'features/landlord/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/landlord/messages_tab/data/datasources/firebase_messages_remote_data_source.dart';
import 'features/landlord/messages_tab/data/datasources/messages_remote_data_source.dart';
import 'features/landlord/messages_tab/data/repositories/messages_repository.dart';
import 'features/landlord/messages_tab/data/repositories/messages_repository_impl.dart';
import 'features/landlord/property_tab/blocs/property_list/property_list_cubit.dart';
import 'features/landlord/property_tab/data/datasources/property_remote_data_source_impl.dart';
import 'features/landlord/property_tab/data/datasources/property_review_remote_data_source_impl.dart';
import 'features/landlord/property_tab/data/repositories/property_repository.dart';
import 'features/landlord/property_tab/data/repositories/property_repository_impl.dart';
import 'features/profile/data/repositories/profile_image_repository.dart';
import 'features/profile/data/repositories/profile_image_repository_impl.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalLocationService().loadData();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FCMService().initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(FirebaseAuthDataSourceImpl()),
        ),
        RepositoryProvider<ProfileImageRepository>(
          create: (context) => ProfileImageRepositoryImpl(),
        ),
        RepositoryProvider<LandlordRequestRepositoryImpl>(
          create: (context) =>
              LandlordRequestRepositoryImpl(LandlordRequestDataSourceImpl()),
        ),
        RepositoryProvider<CreatePropertyRepository>(
          create: (context) =>
              CreatePropertyRepositoryImpl(CreatePropertyDataSourceImpl()),
        ),
        RepositoryProvider<PropertyRepository>(
          create: (context) => PropertyRepositoryImpl(
            remoteDataSource: PropertyRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
            reviewRemoteDataSource: PropertyReviewRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
        RepositoryProvider<AdminPropertyApprovalRepositoryImpl>(
          create: (context) => AdminPropertyApprovalRepositoryImpl(
            AdminPropertyApprovalDataSourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
        RepositoryProvider<AdminDashboardRepository>(
          create: (context) => AdminDashboardRepositoryImpl(
            AdminDashboardDataSourceImpl(firestore: FirebaseFirestore.instance),
          ),
        ),
        RepositoryProvider<AdminUserManagementRepository>(
          create: (context) => AdminUserManagementRepositoryImpl(
            AdminUserManagementRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
        RepositoryProvider<MessagesRemoteDataSource>(
          create: (context) => FirebaseMessagesRemoteDataSource(),
        ),
        RepositoryProvider<MessagesRepository>(
          create: (context) =>
              MessagesRepositoryImpl(context.read<MessagesRemoteDataSource>()),
        ),
        RepositoryProvider<AppointmentRemoteDataSource>(
          create: (context) => FirebaseAppointmentRemoteDataSource(
            firestore: FirebaseFirestore.instance,
          ),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (context) => AppointmentRepositoryImpl(
            remoteDataSource: context.read<AppointmentRemoteDataSource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationCubit(
              authRepository: context.read<AuthRepositoryImpl>(),
            ),
          ),
          BlocProvider(
            create: (context) => PropertyListCubit(
              repository: context.read<PropertyRepository>(),
            ),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (BuildContext context, Widget? child) {
            return const _AppRouterHost();
          },
        ),
      ),
    );
  }
}

class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost> {
  GoRouterRefreshStream? _refresh;
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router != null) {
      return;
    }
    final auth = context.read<AuthenticationCubit>();
    _refresh = GoRouterRefreshStream(auth.stream);
    _router = AppRoutes(refreshListenable: _refresh!).router;
    setState(() {});
  }

  @override
  void dispose() {
    _refresh?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listenWhen: (previous, current) => current is UnAuthenticationState,
      listener: (context, state) {
        context.read<PropertyListCubit>().resetAfterLogout();
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'Quản lý trọ',
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child,
          );
        },
      ),
    );
  }
}
