import 'package:get/get.dart';
import 'package:kupan_business/screens/login_screen.dart';
import '../screens/details_screen.dart';
import '../screens/otp_screen.dart';
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
      name: AppRoutes.details,
      page: () => const DetailsScreen(),
      binding: null,
    ),
  ];
}
