import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/flutter_force_permission_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Disclosure page.
///
/// Shown when there are any permissions that need users to grant.
class DisclosurePage extends StatefulWidget {
  const DisclosurePage({
    super.key,
    required this.permissionConfig,
    required this.permissionStatuses,
  });

  /// Maximum number of lines displayed for title and rationale for each permission item.
  static const maxLines = 3;

  final FlutterForcePermissionConfig permissionConfig;
  final Map<Permission, PermissionServiceStatus> permissionStatuses;

  @override
  State<DisclosurePage> createState() => _DisclosurePageState();
}

@immutable
class _PermissionItem {
  const _PermissionItem(this.permission, this.itemText);

  final Permission permission;
  final PermissionItemText itemText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PermissionItem &&
          runtimeType == other.runtimeType &&
          permission == other.permission &&
          itemText == other.itemText;

  @override
  int get hashCode => permission.hashCode ^ itemText.hashCode;

  @override
  String toString() =>
      '_PermissionItem{permission: $permission, itemText: $itemText}';
}

class _DisclosurePageState extends State<DisclosurePage>
    with
        // ignore: prefer_mixin, WidgetsBindingObserver is Framework code
        WidgetsBindingObserver {
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
    final titleWidget = Column(
      children: [
        const SizedBox(height: 64),
        Text(
          widget.permissionConfig.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16),
      ],
    );

    final permissionItems = widget.permissionConfig.permissionItemConfigs
        .where(
      (element) => element.permissions.every(
        (perm) =>
            widget.permissionStatuses[perm]?.status != PermissionStatus.granted,
      ),
    )
        .expand((e) {
      final serviceText = e.serviceItemText;
      final perm = e.permissions.first;
      final serviceDisabled = widget.permissionStatuses.values
          .any((element) => element.serviceStatus == ServiceStatus.disabled);

      return serviceText != null && serviceDisabled
          ? [
              _PermissionItem(perm, serviceText),
              _PermissionItem(perm, e.itemText),
            ]
          : [_PermissionItem(perm, e.itemText)];
    }).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(32),
              itemCount: permissionItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return titleWidget;
                } else {
                  final item = permissionItems[index - 1];
                  var icon = item.itemText.icon;
                  icon ??= Icon(
                    Icons.perm_device_info_sharp,
                    color: Theme.of(context).primaryColor,
                  );

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
                                  item.itemText.header,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: DisclosurePage.maxLines,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item.itemText.rationaleText,
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
              child: Text(widget.permissionConfig.confirmText),
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
        in widget.permissionConfig.permissionItemConfigs) {
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
    final dialogConfig = permConfig.itemText.forcedPermissionDialogConfig;
    // ignore: avoid-ignoring-return-values, not needed.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            dialogConfig?.title ?? '',
          ),
          content: Text(
            dialogConfig?.text ?? '',
          ),
          actions: [
            TextButton(
              onPressed: _showSettings,
              child: Text(
                dialogConfig?.buttonText ?? '',
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
