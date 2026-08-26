import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Promjena vlastite lozinke. Trenutna lozinka je obavezna kao potvrda identiteta.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscure = true;
  bool _isSubmitting = false;
  String? _currentPasswordError;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _currentPasswordError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final t = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: t.changePasswordAppBarTitle,
      message: t.changePasswordConfirmDialogMessage,
      confirmLabel: t.changePasswordConfirmButton,
    );

    if (!confirmed || !mounted) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().changePassword(
            currentPassword: _current.text,
            newPassword: _newPassword.text,
            confirmNewPassword: _confirmPassword.text,
          );

      if (!mounted) return;

      // Promjena lozinke ponistava token na serveru, pa slijedi ponovna prijava.
      AppFeedback.success(context, t.changePasswordSuccessMessage);
      await context.read<AuthProvider>().logout();
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() => _currentPasswordError = error.errorFor('currentPassword'));
      _formKey.currentState?.validate();

      if (_currentPasswordError == null) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.changePasswordAppBarTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xl,
            AppSpacing.screen,
            AppSpacing.xxxl,
          ),
          children: [
            AppCard(
              backgroundColor: AppColors.infoSurface,
              borderColor: AppColors.info.withValues(alpha: 0.25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.info,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t.changePasswordSecurityNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppTextField(
              label: t.currentPasswordLabel,
              controller: _current,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              isRequired: true,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (value) =>
                  _currentPasswordError ?? Validators.required(value, 'Trenutna lozinka'),
              onChanged: (_) {
                if (_currentPasswordError != null) {
                  setState(() => _currentPasswordError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            AppTextField(
              label: t.fieldNewPasswordLabel,
              controller: _newPassword,
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscure,
              isRequired: true,
              helperText: t.passwordMinLengthHelper,
              validator: (value) =>
                  Validators.password(value, fieldName: 'Nova lozinka'),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppTextField(
              label: t.fieldConfirmNewPasswordLabel,
              controller: _confirmPassword,
              prefixIcon: Icons.check_circle_outline_rounded,
              obscureText: _obscure,
              isRequired: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  Validators.passwordConfirmation(value, _newPassword.text),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            BusyButton(
              label: t.changePasswordSubmitButton,
              icon: Icons.check_rounded,
              isBusy: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: Text(t.commonDiscard),
            ),
          ],
        ),
      ),
    );
  }
}
