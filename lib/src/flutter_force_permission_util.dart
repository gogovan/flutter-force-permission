import 'package:permission_handler/permission_handler.dart';

String getRequestedPrefKey(Permission perm) => '${perm.toString()}_requested';
