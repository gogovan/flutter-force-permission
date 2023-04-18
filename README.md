# flutter-force-permission

![Build](https://github.com/gogovan/flutter-force-permission/actions/workflows/build.yaml/badge.svg)
![codecov](https://codecov.io/gh/gogovan/flutter-force-permission/branch/main/graph/badge.svg?token=F9DPJUAVAJ)

Show permission disclosure page and allows required permissions and their associated services before
the user can proceed.

This package shows a prominent in-app disclosure page for getting permissions as required
by [Google Play](https://support.google.com/googleplay/android-developer/answer/9799150?visit_id=638041800350153935-369621111&p=pd-m&rd=1#prominent_disclosure&zippy=%2Cstep-provide-prominent-in-app-disclosure%2Cstep-review-best-practices-for-accessing-location%2Cstep-consider-alternatives-to-accessing-location-in-the-background%2Cstep-make-access-to-location-in-the-background-clear-to-users%2Csee-an-example-of-prominent-in-app-disclosure)
. Also support iOS to ensure a consistent experience.

In addition, permissions and their associated services (e.g. GPS) can be set as "required". If this
is set, those required permissions will be required and if users denied it, this package will show a
customizable dialog and redirect user to the appropriate settings page provided by the native OS.

## Setup

1. Add the following to `pubspec.yaml`

```yaml
dependencies:
  flutter_force_permission: ^0.1.0
  # Currently this package depends on our `flutter-permission-handler` package to fix an iOS issue.
  # Directly depends on our packages to avoid any pubspec dependency resolving failure.
  # Track the PR at: https://github.com/Baseflow/flutter-permission-handler/pull/967
  # TODO replace once we upload our packages and our PR merged by Baseflow.
  permission_handler:
     git:
        url: https://github.com/gogovan/flutter-permission-handler.git
        ref: master
        path: permission_handler
  permission_handler_apple:
     git:
        url: https://github.com/gogovan/flutter-permission-handler.git
        ref: master
        path: permission_handler_apple

# TODO replace once we upload our packages and our PR merged by Baseflow.
dependency_overrides:
   permission_handler_apple:
      git:
         url: https://github.com/gogovan/flutter-permission-handler.git
         ref: master
         path: permission_handler_apple
```

2. This package depends on [permission_handler](https://pub.dev/packages/permission_handler).
   Perform setup according to that package.
3. On Android, if you use `POST_NOTIFICATIONS` permission, update the `targetSdkVersion`
   in `build.gradle` to at least 33 so that the permission request dialog is shown correctly. Refer
   to [relevant Android Developer page](https://developer.android.com/develop/ui/views/notifications/notification-permission)
   for details.

```groovy
android {
    // ...
    defaultConfig {
        compileSdkVersion 33
        targetSdkVersion 33
        // ...
    }
    // ...
}
```

4. If any features is required, it is highly recommended to also set the `<uses-feature>` tag in
   AndroidManifest.xml. Refer
   to [relevant Android Developers page](https://developer.android.com/guide/topics/manifest/uses-feature-element)
   for details.

## Usage

1. Create an instance of FlutterForcePermission, providing configuration. Refer to documentation
   of [FlutterForcePermissionConfig] for configuration details. Use a single instance of `FlutterForcePermission` throughout your app.

```dart

final perm = FlutterForcePermission(
  FlutterForcePermissionConfig(
    title: 'Title',
    permissionItemConfigs: [
      PermissionItemConfig(
        permissions: [Permission.locationWhenInUse],
        required: PermissionRequiredOption.required,
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

2. Show the disclosure page as needed. This method will handle showing the disclosure page and
   requesting permissions. This function takes a `BuildContext`. This is an async function. Wrap the function
   in an `async` block as needed. Returns a map of permission and their requested status (
   granted/denied/etc), service status and whether they are requested by this plugin.

```dart
final result = await perm.show(context);
```

### Styling

You can set the styles by providing a [ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)
in the configuration.

- `elevatedButtonTheme.style` is used for the primary button.
- `primaryColor` is used for as the color of the icons.
- Title uses `titleLarge` text style.
- Item header use `titleMedium` text style.
- Item body use `bodyMedium` text style.

## Advanced Usage

### Customize the required permission denied prompt

If you wish to customize the dialog shown when the required permission is denied, provide
a `showDialogCallback` which to show your dialog. Parameters are included for you to compose the
appropriate dialog. In your callback, you SHOULD:

1. Display a non-dismissable dialog. This can be typically achieved by setting `barrierDismissible`
   to false and provide an empty callback e.g. (`() async => false`) to `willPopCallback` for your
   dialog.
2. Call the provided `callback` parameter in your callback when the user click the confirm button,
   and dismiss your dialog by `Navigator.pop`.

```dart

final config = FlutterForcePermissionConfig(
  title: 'Title',
  confirmText: 'Confirm',
  permissionItemConfigs: [
    PermissionItemConfig(
      permissions: [
        Permission.location,
      ],
      itemText: PermissionItemText(
        header: 'Foreground location',
        rationaleText: 'Rationale',
        forcedPermissionDialogConfig: ForcedPermissionDialogConfig(
          title: 'Location required',
          text: 'Location needed for proper operation',
          buttonText: 'Settings',
        ),
      ),
      required: PermissionRequiredOption.required,
    ),
  ],
  showDialogCallback: (context, option, permConfig, callback) {
    // Store the navigator to avoid storing contexts across async gaps. See https://stackoverflow.com/a/69512692/11675817 for details.
    final navigator = Navigator.of(context);
    // Show your dialog.
    showDialog(context: context,
      barrierDismissible: false,
      builder: (context) =>
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(permConfig.forcedPermissionDialogConfig.title),
              content: Text(permConfig.forcedPermissionDialogConfig.text),
              actions: [
                TextButton(
                  onPressed: () {
                    callback();
                    navigator.pop();
                  },
                  child: Text(permConfig.forcedPermissionDialogConfig.buttonText),
                ),
              ],
            ),
          ),
    );
  },
);
```

## Known Issues

- Currently it depends on our fork
  of [`flutter-permission-handler`](https://github.com/gogovan/flutter-permission-handler) instead
  of the original to fix an issue for iOS. You may track the
  issue and pull request [here](https://github.com/Baseflow/flutter-permission-handler/pull/967).

## Issues

## Contributing

