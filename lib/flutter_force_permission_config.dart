library flutter_force_permission;

import 'package:flutter_force_permission/permission_item_config.dart';

/// Configuration for Flutter Force Permission.
class FlutterForcePermissionConfig {
  FlutterForcePermissionConfig({
    required this.title,
    required this.confirmText,
    required this.permissionItemConfigs,
  });

  /// The title for the disclosure page.
  final String title;

  /// The text for the confirmation button.
  final String confirmText;

  /// Configurations for requested permissions.
  ///
  /// The list ordering dictates the order of the permissions requested in the disclosure page and the order the OS shows the permission dialogs.
  /// See [PermissionItemConfig] for details.
  final List<PermissionItemConfig> permissionItemConfigs;
}
