library flutter_force_permission;

import 'package:flutter_force_permission/flutter_force_permission_config.dart';
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
  /// Returns a map of Permission and their status, using permission_handler interfaces.
  /// Only requested permissions will be included in the return value.
  Future<Map<Permission, PermissionStatus>> show() async {
    final permissionStatuses = await _getPermissionStatuses();

    return permissionStatuses;
  }

  Future<Map<Permission, PermissionStatus>> _getPermissionStatuses() async {
    final Map<Permission, PermissionStatus> result = {};
    for (final List<Permission> perms in config.permissionItemConfigs.map((e) => e.permission)) {
      for (final Permission perm in perms) {
        final status = await perm.status;
        result[perm] = status;
      }
    }

    return result;
  }
}
