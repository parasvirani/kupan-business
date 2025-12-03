import 'package:get/get.dart';
import 'package:kupan_business/screens/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/my_outlets_screen.dart';
import '../screens/details/details_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/personal_info.dart';
import '../screens/splash_screen.dart';
import 'appRoutesStrings.dart';

class AppPage {
  static String initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: null,
    ),

    GetPage(
      preventDuplicates: true,
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: null,
    ),
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: null,
    ),
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.personalinfo,
      page: () =>  UserDetailsScreen(),
      binding: null,
    ),
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.details,
      page: () => const DetailsScreen(),
      binding: null,
    ),
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: null,
    ),
    GetPage(
      preventDuplicates: true,
      name: AppRoutes.myOutlets,
      page: () => const MyOutletsScreen(),
      binding: null,
    ),

  ];
}
