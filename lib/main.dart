import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'package:geolocator_app/di/di.dart';
import 'package:geolocator_app/flavors.dart';
import 'package:geolocator_app/presentation/controllers/tracking_controller.dart';
import 'package:geolocator_app/presentation/pages/tracking_page.dart';

/// Default entry point (`flutter run` / `flutter build`).
///
/// Flavor-specific entry points call [bootstrap] with their own flavor.
Future<void> main() => bootstrap(Flavor.dev);

Future<void> bootstrap(Flavor flavor) async {
  F.appFlavor = flavor;

  WidgetsFlutterBinding.ensureInitialized();

  await initModules();

  Get.put<TrackingController>(GetIt.instance<TrackingController>());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: F.title,
      debugShowCheckedModeBanner: !F.isProduction,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TrackingPage(),
    );
  }
}
