import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3rd party libraries (and some 1st party ones) relies on static methods which are unmockable and hence untestable.
/// This service wraps those methods so that it can be tested.
/// See https://github.com/Baseflow/flutter-permission-handler/issues/262 for details.
class TestStub {
  const TestStub();

  Future<PermissionStatus> status(Permission permission) => permission.status;

  Future<ServiceStatus> serviceStatus(PermissionWithService permission) =>
      permission.serviceStatus;

  Future<void> openAppSettings() => AppSettings.openAppSettings();

  Future<void> openLocationSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.location);

  Future<PermissionStatus> request(Permission permission) =>
      permission.request();

  Future<SharedPreferences> getSharedPreference() =>
      SharedPreferences.getInstance();

  NavigatorState getNavigator(BuildContext context) => Navigator.of(context);
}
