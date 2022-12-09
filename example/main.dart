import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/forced_permission_dialog_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Example for flutter-force-permission.
///
/// Note that typically you want to show disclosure page when the app is resumed. This can be
/// achieved using [WidgetsBindingObserver].
/// This demo triggers the disclosure page on a button click for simplicity.
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
              child: const Text("Show disclosure page"),
              onPressed: () async {
                final perm = FlutterForcePermission(
                  FlutterForcePermissionConfig(
                    title: 'Title',
                    confirmText: 'Confirm',
                    permissionItemConfigs: [
                      PermissionItemConfig(
                        permissions: [Permission.notification],
                        itemText: PermissionItemText(
                          header: 'Notification',
                          rationaleText: 'Rationale for Notification.',
                        ),
                      ),
                      PermissionItemConfig(
                        permissions: [Permission.locationWhenInUse],
                        required: true,
                        itemText: PermissionItemText(
                          header: 'Foreground Location',
                          rationaleText: 'Rationale for Foreground location. Required.',
                          forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
                            title: 'Please enable location permission',
                            text: 'Please enable location permission for proper usage.',
                            buttonText: 'Settings',
                          ),
                        ),
                      ),
                      PermissionItemConfig(
                        permissions: [Permission.locationAlways],
                        itemText: PermissionItemText(
                          header: 'Background Location',
                          rationaleText: 'Rationale for Background location. lorem ipsum dolor sit amet.',
                        ),
                      ),
                      PermissionItemConfig(
                        permissions: [
                          Permission.activityRecognition,
                          Permission.sensors,
                        ],
                        itemText: PermissionItemText(
                          header: 'Activity Recognition and sensors',
                          rationaleText: 'Rationale for Activity Recognition and sensors.',
                        ),
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
