import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/dimens.dart';
import '../l10n/app_localizations.dart';

/// Poruke o uspjehu i gresci te potvrde nepovratnih akcija.
///
/// Poruke su konkretne i opisuju sta se stvarno desilo, umjesto genericnih
/// tekstova poput "Success" ili "Bad request".
class AppFeedback {
  const AppFeedback._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle_rounded);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.danger, Icons.error_rounded);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.primary, Icons.info_rounded);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: AppSizes.iconMd),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
  }

  /// Potvrda prije nepovratne akcije (otkazivanje, brisanje, kupovina).
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final t = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel ?? t.commonDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    minimumSize: const Size(120, 44),
                  )
                : FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            child: Text(confirmLabel ?? t.commonConfirm),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Trazi obrazlozenje prije akcije koja ga zahtijeva (npr. razlog otkazivanja).
  static Future<String?> promptReason(
    BuildContext context, {
    required String title,
    required String label,
    String? confirmLabel,
  }) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(labelText: label),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.length < 3) {
                return t.reasonMinLengthError;
              }
              return null;
            },
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.commonDiscard),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            child: Text(confirmLabel ?? t.commonConfirm),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }
}

/// Dugme koje tokom cekanja prikazuje indikator i sprjecava dvostruko slanje.
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final IconData? icon;
  final bool isOutlined;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconMd),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final handler = isBusy ? null : onPressed;

    if (isOutlined) {
      return OutlinedButton(onPressed: handler, child: child);
    }

    return FilledButton(
      onPressed: handler,
      style: backgroundColor == null
          ? null
          : FilledButton.styleFrom(backgroundColor: backgroundColor),
      child: child,
    );
  }
}
