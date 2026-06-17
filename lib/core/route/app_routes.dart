import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/blocs/authentication/auth_cubit.dart';
import '../../features/auth/blocs/authentication/auth_state.dart';
import '../../features/auth/blocs/forget_password_form/forget_password_form_cubit.dart';
import '../../features/auth/blocs/sign_form/signin_form_cubit.dart';
import '../../features/auth/data/models/user.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/screens/forget_password/forget_password_screen.dart';
import '../../features/auth/presentation/screens/signin/signin_screen.dart';
import '../../features/admin/approvals/blocs/landlord_request_detail/landlord_request_detail_cubit.dart';
import '../../features/admin/approvals/data/models/admin_property_approval_detail_args.dart';
import '../../features/admin/approvals/data/models/landlord_request.dart';
import '../../features/admin/approvals/data/repositories/landlord_request/landlord_request_repository_impl.dart';
import '../../features/admin/home/presentation/admin_layout_screen.dart';
import '../../features/admin/approvals/presentation/landlord_request_detail/landlord_request_detail_screen.dart';
import '../../features/admin/approvals/presentation/property_request_detail/admin_property_approval_detail_screen.dart';
import '../../features/admin/user_management/blocs/admin_user_detail/admin_user_detail_cubit.dart';
import '../../features/admin/user_management/data/repositories/admin_user_management_repository.dart';
import '../../features/admin/user_management/presentation/admin_user_details.dart/admin_user_detail_screen.dart';
import '../../features/landlord/appointment/data/repositories/appointment_repository.dart';
import '../../features/landlord/appointment/data/models/appointment_model.dart';
import '../../features/landlord/appointment/blocs/landlord_appointment_detail/landlord_appointment_detail_cubit.dart';
import '../../features/landlord/appointment/presentation/screens/landlord_appointment_detail_screen.dart';
import '../../features/landlord/create_property/data/models/property_model.dart';
import '../../features/landlord/create_property/data/models/room_model.dart';
import '../../features/landlord/create_property/presentation/room_detail/room_detail_screen.dart';
import '../../features/landlord/create_property/presentation/steps/step4/models/room_preview_screen_args.dart';
import '../../features/landlord/create_property/presentation/steps/step4/room_preview_screen.dart';
import '../../features/landlord/create_property/presentation/screens/edit_property_screen.dart';
import '../../features/landlord/create_property/presentation/steps/step1/widgets/map_location_picker_screen.dart';
import '../../features/landlord/home_tab/blocs/landlord_navigation_cubit.dart';
import '../../features/landlord/landlord_layout/landlord_layout_screen.dart';
import '../../features/landlord/property_tab/blocs/property_details_reviews/property_details_reviews_cubit.dart';
import '../../features/landlord/property_tab/data/repositories/property_repository.dart';
import '../../features/landlord/property_tab/presentation/property_details/screens/property_details.dart';
import '../../features/profile/blocs/change_password_form/change_password_form_cubit.dart';
import '../../features/profile/blocs/landlord_request_view/landlord_request_view_cubit.dart';
import '../../features/profile/blocs/profile_edit/profile_edit_cubit.dart';
import '../../features/profile/blocs/profile_image.dart/profile_image_cubit.dart';
import '../../features/profile/data/repositories/profile_image_repository.dart';
import '../../features/profile/presentation/screens/change_password/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/landlord_request_view/landlord_request_view_screen.dart';
import '../../features/profile/presentation/screens/security_password/security_password_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/app_enums.dart';

final appRouteObserver = RouteObserver<ModalRoute<dynamic>>();

class RouteNames {
  static const String loginpage = '/login';
  static const String homepage = '/homepage';
  static const String forgetpasswordpage = '/forget-password';
  static const String landlordRequestDetail = '/landlord-request';
  static const String landlordRequestPage = '/my-landlord-request';
  static const String mapPicker = '/map_picker';
  static const String propertyDetail = '/property-detail';
  static const String editProperty = '/edit-property';
  static const String roomDetail = '/room-detail';
  static const String roomPreview = '/room-preview';
  static const String adminPropertyApprovalDetail = '/admin-property-approval';
  static const String editProfilePage = '/edit-profile';
  static const String securityPasswordPage = '/security-password';
  static const String changePasswordPage = '/change-password';
  static const String landlordAppointmentDetail = '/landlord-appointment-detail';
  static const String adminUserDetail = '/admin-user-detail';
}

