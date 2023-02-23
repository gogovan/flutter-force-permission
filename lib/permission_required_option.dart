/// Options for permission required level.
enum PermissionRequiredOption {
  /// None: This permission is not required. Users will be asked once only
  /// using system provided dialogs.
  none,

  /// Ask: This permission is recommended. Users will first be asked using
  /// system provided dialogs. As long as this permission is not granted, users
  /// will be asked with a customizable, cancellable dialog.
  ask,

  /// Forced: This permission is required. Users will be unable to proceed
  /// without granting this permission. A customizable, uncancellable dialog
  /// will be shown in place asking users to grant the permission.
  /// NOTE: This may cause rejections on iOS App Store. Use responsibly.
  required,
}
