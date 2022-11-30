import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:permission_handler/permission_handler.dart';

class DisclosurePage extends StatelessWidget {
  const DisclosurePage({super.key, required this.forcePermission});

  final FlutterForcePermission forcePermission;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      children: [
        const SizedBox(height: 64),
        Text(
          forcePermission.config.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16),
      ],
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(32),
              itemCount:
                  forcePermission.config.permissionItemConfigs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return titleWidget;
                } else {
                  final item =
                      forcePermission.config.permissionItemConfigs[index - 1];
                  var icon = item.icon;
                  if (icon == null) {
                    final perm = item.permission.first;
                    if (perm.value == Permission.notification.value) {
                      icon = Icon(
                        Icons.notifications_none,
                        color: Theme.of(context).primaryColor,
                      );
                    } else if (perm.value ==
                        Permission.locationWhenInUse.value) {
                      icon = Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).primaryColor,
                      );
                    } else if (perm.value == Permission.locationAlways.value ||
                        perm.value == Permission.location.value) {
                      icon = Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      );
                    } else if (perm.value == Permission.sensors.value ||
                        perm.value == Permission.activityRecognition.value) {
                      icon = Icon(
                        Icons.directions_run,
                        color: Theme.of(context).primaryColor,
                      );
                    } else {
                      if (kDebugMode) {
                        print(
                          '[FlutterForcePermission] WARN: unsupported permission ${item
                              .permission} found.',
                        );
                      }
                      icon = Icon(
                        Icons.perm_device_info_sharp,
                        color: Theme.of(context).primaryColor,
                      );
                    }
                  }

                  return Center(
                    child: Row(
                      children: [
                        icon,
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.header,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              item.rationaleText,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) => const SizedBox(height: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _onGrantPermission,
              child: Text(forcePermission.config.confirmText),
            ),
          ),
        ],
      ),
    );
  }

  void _onGrantPermission() {}
}
