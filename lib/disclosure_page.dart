import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/flutter_force_permission_util.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Disclosure page.
///
/// Shown when there are any permissions that need users to grant.
class DisclosurePage extends StatelessWidget {
  const DisclosurePage({super.key, required this.forcePermission});

  /// Maximum number of lines for title and rationale for each permission item.
  static const maxLines = 9;

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
                    final perm = item.permissions.first;
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
                    } else if (perm.value ==
                            Permission.activityRecognition.value ||
                        perm.value == Permission.sensors.value) {
                      icon = Icon(
                        Icons.directions_run,
                        color: Theme.of(context).primaryColor,
                      );
                    } else {
                      if (kDebugMode) {
                        print(
                          '[FlutterForcePermission] WARN: unsupported permission ${item.permissions} found.',
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
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  item.header,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: maxLines,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item.rationaleText,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: maxLines,
                                ),
                              ),
                            ],
                          ),
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
              onPressed: () => _onGrantPermission(context),
              child: Text(forcePermission.config.confirmText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGrantPermission(BuildContext context) async {
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();

    // Request permissions one by one because in some cases requesting
    // multiple permissions does not ask the user as expected.
    for (final PermissionItemConfig permConfig
        in forcePermission.config.permissionItemConfigs) {
      for (final Permission perm in permConfig.permissions) {
        // ignore: avoid-ignoring-return-values, not needed.
        await perm.request();
        // ignore: avoid-ignoring-return-values, not needed.
        await prefs.setBool(getRequestedKey(perm), true);
      }
    }

    navigator.pop();
  }
}
