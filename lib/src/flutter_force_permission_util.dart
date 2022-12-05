import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

@internal
String getRequestedPrefKey(Permission perm) => '${perm.toString()}_requested';
