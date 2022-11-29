import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

/// Configuration for each item in the disclosure page and requested permissions.
class PermissionItemConfig {
  PermissionItemConfig({
    required this.permission,
    required this.title,
    required this.rationaleText,
    this.icon,
    this.required = false,
    this.forcedPermissionDialogText = '',
  });

  /// The Permission to request.
  ///
  /// If multiple permissions are provided, this item will cover all of them.
  /// Refer to the constants of the Permission in [permission_handler plugin](https://pub.dev/documentation/permission_handler_platform_interface/latest/permission_handler_platform_interface/Permission-class.html).
  /// Currently, only supports location, locationAlways, locationWhenInUse, notification, sensors, activityRecognition.
  final List<Permission> permission;

  /// Title for the permission item.
  final String title;

  /// The Icon for the permission item.
  ///
  /// If omitted, a Material Icon appropriate for the permission will be used.
  final Icon? icon;

  /// Detailed text for the permission.
  ///
  /// Refer to [Google Play](https://support.google.com/googleplay/android-developer/answer/9799150?visit_id=638041800350153935-369621111&p=pd-m&rd=1#prominent_disclosure&zippy=%2Cstep-provide-prominent-in-app-disclosure%2Cstep-review-best-practices-for-accessing-location%2Cstep-consider-alternatives-to-accessing-location-in-the-background%2Cstep-make-access-to-location-in-the-background-clear-to-users%2Csee-an-example-of-prominent-in-app-disclosure)
  /// for policy requirements for this rationale text.
  final String rationaleText;

  /// Whether these permissions are required.
  ///
  /// If it is required, users cannot migrate out of disclosure page until the permission is granted.
  final bool required;

  /// For required permissions, the text shown for the dialog when requesting users to go to Settings page.
  final String forcedPermissionDialogText;

}