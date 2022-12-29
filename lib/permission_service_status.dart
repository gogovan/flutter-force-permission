import 'package:permission_handler/permission_handler.dart';

/// Permission status and the status of their associated service, if any.
class PermissionServiceStatus {
  PermissionServiceStatus({
    required this.status,
    required this.requested,
    this.serviceStatus,
  });

  /// Status of the permission.
  final PermissionStatus status;

  /// Whether the permission is requested by this plugin.
  ///
  /// Note that detecting whether a permission is requested by anywhere from the app is not possible due to
  /// a lack of an API to query such information without actually making the request in both Android and iOS.
  final bool requested;

  /// Status of the service associated to the permission. Null if no associated service.
  final ServiceStatus? serviceStatus;

  @override
  String toString() =>
      'PermissionServiceStatus{status: $status, requested: $requested, serviceStatus: $serviceStatus}';
}
