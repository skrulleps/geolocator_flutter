import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'package:geolocator_app/di/di.dart';
import 'package:geolocator_app/presentation/controllers/tracking_controller.dart';
import 'package:geolocator_app/presentation/pages/tracking_page.dart';

Future<void> main() async {
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
      title: 'GPS Tracking MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TrackingPage(),
    );
  }
}
