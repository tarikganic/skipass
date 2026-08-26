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
    final l10n = AppLocalizations.of(context)!;
    final resolvedConfirmLabel = confirmLabel ?? l10n.commonConfirm;
    final resolvedCancelLabel = cancelLabel ?? l10n.commonDismiss;
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
            child: Text(resolvedCancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    minimumSize: const Size(120, 44),
                  )
                : FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            child: Text(resolvedConfirmLabel),
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
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _ReasonDialog(
        title: title,
        label: label,
        confirmLabel: confirmLabel,
      ),
    );
  }
}

/// Sadrzaj dijaloga za unos obrazlozenja.
///
/// TextEditingController zivi unutar ovog StatefulWidget-a (ne u pozivajucoj
/// funkciji) kako bi ga Flutter uklonio tek kada se dijalog stvarno demontira,
/// a ne odmah nakon zatvaranja - dijalog jos nekoliko frejmova iscrtava izlaznu
/// animaciju nakon Navigator.pop(), pa prijevremeni dispose() puca sa
/// "TextEditingController was used after being disposed".
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.label, this.confirmLabel});

  final String title;
  final String label;
  final String? confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedConfirmLabel = widget.confirmLabel ?? l10n.commonConfirm;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(labelText: widget.label),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.length < 3) {
              return l10n.appFeedbackReasonMinLength;
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonDismiss),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
          child: Text(resolvedConfirmLabel),
        ),
      ],
    );
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
