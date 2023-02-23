library flutter_force_permission;

/// Configuration for the dialog shown when requesting users to go to Settings page.
class ForcedPermissionDialogConfig {
  ForcedPermissionDialogConfig({
    required this.title,
    required this.text,
    required this.buttonText,
    this.cancelText = '',
  });

  /// The title shown for the dialog when requesting users to go to Settings page.
  final String title;

  /// The body text shown for the dialog when requesting users to go to Settings page.
  final String text;

  /// The text of the cancel button for the dialog when requesting users to go to Settings page.
  /// Only used for options with `required` set to `ask`.
  final String cancelText;

  /// The text of the confirm button shown for the dialog when requesting users to go to Settings page.
  final String buttonText;
}
