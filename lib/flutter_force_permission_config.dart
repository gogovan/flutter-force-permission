import 'package:flutter_force_permission/permission_item_config.dart';

class FlutterForcePermissionConfig {
  FlutterForcePermissionConfig({
    required this.title,
    required this.permissionItemConfigs,
  });

  final String title;
  final List<PermissionItemConfig> permissionItemConfigs;

}
