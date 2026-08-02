import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kupan_business/services/api_client.dart';
import 'package:kupan_business/services/push_service.dart';
import 'package:kupan_business/services/secure_store.dart';
import 'package:kupan_business/utils/appRoutesNavigation.dart';
import 'package:kupan_business/utils/appRoutesStrings.dart';

import 'firebase_options.dart';

/// Reads the SSL-pinning kill-switch from Firebase Remote Config.
///
/// IMPORTANT: Remote Config uses Firebase's OWN network stack (Google infra),
/// NOT the pinned [ApiClient] — so this flag is reachable even if a bad pin is
/// blocking the Vercel backend. Defaults to `true` (pin enabled) when the fetch
/// hasn't completed (first launch / no network); the runtime fail-open valve in
/// [ApiClient] prevents a bad rotation from bricking such a launch.
Future<bool> _readSslPinningFlag() async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setDefaults(const {'ssl_pinning_enabled': true});
    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 5),
      minimumFetchInterval: const Duration(hours: 6),
    ));
    await rc.fetchAndActivate();
    return rc.getBool('ssl_pinning_enabled');
  } catch (_) {
    return true; // secure-by-default; fail-open valve is the anti-brick backstop
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  // One-time migration of secrets (token/userId/userName) into encrypted storage.
  await SecureStore.i.init();

  // Centralised HTTP client with TLS pinning (kill-switch via Remote Config).
  await ApiClient.instance.init(
    pinningEnabled: await _readSslPinningFlag(),
    onFailOpen: () => FirebaseRemoteConfig.instance.fetchAndActivate(),
    onUnauthorized: () async {
      // Fires only after repeated 401s (e.g. token invalidated by a JWT_SECRET
      // rotation). Guard the loop: never yank a user already on the login screen.
      if (Get.currentRoute == AppRoutes.login) return;
      await SecureStore.i.clearSession();
      Get.offAllNamed(AppRoutes.login);
    },
  );

  // Initialize push notifications — token is saved to backend in DashboardController.onInit
  await PushService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPage.initial,
      getPages: AppPage.routes,
    );
  }
}
