import 'package:permission_handler/permission_handler.dart';

/// Permission status and the status of their associated service, if any.
class PermissionServiceStatus {
  PermissionServiceStatus({
    required this.status,
    this.serviceStatus,
  });

  /// Status of the permission.
  final PermissionStatus status;

  /// Status of the service associated to the permission. Null if no associated service.
  final ServiceStatus? serviceStatus;

  @override
  String toString() =>
      'PermissionServiceStatus{status: $status, serviceStatus: $serviceStatus}';
}