String? _authRedirect(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthenticationCubit>().state;
  final loggedIn = authState is AuthenticationSuccessState;
  final loc = state.matchedLocation;

  final isPublic = loc == '/' ||
      loc == RouteNames.loginpage ||
      loc == RouteNames.forgetpasswordpage;

  if (isPublic) {
    if (loggedIn && loc == RouteNames.loginpage) {
      return RouteNames.homepage;
    }
    return null;
  }

  if (!loggedIn) {
    return RouteNames.loginpage;
  }
  return null;
}

class AppRoutes {
  AppRoutes({required Listenable refreshListenable})
    : router = GoRouter(
        navigatorKey: rootNavigatorKey,
        observers: [appRouteObserver],
        refreshListenable: refreshListenable,
        redirect: _authRedirect,
        routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.loginpage,
        name: RouteNames.loginpage,
        builder: (context, state) {
          return BlocProvider<SignInFormCubit>(
            create: (context) => SignInFormCubit(),
            child: const SignInScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.forgetpasswordpage,
        name: RouteNames.forgetpasswordpage,
        builder: (context, state) {
          return BlocProvider<ForgetPasswordFormCubit>(
            create: (context) => ForgetPasswordFormCubit(),
            child: const ForgetPasswordScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.homepage,
        name: RouteNames.homepage,
        builder: (context, state) {
          final authState = context.read<AuthenticationCubit>().state;

          if (authState is AuthenticationLoadingState ||
              authState is AuthenticationInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authState is AuthenticationSuccessState) {
            final user = authState.user;

            if (user.role == UserRole.admin) {
              return const AdminLayoutScreen();
            } else if (user.role == UserRole.landlord) {
              LandlordTab? initialTab;
              final tabQuery = state.uri.queryParameters['tab'];
              if (tabQuery == 'posts') {
                initialTab = LandlordTab.posts;
              }
              return LandlordLayoutScreen(initialTab: initialTab);
            }
          }
          return const SignInScreen();
        },
      ),

      GoRoute(
        path: '${RouteNames.landlordRequestDetail}/:userId',
        name: RouteNames.landlordRequestDetail,
        builder: (context, state) {
          final request = state.extra as LandlordRequest?;
          if (request == null) {
            return const Scaffold(
              body: Center(child: Text('Không tìm thấy hồ sơ')),
            );
          }
          return BlocProvider<LandlordRequestDetailCubit>(
            create: (ctx) => LandlordRequestDetailCubit(
              repository: ctx.read<LandlordRequestRepositoryImpl>(),
            ),
            child: LandlordRequestDetailScreen(request: request),
          );
        },
      ),

      GoRoute(
        path: RouteNames.landlordRequestPage,
        name: RouteNames.landlordRequestPage,
        builder: (context, state) {
          final authState = context.read<AuthenticationCubit>().state;
          if (authState is! AuthenticationSuccessState) {
            return const Scaffold(
              body: Center(child: Text('Vui lòng đăng nhập để xem đơn đăng ký.')),
            );
          }
          final userId = authState.user.userId;
          return BlocProvider<LandlordRequestViewCubit>(
            key: ValueKey<String>(userId),
            create: (ctx) => LandlordRequestViewCubit(
              repository: ctx.read<LandlordRequestRepositoryImpl>(),
              userId: userId,
            ),
            child: const LandlordRequestViewScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.mapPicker,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MapLocationPickerScreen(
            initialLatitude: args?['initialLatitude'] as double?,
            initialLongitude: args?['initialLongitude'] as double?,
            initialAddress: args?['initialAddress'] as String?,
          );
        },
      ),

      GoRoute(
        path: RouteNames.propertyDetail,
        builder: (context, state) {
          final initialProperty = state.extra as PropertyModel?;
          if (initialProperty == null) {
            return const Scaffold(
              body: Center(child: Text('Không có dữ liệu nhà trọ')),
            );
          }
          return BlocProvider(
            create: (ctx) => PropertyDetailsReviewsCubit(
              repository: ctx.read<PropertyRepository>(),
            )..watch(initialProperty.propertyId),
            child: PropertyDetailsScreen(property: initialProperty),
          );
        },
      ),

      GoRoute(
        path: RouteNames.editProperty,
        builder: (context, state) {
          final initialProperty = state.extra as PropertyModel?;
          if (initialProperty == null) {
            return const Scaffold(
              body: Center(child: Text('Không có dữ liệu nhà trọ')),
            );
          }
          return EditPropertyScreen(property: initialProperty);
        },
      ),

      GoRoute(
        path: RouteNames.roomDetail,
        builder: (context, state) {
          final initialRoom = state.extra as RoomModel?;
          return RoomDetailScreen(initialRoom: initialRoom);
        },
      ),

      GoRoute(
        path: RouteNames.roomPreview,
        builder: (context, state) {
          final args = state.extra as RoomPreviewScreenArgs?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Không có dữ liệu phòng')),
            );
          }
          return RoomPreviewScreen(args: args);
        },
      ),

      GoRoute(
        path: RouteNames.landlordAppointmentDetail,
        name: RouteNames.landlordAppointmentDetail,
        builder: (context, state) {
          final appointment = state.extra as AppointmentModel?;
          if (appointment == null) {
            return const Scaffold(
              body: Center(child: Text('Không có dữ liệu lịch hẹn')),
            );
          }
          return BlocProvider(
            create: (ctx) => LandlordAppointmentDetailCubit(
              repository: ctx.read<AppointmentRepository>(),
              appointment: appointment,
            ),
            child: const LandlordAppointmentDetailScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteNames.adminPropertyApprovalDetail,
        builder: (context, state) {
          final extra = state.extra;
          PropertyModel? property;

          if (extra is AdminPropertyApprovalDetailArgs) {
            property = extra.property;
          } else if (extra is PropertyModel) {
            property = extra;
          }

          if (property == null) {
            return const Scaffold(
              body: Center(child: Text('Không tìm thấy bài đăng')),
            );
          }
          return AdminPropertyApprovalDetailScreen(property: property);
        },
      ),

      GoRoute(
        path: RouteNames.editProfilePage,
        name: RouteNames.editProfilePage,
        builder: (context, state) {
          final user = state.extra is UserModel
              ? state.extra as UserModel
              : null;
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileImageCubit>(
                create: (context) => ProfileImageCubit(
                  context.read<ProfileImageRepository>(),
                  initialAvatarUrl: user?.avatarUrl ?? '',
                ),
              ),
              BlocProvider<ProfileEditCubit>(
                create: (context) => ProfileEditCubit(
                  initialName: user?.userName ?? '',
                  initialPhone: user?.phoneNumber ?? '',
                  repository: context.read<ProfileImageRepository>(),
                ),
              ),
            ],
            child: EditProfileScreen(user: user),
          );
        },
      ),

      GoRoute(
        path: RouteNames.securityPasswordPage,
        name: RouteNames.securityPasswordPage,
        builder: (context, state) => const SecurityPasswordScreen(),
      ),

      GoRoute(
        path: RouteNames.changePasswordPage,
        name: RouteNames.changePasswordPage,
        builder: (context, state) => BlocProvider<ChangePasswordFormCubit>(
          create: (context) =>
              ChangePasswordFormCubit(context.read<AuthRepositoryImpl>()),
          child: const ChangePasswordScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.adminUserDetail,
        name: RouteNames.adminUserDetail,
        builder: (context, state) {
          final user = state.extra is UserModel
              ? state.extra as UserModel
              : null;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('Không tìm thấy người dùng')),
            );
          }
          return BlocProvider<AdminUserDetailCubit>(
            create: (context) => AdminUserDetailCubit(
              user: user,
              repository: context.read<AdminUserManagementRepository>(),
            ),
            child: const AdminUserDetailScreen(),
          );
        },
      ),
    ],
  );

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  final GoRouter router;
}
