library flutter_force_permission;

import 'package:flutter/widgets.dart';
import 'package:flutter_force_permission/forced_permission_dialog_config.dart';
import 'package:permission_handler/permission_handler.dart';

/// Configuration for each item in the disclosure page and requested permissions.
class PermissionItemConfig {
  PermissionItemConfig({
    required this.permissions,
    required this.header,
    required this.rationaleText,
    this.icon,
    this.required = false,
    this.forcedPermissionDialogConfig,
  });

  /// The Permission to request.
  ///
  /// If multiple permissions are provided, this item will cover all of them.
  /// Refer to the constants of the Permission in [permission_handler plugin](https://pub.dev/documentation/permission_handler_platform_interface/latest/permission_handler_platform_interface/Permission-class.html).
  /// Currently, only supports location, locationAlways, locationWhenInUse, notification, activityRecognition, sensors.
  final List<Permission> permissions;

  /// Title for the permission item.
  final String header;

  /// The Icon for the permission item.
  ///
  /// If omitted, a Material Icon appropriate for the permission colored with Primary color of the current theme will be used.
  final Icon? icon;

  /// Detailed text for the permission.
  ///
  /// Refer to [Google Play](https://support.google.com/googleplay/android-developer/answer/9799150?visit_id=638041800350153935-369621111&p=pd-m&rd=1#prominent_disclosure&zippy=%2Cstep-provide-prominent-in-app-disclosure%2Cstep-review-best-practices-for-accessing-location%2Cstep-consider-alternatives-to-accessing-location-in-the-background%2Cstep-make-access-to-location-in-the-background-clear-to-users%2Csee-an-example-of-prominent-in-app-disclosure)
  /// for policy requirements for this rationale text.
  final String rationaleText;

  /// Whether these permissions are required.
  ///
  /// If it is required, users cannot migrate out of disclosure page until the permission is granted. `forcedPermissionDialogConfig` should include configuration for the
  /// dialog shown when required permission are denied.
  final bool required;

  /// Configuration for the dialog shown when this permission is denied and the permission is required.
  final ForcedPermissionDialogConfig? forcedPermissionDialogConfig;
}