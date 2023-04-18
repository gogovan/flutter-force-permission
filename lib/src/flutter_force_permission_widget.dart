import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/views/disclosure_page.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterForcePermissionWidget extends StatefulWidget {
  const FlutterForcePermissionWidget({
    required this.permissionConfig,
    required this.permissionStatuses,
    super.key,
  });

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  final FlutterForcePermissionConfig permissionConfig;
  final Map<Permission, PermissionServiceStatus> permissionStatuses;

  @override
  State<FlutterForcePermissionWidget> createState() =>
      _FlutterForcePermissionWidgetState();
}

class _FlutterForcePermissionWidgetState
    extends State<FlutterForcePermissionWidget> {

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Navigator(
        key: FlutterForcePermissionWidget.navigatorKey,
        initialRoute: '/disclosurePage',
        onGenerateRoute: (settings) => _onGenerateRoute(settings, context),
      ),
    );

  Route _onGenerateRoute(RouteSettings settings, BuildContext outerContext) =>
      settings.name == '/disclosurePage'
          ? MaterialPageRoute(
              builder: (context) => DisclosurePage(
                permissionConfig: widget.permissionConfig,
                permissionStatuses: widget.permissionStatuses,
                onDone: () {
                  // We want to pop the navigator outside the Force Permission widget, popping the entire Force Permission
                  // and its navigator with it. We use the outer context passed from build to achieve this.
                  Navigator.pop(outerContext);
                },
              ),
              settings: settings,
            )
          : MaterialPageRoute(
              builder: (context) => const Placeholder(),
              settings: settings,
            );


}
