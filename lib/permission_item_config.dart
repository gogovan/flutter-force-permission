library flutter_force_permission;

import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Configuration for each permission(s) in the disclosure page and requested permissions.
class PermissionItemConfig {
  PermissionItemConfig({
    required this.permissions,
    required this.itemText,
    this.serviceItemText,
    this.required = false,
  });

  /// The Permission(s) to request.
  ///
  /// If multiple permissions are provided, this item will cover all of them.
  /// Refer to the constants of the Permission in [permission_handler plugin](https://pub.dev/documentation/permission_handler_platform_interface/latest/permission_handler_platform_interface/Permission-class.html).
  final List<Permission> permissions;

  /// The display item configuration for these permission(s). Refer to [PermissionItemText] for details.
  final PermissionItemText itemText;

  /// If the permission has an associated service (such as location) and this permission is required, this service will also be checked for availability.
  /// If service is unavailable and this item is not null, the disclosure page will show a disclosure item for this service, before `itemText`.
  /// Users will also be asked to enable the service.
  ///
  /// *Note*: This is used only when `required` is true.
  final PermissionItemText? serviceItemText;

  /// Whether these permission(s) are required.
  ///
  /// If it is required, users cannot migrate out of disclosure page until the permission is granted.
  /// `forcedPermissionDialogConfig` under `itemText` should include configuration for the
  /// dialog shown when required permission are denied.
  final bool required;
}
