// ignore_for_file: avoid-ignoring-return-values, not needed.
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/src/test_stub.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flutter_force_permission_test.mocks.dart';

@GenerateMocks([NavigatorState, TestStub, SharedPreferences])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final navigator = MockNavigatorState();
  when(navigator.push(any)).thenAnswer((realInvocation) => Future.value());

  test('Show disclosure page', () async {
    await _test();
  });

  test('Do not show disclosure page if permission already granted', () async {
    await _test(
      permissionStatus: PermissionStatus.granted,
      expectNavigatorPushed: false,
    );
  });

  test('Do not show disclosure page if already asked', () async {
    await _test(prefRequested: true, expectNavigatorPushed: false);
  });

  test('Do show disclosure page for required perms if asked', () async {
    await _test(prefRequested: true, permissionRequired: true);
  });
}

Future<void> _test({
  prefRequested = false,
  permissionStatus = PermissionStatus.denied,
  serviceStatus = ServiceStatus.enabled,
  permissionRequired = false,
  expectNavigatorPushed = true,
}) async {
  final navigator = MockNavigatorState();
  when(navigator.push(any)).thenAnswer((realInvocation) => Future.value());

  final prefs = MockSharedPreferences();
  when(prefs.getBool('Permission.location_requested'))
      .thenReturn(prefRequested);

  final testStub = MockTestStub();
  when(testStub.status(Permission.location))
      .thenAnswer((realInvocation) => Future.value(permissionStatus));
  when(testStub.serviceStatus(Permission.location))
      .thenAnswer((realInvocation) => Future.value(serviceStatus));
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
        required: permissionRequired,
      ),
    ],
  );

  final instance = FlutterForcePermission.stub(config, testStub);
  final result = await instance.show(navigator);

  if (expectNavigatorPushed) {
    verify(navigator.push(any));
  } else {
    verifyNever(navigator.push(any));
  }
  expect(result[Permission.location]!.status, permissionStatus);
  expect(result[Permission.location]!.serviceStatus, serviceStatus);
}
