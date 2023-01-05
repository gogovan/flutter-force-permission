import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3rd party libraries relies on static methods which are unmockable and hence untestable.
/// This service wraps those methods so that it can be tested.
/// https://github.com/Baseflow/flutter-permission-handler/issues/262
class TestStub {
  const TestStub();

  Future<PermissionStatus> status(Permission permission) => permission.status;

  Future<ServiceStatus> serviceStatus(PermissionWithService permission) =>
      permission.serviceStatus;

  Future<void> openAppSettings() => AppSettings.openAppSettings();

  Future<void> openLocationSettings() => AppSettings.openLocationSettings();

  Future<PermissionStatus> request(Permission permission) =>
      permission.request();

  Future<SharedPreferences> getSharedPreference() =>
      SharedPreferences.getInstance();
}
