library flutter_force_permission;

import 'package:flutter/material.dart';
import 'package:flutter_force_permission/flutter_force_permission_config.dart';
import 'package:flutter_force_permission/permission_required_option.dart';
import 'package:flutter_force_permission/permission_service_status.dart';
import 'package:flutter_force_permission/src/flutter_force_permission_util.dart';
import 'package:flutter_force_permission/src/test_stub.dart';
import 'package:flutter_force_permission/src/views/disclosure_page.dart';
import 'package:permission_handler/permission_handler.dart';

/// Flutter Force Permission
///
/// Show permission disclosure page and allows required permissions before user can proceed.
class FlutterForcePermission {
  /// Constructor. Pass configuration here. Refer to [FlutterForcePermissionConfig] for details.
  FlutterForcePermission(this.config)
      : _service = const TestStub(),
        _requestedInSession = <Permission, bool>{};

  @visibleForTesting
  FlutterForcePermission.stub(
    this.config,
    this._service,
    this._requestedInSession,
  );

  /// Configuration. Refer to [FlutterForcePermissionConfig] for details.
  final FlutterForcePermissionConfig config;

  final TestStub _service;

  bool _showing = false;

  final Map<Permission, bool> _requestedInSession;

  @visibleForTesting
  Map<Permission, bool> getRequestedInSession() => _requestedInSession;

  /// Show disclosure page.
  ///
  /// This will show the disclosure page according to the provided configuration, and handles requesting permissions.
  /// If the disclosure page is already shown, it will do nothing.
  /// Returns a map of Permission and their status after requesting the permissions.
  /// Only permissions specified in the configuration will be included in the return value.
  Future<Map<Permission, PermissionServiceStatus>> show(
    NavigatorState navigator,
  ) async {
    // Check for permissions.
    final permissionStatuses = await getPermissionStatuses();
    if (_showing) return permissionStatuses;
    _showing = true;

    if (permissionStatuses.values
        .every((element) => element.status == PermissionStatus.granted)) {
      // All permissions granted, no need to show disclosure page.
      return permissionStatuses;
    }

    final bool needShow = isShowPermissionPage(permissionStatuses);

    if (!needShow) {
      return permissionStatuses;
    }

    // Navigate to disclosure page.
    // ignore: avoid-ignoring-return-values, not needed.
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => DisclosurePage(
          permissionConfig: config,
          permissionStatuses: permissionStatuses,
        ),
      ),
    );

    _showing = false;

    for (final permConfig in config.permissionItemConfigs) {
      for (final perm in permConfig.permissions) {
        if (permConfig.required != PermissionRequiredOption.required) {
          _requestedInSession[perm] = true;
        }
      }
    }

    // Check for permission status again as it is likely updated.
    return getPermissionStatuses();
  }

  bool isShowPermissionPage(
    Map<Permission, PermissionServiceStatus> permissionStatuses,
  ) {
    var needShow = false;
    for (final permConfig in config.permissionItemConfigs) {
      for (final perm in permConfig.permissions) {
        if (permissionStatuses[perm]?.status != PermissionStatus.granted &&
                (permConfig.required == PermissionRequiredOption.required) ||
            !(permissionStatuses[perm]?.requested ?? true) ||
            (permConfig.required == PermissionRequiredOption.ask &&
                _requestedInSession[perm] != true)) {
          needShow = true;
          break;
        }
        if (perm is PermissionWithService &&
            permissionStatuses[perm]?.serviceStatus == ServiceStatus.disabled &&
            permConfig.required != PermissionRequiredOption.none &&
            _requestedInSession[perm] != true) {
          needShow = true;
          break;
        }
      }
    }

    return needShow;
  }

  /// Get all permission statuses.
  ///
  /// Only permissions specified in the configuration will be queried and returned.
  Future<Map<Permission, PermissionServiceStatus>>
      getPermissionStatuses() async {
    final prefs = await _service.getSharedPreference();
    final Map<Permission, PermissionServiceStatus> result = {};
    for (final List<Permission> perms
        in config.permissionItemConfigs.map((e) => e.permissions)) {
      for (final Permission perm in perms) {
        final status = await _service.status(perm);
        final requested = prefs.getBool(getRequestedPrefKey(perm)) ?? false;
        ServiceStatus? serviceStatus;
        if (perm is PermissionWithService) {
          serviceStatus = await _service.serviceStatus(perm);
        }
        result[perm] = PermissionServiceStatus(
          status: status,
          requested: requested,
          serviceStatus: serviceStatus,
        );
      }
    }

    return result;
  }
}
