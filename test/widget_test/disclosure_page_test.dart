// ignore_for_file: avoid-ignoring-return-values, not needed.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/forced_permission_dialog_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_required_option.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/test_stub.dart';
import 'package:flutter_force_permission/src/views/disclosure_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'disclosure_page_test.mocks.dart';

@GenerateMocks([TestStub, SharedPreferences])
void main() {
  final prefs = MockSharedPreferences();
  when(prefs.getBool('Permission.location_requested')).thenReturn(false);
  when(prefs.setBool('Permission.location_requested', any))
      .thenAnswer((realInvocation) => Future.value(true));
  when(prefs.setBool('Permission.phone_requested', any))
      .thenAnswer((realInvocation) => Future.value(true));

  testWidgets('Regular permission show dialog', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.request(Permission.phone))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));
    when(testStub.status(Permission.phone))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));

    await _test(
      tester,
      testStub,
      config: FlutterForcePermissionConfig(
        title: 'Title',
        confirmText: 'Confirm',
        permissionItemConfigs: [
          PermissionItemConfig(
            permissions: [
              Permission.phone,
            ],
            itemText: PermissionItemText(
              header: 'Foreground location',
              rationaleText: 'Rationale',
            ),
          ),
        ],
      ),
      verification: (resumed) {
        verify(testStub.request(Permission.phone));
        verify(prefs.setBool('Permission.phone_requested', true));
      },
    );
  });

  testWidgets('Required permission granted', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.request(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.status(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));

    await _test(
      tester,
      testStub,
      config: FlutterForcePermissionConfig(
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
              forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                title: 'Location required',
                text: 'Location needed for proper operation',
                buttonText: 'Settings',
              ),
            ),
            required: PermissionRequiredOption.required,
          ),
        ],
      ),
      verification: (resumed) {
        verify(testStub.request(Permission.location));
        verify(prefs.setBool('Permission.location_requested', true));
      },
    );
  });

  testWidgets('Ask permission', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.request(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.status(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.openAppSettings())
        .thenAnswer((realInvocation) => Future.value());

    await _test(
      tester,
      testStub,
      config: FlutterForcePermissionConfig(
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
              forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                title: 'Location required',
                text: 'Location needed for proper operation',
                cancelText: 'Cancel',
                buttonText: 'Settings',
              ),
            ),
            required: PermissionRequiredOption.ask,
          ),
        ],
      ),
      verification: (resumed) async {
        verify(testStub.request(Permission.location));

        expect(find.text('Location required'), findsOneWidget);
        expect(
          find.text('Location needed for proper operation'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        await tester.tap(find.text('Cancel'));

        resumed.add(true);
        await tester.pump();

        expect(find.text('Settings'), findsNothing);
      },
    );
  });

  testWidgets('Required permission denied', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.request(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.status(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
    when(testStub.openAppSettings())
        .thenAnswer((realInvocation) => Future.value());

    await _test(
      tester,
      testStub,
      config: FlutterForcePermissionConfig(
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
              forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                title: 'Location required',
                text: 'Location needed for proper operation',
                buttonText: 'Settings',
              ),
            ),
            required: PermissionRequiredOption.required,
          ),
        ],
      ),
      verification: (resumed) async {
        verify(testStub.request(Permission.location));

        expect(find.text('Location required'), findsOneWidget);
        expect(
          find.text('Location needed for proper operation'),
          findsOneWidget,
        );
        expect(find.text('Settings'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pump();

        verify(testStub.openAppSettings());

        resumed.add(true);
        await tester.pump();

        expect(find.text('Settings'), findsOneWidget);
        await tester.tap(find.text('Settings'));

        when(testStub.status(Permission.location)).thenAnswer(
          (realInvocation) => Future.value(PermissionStatus.granted),
        );
        resumed.add(true);
        await tester.pump();

        expect(find.text('Settings'), findsNothing);
      },
    );
  });

  // If permissions are permanently denied, permission request will not show.
  testWidgets('Required permission permanently denied', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.status(Permission.location)).thenAnswer(
      (realInvocation) => Future.value(PermissionStatus.permanentlyDenied),
    );
    when(testStub.openAppSettings())
        .thenAnswer((realInvocation) => Future.value());

    await _test(
      tester,
      testStub,
      config: FlutterForcePermissionConfig(
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
              forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                title: 'Location required',
                text: 'Location needed for proper operation',
                buttonText: 'Settings',
              ),
            ),
            required: PermissionRequiredOption.required,
          ),
        ],
      ),
      verification: (resumed) async {
        expect(find.text('Location required'), findsOneWidget);
        expect(find.text('Location needed for proper operation'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pump();

        verify(testStub.openAppSettings());

        resumed.add(true);
        await tester.pump();

        expect(find.text('Settings'), findsOneWidget);
        await tester.tap(find.text('Settings'));

        when(testStub.status(Permission.location))
            .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));
        resumed.add(true);
        await tester.pump();

        expect(find.text('Settings'), findsNothing);
      },
    );
  });

  testWidgets('Required service permission', (tester) async {
    final testStub = MockTestStub();
    when(testStub.getSharedPreference())
        .thenAnswer((realInvocation) => Future.value(prefs));
    when(testStub.request(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));
    when(testStub.status(Permission.location))
        .thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));
    when(testStub.serviceStatus(Permission.location))
        .thenAnswer((realInvocation) => Future.value(ServiceStatus.disabled));

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
            forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
              title: 'Location required',
              text: 'Location needed for proper operation',
              buttonText: 'Location Settings',
            ),
          ),
          serviceItemText: PermissionItemText(
            header: 'GPS',
            rationaleText: 'GPS Rationale',
            forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
              title: 'GPS required',
              text: 'GPS needed for proper operation',
              buttonText: 'GPS Settings',
            ),
          ),
          required: PermissionRequiredOption.required,
        ),
      ],
    );
    final status = <Permission, PermissionServiceStatus>{
      Permission.location: PermissionServiceStatus(
        status: PermissionStatus.granted,
        requested: false,
        serviceStatus: ServiceStatus.disabled,
      ),
    };
    final StreamController<bool> resumed = StreamController.broadcast()
      ..add(true);

    await tester.pumpWidget(
      MaterialApp(
        home: DisclosurePage.stub(
          permissionConfig: config,
          permissionStatuses: status,
          service: testStub,
          resumed: resumed,
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Foreground location'), findsNothing);
    expect(find.text('Rationale'), findsNothing);
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('GPS Rationale'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(find.text('GPS required'), findsOneWidget);
    expect(find.text('GPS needed for proper operation'), findsOneWidget);
    expect(find.text('GPS Settings'), findsOneWidget);

    await tester.tap(find.text('GPS Settings'));
    await tester.pump();

    verify(testStub.openLocationSettings());

    resumed.add(true);
    await tester.pump();

    expect(find.text('GPS Settings'), findsOneWidget);
    await tester.tap(find.text('GPS Settings'));

    when(testStub.serviceStatus(Permission.location))
        .thenAnswer((realInvocation) => Future.value(ServiceStatus.enabled));
    resumed.add(true);
    await tester.pump();

    expect(find.text('GPS Settings'), findsNothing);

    await resumed.close();
  });

  testWidgets(
    'Required permission denied with custom dialog callback `showDialogCallback`',
    (tester) async {
      final testStub = MockTestStub();
      when(testStub.getSharedPreference())
          .thenAnswer((realInvocation) => Future.value(prefs));
      when(testStub.request(Permission.location)).thenAnswer(
        (realInvocation) => Future.value(PermissionStatus.denied),
      );
      when(testStub.status(Permission.location)).thenAnswer(
        (realInvocation) => Future.value(PermissionStatus.denied),
      );
      when(testStub.openAppSettings())
          .thenAnswer((realInvocation) => Future.value());

      await _test(
        tester,
        testStub,
        config: FlutterForcePermissionConfig(
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
                forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                  title: 'Location required',
                  text: 'Location needed for proper operation',
                  buttonText: 'Settings',
                ),
              ),
              required: PermissionRequiredOption.required,
            ),
          ],
          showDialogCallback: (context, option, config, callback) {
            callback();
          },
        ),
        verification: (resumed) async {
          verify(testStub.request(Permission.location));
          when(testStub.status(Permission.location)).thenAnswer(
                (realInvocation) => Future.value(PermissionStatus.granted),
          );
          resumed.add(true);
          await tester.pump();

          verify(testStub.openAppSettings());
          expect(find.text('Settings'), findsNothing);

          await resumed.close();
        },
      );
    },
  );
}

Future<void> _test(
  WidgetTester tester,
  TestStub testStub, {
  required FlutterForcePermissionConfig config,
  required Function(StreamController<bool> resumed) verification,
}) async {
  final status = <Permission, PermissionServiceStatus>{
    Permission.phone: PermissionServiceStatus(
      status: PermissionStatus.denied,
      requested: false,
      serviceStatus: ServiceStatus.enabled,
    ),
  };
  final StreamController<bool> resumed = StreamController.broadcast()
    ..add(true);

  await tester.pumpWidget(
    MaterialApp(
      home: DisclosurePage.stub(
        permissionConfig: config,
        permissionStatuses: status,
        service: testStub,
        resumed: resumed,
      ),
    ),
  );

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Foreground location'), findsOneWidget);
  expect(find.text('Rationale'), findsOneWidget);
  expect(find.text('Confirm'), findsOneWidget);

  await tester.tap(find.text('Confirm'));
  await tester.pump();

  await verification(resumed);

  await resumed.close();
}
