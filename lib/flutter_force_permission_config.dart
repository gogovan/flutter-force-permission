library flutter_force_permission;

import 'package:flutter/material.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_required_option.dart';

typedef ShowDialogCallback = Future<bool> Function(
  BuildContext context,
  PermissionRequiredOption option,
  PermissionItemText? permConfig,
  VoidCallback callback,
);

/// Configuration for Flutter Force Permission.
class FlutterForcePermissionConfig {
  FlutterForcePermissionConfig({
    required this.title,
    required this.confirmText,
    required this.permissionItemConfigs,
    this.showDialogCallback,
    this.themeData,
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

  /// Optional callback to show a custom dialog. If you wish to use dialogs other than
  /// the provided Material Design dialogs, provide a callback in this parameter.
  /// The parameters provided to the callback consists of the following:
  /// `context`: Use this context to build your dialogs.
  /// `option`: Indicates the PermissionRequiredOption for this dialog.
  ///   If this is `ask`, provide two buttons, one to dismiss the dialog and the other to show settings page by calling `callback`.
  ///   If this is `required`, provide one button which show settings page by calling `callback`.
  /// `permConfig`: Configuration for the item, contains all the text that you need to show.
  /// `callback`: Calls this callback when the user confirms the action to show settings page.
  ///
  /// This callback SHOULD invoke the provided `callback` in your callback upon confirmation
  /// to ensure proper functionality as the `callback` will invoke appropriate setting pages provided by the OS.
  /// The dialog shown during your callback SHOULD NOT be dismissable. It is typically
  /// achieved by setting `barrierDismissible` to false and provide an empty callback
  /// e.g. (`() async => false`) to `willPopCallback` for your dialog.
  ///
  /// Also, you will need to dismiss your dialog after confirmation.
  final ShowDialogCallback? showDialogCallback;

  /// Optional theme data for the disclosure page.
  /// If none is provided, theme data from the default Context is used.
  final ThemeData? themeData;
}
