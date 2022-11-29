import 'package:flutter/widgets.dart';

class PermissionItemConfig {
  PermissionItemConfig({
    required this.title,
    required this.rationaleText,
    this.required = false,
    this.forcedPermissionDialogText = '',
    this.icon,
  });

  final String title;
  final String rationaleText;
  final bool required;
  final String forcedPermissionDialogText;
  final Icon? icon;

}