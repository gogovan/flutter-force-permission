import 'package:flutter/material.dart';
import 'package:flutter_force_permission/forced_permission_dialog_config.dart';

/// Configuration for each displayed permission item.
class PermissionItemText {
  PermissionItemText({
    required this.header,
    required this.rationaleText,
    this.icon,
    this.forcedPermissionDialogConfig,
  });

  /// Title for the permission item.
  final String header;

  /// The Icon for the permission item.
  ///
  /// If omitted, a default icon will be provided.
  final Icon? icon;

  /// Detailed text for the permission.
  ///
  /// Refer to [Google Play](https://support.google.com/googleplay/android-developer/answer/9799150?visit_id=638041800350153935-369621111&p=pd-m&rd=1#prominent_disclosure&zippy=%2Cstep-provide-prominent-in-app-disclosure%2Cstep-review-best-practices-for-accessing-location%2Cstep-consider-alternatives-to-accessing-location-in-the-background%2Cstep-make-access-to-location-in-the-background-clear-to-users%2Csee-an-example-of-prominent-in-app-disclosure)
  /// for policy requirements for this rationale text.
  final String rationaleText;

  /// Configuration for the dialog shown when this permission is denied and the permission is required.
  final ForcedPermissionDialogConfig? forcedPermissionDialogConfig;

  @override
  String toString() =>
      'PermissionItemText{header: $header, icon: $icon, rationaleText: $rationaleText, forcedPermissionDialogConfig: $forcedPermissionDialogConfig}';
}
