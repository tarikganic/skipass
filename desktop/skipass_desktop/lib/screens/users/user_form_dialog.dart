import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

const _roles = ['Skier', 'Staff', 'Admin'];

Map<String, String> _roleLabels(AppLocalizations l10n) => {
      'Skier': l10n.roleSkier,
      'Staff': l10n.roleStaff,
      'Admin': l10n.roleAdmin,
    };

/// Kreiranje ili izmjena korisnika - dostupno samo administratoru.
class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.existing});

  final AppUser? existing;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _username = TextEditingController(text: widget.existing?.username ?? '');
  late final _firstName = TextEditingController(text: widget.existing?.firstName ?? '');
  late final _lastName = TextEditingController(text: widget.existing?.lastName ?? '');
  late final _email = TextEditingController(text: widget.existing?.email ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  late String _role = widget.existing?.role ?? 'Staff';
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _username.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final service = context.read<UserService>();
      AppUser result;

      if (_isEditing) {
        final body = {
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          'role': _role,
          'isActive': _isActive,
          'newPassword': _password.text.trim().isEmpty ? null : _password.text.trim(),
          'confirmNewPassword': _confirmPassword.text.trim().isEmpty ? null : _confirmPassword.text.trim(),
        };
        result = await service.update(widget.existing!.id, body);
      } else {
        final body = {
          'username': _username.text.trim(),
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          'role': _role,
          'isActive': _isActive,
          'password': _password.text.trim(),
          'confirmPassword': _confirmPassword.text.trim(),
        };
        result = await service.create(body);
      }

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roleLabels = _roleLabels(l10n);

    return AppDialog(
      title: _isEditing ? l10n.userFormDialogEditTitle : l10n.usersScreenAddButton,
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isEditing) ...[
              AppTextField(label: l10n.loginScreenUsernameLabel, controller: _username, isRequired: true, validator: Validators.username),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.profileDialogFirstNameLabel,
                    controller: _firstName,
                    isRequired: true,
                    validator: (value) => Validators.name(value, l10n.profileDialogFirstNameLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(
                    label: l10n.profileDialogLastNameLabel,
                    controller: _lastName,
                    isRequired: true,
                    validator: (value) => Validators.name(value, l10n.profileDialogLastNameLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.profileDialogEmailLabel,
                    controller: _email,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(label: l10n.profileDialogPhoneLabel, controller: _phone, keyboardType: TextInputType.phone, validator: Validators.phone),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField<String>(
              label: l10n.userFormDialogRoleLabel,
              items: _roles,
              value: _role,
              isRequired: true,
              itemLabel: (r) => roleLabels[r] ?? r,
              onChanged: (value) => setState(() => _role = value ?? _role),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: _isEditing ? l10n.userFormDialogNewPasswordLabel : l10n.loginScreenPasswordLabel,
                    controller: _password,
                    obscureText: true,
                    isRequired: !_isEditing,
                    validator: (value) {
                      if (_isEditing && (value == null || value.trim().isEmpty)) return null;
                      return Validators.password(value);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(
                    label: l10n.userFormDialogConfirmPasswordLabel,
                    controller: _confirmPassword,
                    obscureText: true,
                    isRequired: !_isEditing,
                    validator: (value) {
                      if (_isEditing && _password.text.trim().isEmpty && (value == null || value.trim().isEmpty)) return null;
                      return Validators.passwordConfirmation(value, _password.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.userFormDialogActiveSwitch),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
    );
  }
}
