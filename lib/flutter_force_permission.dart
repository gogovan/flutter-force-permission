library flutter_force_permission;

import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/src/disclosure_page.dart';
import 'package:permission_handler/permission_handler.dart';

/// Flutter Force Permission
///
/// Show permission disclosure page and allows required permissions before user can proceed.
class FlutterForcePermission {
  /// Constructor. Pass configuration here. Refer to [FlutterForcePermissionConfig] for details.
  FlutterForcePermission(this.config);

  /// Configuration. Refer to [FlutterForcePermissionConfig] for details.
  final FlutterForcePermissionConfig config;

  /// Show disclosure page.
  ///
  /// This will show the disclosure page according to the provided configuration, and handles requesting permissions.
  /// Returns a map of Permission and their status after requesting the permissions. Refer to [permission_handler](https://pub.dev/documentation/permission_handler_platform_interface/latest/permission_handler_platform_interface/PermissionStatus.html) for return values.
  /// Only permissions specified in the configuration will be included in the return value.
  Future<Map<Permission, PermissionStatus>> show(BuildContext context) async {
    // Obtain navigator before any await call to avoid storing BuildContext across async gaps.
    // https://stackoverflow.com/a/69512692
    final navigator = Navigator.of(context);

    // Check for permissions.
    final permissionStatuses = await getPermissionStatuses();

    if (permissionStatuses.values.every((element) => element.isGranted)) {
      // TODO(peter): check if soft permissions are asked.
      // All permissions granted, no need to show disclosure page.
      return permissionStatuses;
    }

    // Navigate to disclosure page.
    // ignore: avoid-ignoring-return-values, not needed.
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => DisclosurePage(forcePermission: this),
      ),
    );

    return getPermissionStatuses();
  }

  /// Get all permission statuses.
  ///
  /// Only permissions specified in the configuration will be queried and returned.
  /// Refer to [permission_handler](https://pub.dev/documentation/permission_handler_platform_interface/latest/permission_handler_platform_interface/PermissionStatus.html) for return values.
  Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    final Map<Permission, PermissionStatus> result = {};
    for (final List<Permission> perms
        in config.permissionItemConfigs.map((e) => e.permissions)) {
      for (final Permission perm in perms) {
        final status = await perm.status;
        result[perm] = status;
      }
    }

    return result;
  }
}
