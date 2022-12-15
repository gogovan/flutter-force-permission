# flutter-force-permission
[![codecov](https://codecov.io/gh/gogovan/flutter-force-permission/branch/main/graph/badge.svg?token=F9DPJUAVAJ)](https://codecov.io/gh/gogovan/flutter-force-permission)
Show permission disclosure page and allows required permissions and their associated services before the user can proceed.

This package shows a prominent in-app disclosure page for getting permissions as required by [Google Play](https://support.google.com/googleplay/android-developer/answer/9799150?visit_id=638041800350153935-369621111&p=pd-m&rd=1#prominent_disclosure&zippy=%2Cstep-provide-prominent-in-app-disclosure%2Cstep-review-best-practices-for-accessing-location%2Cstep-consider-alternatives-to-accessing-location-in-the-background%2Cstep-make-access-to-location-in-the-background-clear-to-users%2Csee-an-example-of-prominent-in-app-disclosure).
Also support iOS to ensure a consistent experience.

In addition, permissions can be set as "required". If this is set, those required permissions will be required and if users denied it, 
this package will show a custom dialog and redirect user to the appropriate settings page provided by the OS.

## Setup
1. Add the following to `pubspec.yaml`
```yaml
dependencies:
  flutter_force_permission: ^0.1.0
  permission_handler: ^10.2.0
```
2. This package depends on [permission_handler](https://pub.dev/packages/permission_handler). Perform setup according to that package.
3. If any features is required, it is highly recommended to also set the `<uses-feature>` tag in AndroidManifest.xml. Refer to [relevant Android Developers page](https://developer.android.com/guide/topics/manifest/uses-feature-element) for details. 

## Usage
1. Create an instance of FlutterForcePermission, providing configuration.
```dart
final perm = FlutterForcePermission(
    FlutterForcePermissionConfig(
      title: 'Title',
      permissionItemConfigs: [
        PermissionItemConfig(
          permissions: [Permission.locationWhenInUse],
          required: true,
          itemText: PermissionItemText(
            header: 'Foreground Location',
            rationaleText: 'Rationale for Foreground location. Required.',
            forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
              title: 'Please enable location permission',
              text: 'Please enable location permission for proper usage.',
              buttonText: 'Settings',
            ),
          ),
        ),
        PermissionItemConfig(
          permissions: [Permission.locationAlways],
          itemText: PermissionItemText(
            header: 'Background Location',
            rationaleText: 'Rationale for Background location. lorem ipsum dolor sit amet.',
          ),
        ),
      ],
    ),
  );
```
2. Show the disclosure page as needed. This method will handle showing the disclosure page and requesting permissions.
This function takes a [NavigatorState] which can be retrieved through `Navigator.of(context)` call.
This is an async function. Wrap the function in an `async` block as needed.
Returns a map of permission and their requested status (granted/denied/etc). Refer to [permission_handler](https://pub.dev/packages/permission_handler) for the interface.
```dart
final result = await perm.show(Navigator.of(context));
```

### Styling
You can set the style of the text shown by setting up a [TextTheme] of the provided context. 
- Title uses `headline6` text style.
- Item header use `subtitle1` text style.
- Item body use `bodyText2` text style.

## Issues

## Contributing

