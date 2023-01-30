import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_item_config.dart';
import 'package:flutter_force_permission/permission_item_text.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/flutter_force_permission_util.dart';
import 'package:flutter_force_permission/src/test_stub.dart';
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

class _DisplayItem {
  _DisplayItem({
    required this.config,
    required this.isService,
  });

  final PermissionItemConfig config;
  final bool isService;
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

  List<_DisplayItem> _getRequestingPermissions() =>
      widget.permissionConfig.permissionItemConfigs.expand((e) {
        var denied = false;
        var requested = false;
        var serviceDisabled = false;
        for (final Permission p in e.permissions) {
          if (widget.permissionStatuses[p]?.status !=
              PermissionStatus.granted) {
            denied = true;
          }
          if (widget.permissionStatuses[p]?.requested ?? true) {
            requested = true;
          }
          if (widget.permissionStatuses[p]?.serviceStatus ==
              ServiceStatus.disabled) {
            serviceDisabled = true;
          }
        }
        final serviceText = e.serviceItemText;

        final List<_DisplayItem> result = [];
        if (serviceDisabled && serviceText != null && e.required) {
          result.add(_DisplayItem(config: e, isService: true));
        }
        if (denied && (!requested || e.required)) {
          result.add(_DisplayItem(config: e, isService: false));
        }

        return result;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final theme = widget.permissionConfig.themeData ?? Theme.of(context);

    final titleWidget = Column(
      children: [
        const SizedBox(height: 64),
        Text(
          widget.permissionConfig.title,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );

    final permissionItems = _getRequestingPermissions();

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
                  final config = item.isService
                      ? item.config.serviceItemText
                      : item.config.itemText;
                  var icon = config?.icon;
                  icon ??= Icon(
                    Icons.perm_device_info_sharp,
                    color: theme.primaryColor,
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
                                  config?.header ?? '',
                                  style: theme.textTheme.titleMedium,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: DisclosurePage.maxLines,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  config?.rationaleText ?? '',
                                  style: theme.textTheme.bodyMedium,
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
              style: theme.elevatedButtonTheme.style,
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
    for (final _DisplayItem item in _getRequestingPermissions()) {
      if (item.isService) {
        final text = item.config.serviceItemText;
        if (text != null) {
          for (final Permission perm in item.config.permissions) {
            if (perm is PermissionWithService) {
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
        }
      } else {
        for (final Permission perm in item.config.permissions) {
          // ignore: prefer-moving-to-variable, multiple calls needed to ensure up-to-date data.
          var permStatus = await widget._service.status(perm);
          if (permStatus != PermissionStatus.permanentlyDenied) {
            // ignore: avoid-ignoring-return-values, not needed.
            await widget._service.request(perm);
          }

          if (item.config.required) {
            // ignore: prefer-moving-to-variable, multiple calls needed to ensure up-to-date data.
            permStatus = await widget._service.status(perm);
            while (permStatus != PermissionStatus.granted) {
              await _showRequiredPermDialog(
                item.config.itemText,
                _showAppSettings,
              );
              // ignore: avoid-ignoring-return-values, not needed.
              await widget._resumed.stream.firstWhere((element) => element);
              // ignore: prefer-moving-to-variable, multiple calls needed to ensure up-to-date data.
              permStatus = await widget._service.status(perm);
            }
          }

          // ignore: avoid-ignoring-return-values, not needed.
          await prefs.setBool(getRequestedPrefKey(perm), true);
        }
      }
    }

    navigator.pop();
  }

  Future<void> _showRequiredPermDialog(
    PermissionItemText permConfig,
    VoidCallback openSettings,
  ) async {
    final navigator = Navigator.of(context);
    final dialogConfig = permConfig.forcedPermissionDialogConfig;
    final callback = widget.permissionConfig.showDialogCallback;

    if (callback == null) {
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
                onPressed: () {
                  openSettings();
                  navigator.pop();
                },
                child: Text(
                  dialogConfig?.buttonText ?? '',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      callback(
        context,
        dialogConfig?.title ?? '',
        dialogConfig?.text ?? '',
        dialogConfig?.buttonText ?? '',
        openSettings,
      );
    }
  }

  Future<void> _showPhoneSettings() async {
    await widget._service.openAppSettings();
  }

  Future<void> _showLocationSettings() async {
    await widget._service.openLocationSettings();
  }

  Future<void> _showAppSettings() async {
    await widget._service.openAppSettings();
  }
}
