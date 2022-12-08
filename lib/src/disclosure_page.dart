import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/src/flutter_force_permission_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Disclosure page.
///
/// Shown when there are any permissions that need users to grant.
class DisclosurePage extends StatefulWidget {
  const DisclosurePage({super.key, required this.forcePermission});

  /// Maximum number of lines displayed for title and rationale for each permission item.
  static const maxLines = 3;

  final FlutterForcePermission forcePermission;

  @override
  State<DisclosurePage> createState() => _DisclosurePageState();
}

class _DisclosurePageState extends State<DisclosurePage>
// ignore: prefer_mixin, WidgetsBindingObserver is Framework code
    with WidgetsBindingObserver {
  StreamController<bool> resumed = StreamController.broadcast();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      resumed.add(true);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ignore: avoid-ignoring-return-values, not needed.
    WidgetsBinding.instance.removeObserver(this);
    // ignore: avoid-ignoring-return-values, not needed.
    resumed.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permConfig = widget.forcePermission.config;

    final titleWidget = Column(
      children: [
        const SizedBox(height: 64),
        Text(
          permConfig.title,
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
              itemCount: permConfig.permissionItemConfigs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return titleWidget;
                } else {
                  final item = widget
                      .forcePermission.config.permissionItemConfigs[index - 1];
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
                                  maxLines: DisclosurePage.maxLines,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item.rationaleText,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: DisclosurePage.maxLines,
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
              child: Text(widget.forcePermission.config.confirmText),
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
        in widget.forcePermission.config.permissionItemConfigs) {
      for (final Permission perm in permConfig.permissions) {
        // ignore: avoid-ignoring-return-values, not needed.
        await perm.request();

        if (permConfig.required) {
          var permStatus = await perm.status;
          while (permStatus != PermissionStatus.granted) {
            await _showRequiredPermDialog(permConfig);
            // ignore: avoid-ignoring-return-values, not needed.
            await resumed.stream.firstWhere((element) => element);
            permStatus = await perm.status;
          }
        }

        // ignore: avoid-ignoring-return-values, not needed.
        await prefs.setBool(getRequestedPrefKey(perm), true);
      }
    }

    navigator.pop();
  }

  Future<void> _showRequiredPermDialog(PermissionItemConfig permConfig) async {
    // ignore: avoid-ignoring-return-values, not needed.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            permConfig.forcedPermissionDialogConfig?.title ?? '',
          ),
          content: Text(
            permConfig.forcedPermissionDialogConfig?.text ?? '',
          ),
          actions: [
            TextButton(
              onPressed: _showSettings,
              child: Text(
                permConfig.forcedPermissionDialogConfig?.buttonText ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettings() async {
    final navigator = Navigator.of(context);

    // ignore: avoid-ignoring-return-values, maybe we could use it but probably later
    await openAppSettings();

    navigator.pop();
  }
}
