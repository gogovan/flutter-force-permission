import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/disclosure_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  testWidgets('Check disclosure page items', (tester) async {
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
    final status = <Permission, PermissionServiceStatus>{
      Permission.location: PermissionServiceStatus(
        status: PermissionStatus.denied,
        serviceStatus: ServiceStatus.enabled,
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        home: DisclosurePage(
          permissionConfig: config,
          permissionStatuses: status,
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Foreground location'), findsOneWidget);
    expect(find.text('Rationale'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });
}
