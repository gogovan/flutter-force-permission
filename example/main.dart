import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  runApp(MaterialApp(
    title: 'Flutter Force Permission Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      child: const Text("Press me to trigger disclosure page"),
      onPressed: () async {
        final perm = FlutterForcePermission(
          FlutterForcePermissionConfig(
            title: 'Title',
            confirmText: 'Confirm',
            permissionItemConfigs: [
              PermissionItemConfig(
                permissions: [Permission.notification],
                header: 'Notification',
                rationaleText: 'Rationale for Notification.',
              ),
              PermissionItemConfig(
                permissions: [Permission.locationWhenInUse],
                header: 'Foreground Location',
                rationaleText:
                    'Rationale for Foreground location. This is required.',
                required: true,
                forcedPermissionDialogText:
                    'Please enable location permission for proper usage.',
              ),
              PermissionItemConfig(
                permissions: [Permission.locationAlways],
                header: 'Background Location',
                rationaleText: 'Rationale for Background location.',
              ),
              PermissionItemConfig(
                permissions: [
                  Permission.activityRecognition,
                  Permission.sensors,
                ],
                header: 'Activity Recognition',
                rationaleText:
                    'Rationale for Activity Recognition and sensors.',
              )
            ],
          ),
        );

        final result = await perm.show(context);
        if (kDebugMode) {
          print(result);
        }
      },
    )));
  }
}
