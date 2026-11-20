import 'package:geolocator_app/di/modules/db_module.dart';
import 'package:geolocator_app/di/modules/locator_module.dart';

Future<void> initModules() async {
  await dbModule();
  await locatorModule();
}
