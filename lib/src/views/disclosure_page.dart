import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/flutter_force_permission_util.dart';
import 'package:flutter_force_permission/src/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Disclosure page.
///
/// Shown when there are any permissions that need users to grant.
class DisclosurePage extends StatefulWidget {
  DisclosurePage({
    super.key,
    required this.permissionConfig,
    required this.permissionStatuses,
  })  : _service = const TestStub(),
        _resumed = StreamController.broadcast();

  @visibleForTesting
  const DisclosurePage.stub({
    required this.permissionConfig,
    required this.permissionStatuses,
    required service,
    required resumed,
    super.key,
  })  : _service = service,
        _resumed = resumed;

  /// Maximum number of lines displayed for title and rationale for each permission item.
  static const maxLines = 3;

  final FlutterForcePermissionConfig permissionConfig;
  final Map<Permission, PermissionServiceStatus> permissionStatuses;

  final TestStub _service;

  final StreamController<bool> _resumed;

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
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      widget._resumed.add(true);
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
    widget._resumed.close();
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

    final permissionItems =
        widget.permissionConfig.permissionItemConfigs.expand((e) {
      var denied = false;
      var serviceDisabled = false;
      for (final Permission p in e.permissions) {
        if (widget.permissionStatuses[p]?.status != PermissionStatus.granted) {
          denied = true;
        }
        if (widget.permissionStatuses[p]?.serviceStatus ==
            ServiceStatus.disabled) {
          serviceDisabled = true;
        }
      }
      final itemText = e.itemText;
      final serviceText = e.serviceItemText;
      final permission = e.permissions.first;

      final List<_PermissionItem> result = [];
      if (serviceDisabled && serviceText != null) {
        result.add(_PermissionItem(permission, serviceText));
      }
      if (denied) {
        result.add(_PermissionItem(permission, itemText));
      }

      return result;
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
    final prefs = await widget._service.getSharedPreference();

    // Request permissions one by one because in some cases requesting
    // multiple permissions does not ask the user as expected.
    for (final PermissionItemConfig permConfig
        in widget.permissionConfig.permissionItemConfigs) {
      for (final Permission perm in permConfig.permissions) {
        if (permConfig.required && perm is PermissionWithService) {
          final text = permConfig.serviceItemText;
          if (text != null) {
            var serviceStatus = await widget._service.serviceStatus(perm);
            while (serviceStatus == ServiceStatus.disabled) {
              if (perm == Permission.phone) {
                await _showRequiredPermDialog(text, _showPhoneSettings);
              } else if (perm == Permission.location ||
                  perm == Permission.locationAlways ||
                  perm == Permission.locationWhenInUse) {
                await _showRequiredPermDialog(text, _showLocationSettings);
              } else {
                if (kDebugMode) {
                  print(
                    '[flutter-force-permission] WARN: Unsupported Permission with service $perm found.',
                  );
                }
                break;
              }
              // ignore: avoid-ignoring-return-values, not needed.
              await widget._resumed.stream.firstWhere((element) => element);
              serviceStatus = await widget._service.serviceStatus(perm);
            }
          }
        }

        // ignore: avoid-ignoring-return-values, not needed.
        await widget._service.request(perm);

        if (permConfig.required) {
          var permStatus = await widget._service.status(perm);
          while (permStatus != PermissionStatus.granted) {
            await _showRequiredPermDialog(
              permConfig.itemText,
              _showAppSettings,
            );
            // ignore: avoid-ignoring-return-values, not needed.
            await widget._resumed.stream.firstWhere((element) => element);
            permStatus = await widget._service.status(perm);
          }
        }

        // ignore: avoid-ignoring-return-values, not needed.
        await prefs.setBool(getRequestedPrefKey(perm), true);
      }
    }

    navigator.pop();
  }

  Future<void> _showRequiredPermDialog(
    PermissionItemText permConfig,
    VoidCallback openSettings,
  ) async {
    final dialogConfig = permConfig.forcedPermissionDialogConfig;
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
              onPressed: openSettings,
              child: Text(
                dialogConfig?.buttonText ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhoneSettings() async {
    final navigator = Navigator.of(context);

    // TODO(peter): find function to open phone settings directly if possible.
    await widget._service.openAppSettings();

    navigator.pop();
  }

  Future<void> _showLocationSettings() async {
    final navigator = Navigator.of(context);

    await widget._service.openLocationSettings();

    navigator.pop();
  }

  Future<void> _showAppSettings() async {
    final navigator = Navigator.of(context);

    await widget._service.openAppSettings();

    navigator.pop();
  }
}
