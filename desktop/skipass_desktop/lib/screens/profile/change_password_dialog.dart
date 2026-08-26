import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Promjena lozinke prijavljenog korisnika.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().changePassword(
            currentPassword: _currentPassword.text,
            newPassword: _newPassword.text,
            confirmNewPassword: _confirmPassword.text,
          );

      if (!mounted) return;
      AppFeedback.success(context, AppLocalizations.of(context)!.changePasswordDialogSuccess);
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.changePasswordDialogTitle,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.changePasswordDialogCurrentLabel,
              controller: _currentPassword,
              obscureText: true,
              isRequired: true,
              validator: (value) => Validators.required(value, l10n.changePasswordDialogCurrentLabel),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.changePasswordDialogNewLabel,
              controller: _newPassword,
              obscureText: true,
              isRequired: true,
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.changePasswordDialogConfirmLabel,
              controller: _confirmPassword,
              obscureText: true,
              isRequired: true,
              validator: (value) => Validators.passwordConfirmation(value, _newPassword.text),
            ),
          ],
        ),
      ),
    );
  }
}
