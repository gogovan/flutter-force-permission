// ignore_for_file: avoid-ignoring-return-values, not needed.
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flutter_force_permission_test.mocks.dart';

@GenerateMocks([NavigatorState, TestStub, SharedPreferences])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('Show disclosure page', () async {
    final navigator = MockNavigatorState();
    when(navigator.push(any)).thenAnswer((realInvocation) => Future.value());

    final prefs = MockSharedPreferences();
    when(prefs.getBool('Permission.location_requested')).thenReturn(false);
    when(prefs.setBool('Permission.location_requested', any))
        .thenAnswer((realInvocation) => Future.value(true));

    final testStub = MockTestStub();
    when(testStub.status(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.serviceStatus(Permission.location))
        .thenAnswer((realInvocation) => Future.value(ServiceStatus.enabled));
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));

    final config = FlutterForcePermissionConfig(
      title: 'Title',
      confirmText: 'Confirm',
      permissionItemConfigs: [
        PermissionItemConfig(
          permissions: [
            Permission.location,
          ],
          itemText: PermissionItemText(
            header: 'Foreground location',
            rationaleText: 'Rationale',
          ),
        ),
      ],
    );

    final instance = FlutterForcePermission.stub(config, testStub);
    final result = await instance.show(navigator);

    verify(navigator.push(any));
    expect(result[Permission.location]!.status, PermissionStatus.denied);
    expect(result[Permission.location]!.serviceStatus, ServiceStatus.enabled);
  });
}
