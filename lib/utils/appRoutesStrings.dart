abstract class AppRoutes {
  AppRoutes._();
  static const splash = RoutesPath.splash;
  static const intro = RoutesPath.intro;
  static const login = RoutesPath.login;
  static const otp = RoutesPath.otp;
  static const locations = RoutesPath.locations;
  static const dashboard = RoutesPath.dashboard;
  static const search = RoutesPath.search;
  static const notification = RoutesPath.notification;
  static const offerDetails = RoutesPath.offerDetails;
  static const details = RoutesPath.details;
  static const personalinfo = RoutesPath.personalinfo;
  static const myOutlets = RoutesPath.myOutlets;
}

abstract class RoutesPath {
  static const splash = "/splash";
  static const intro = "/intro";
  static const login = "/login";
  static const otp = "/otp";
  static const locations = "/locations";
  static const dashboard = "/dashboard";
  static const search = "/search";
  static const notification = "/notification";
  static const offerDetails = "/offerDetails";
  static const details = "/details";
  static const personalinfo = "/personalinfo";
  static const myOutlets = "/myOutlets";
}
