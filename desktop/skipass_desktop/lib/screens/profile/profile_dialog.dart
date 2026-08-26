import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/auth_service.dart';
import '../../services/reference_data_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import 'change_password_dialog.dart';

/// Profil prijavljenog korisnika (osoblje/administrator).
class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  DateTime? _birthDate;
  Lookup? _selectedCity;
  List<Lookup> _cities = const [];
  String? _imageUrl;
  File? _newImage;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstName.text = user?.firstName ?? '';
    _lastName.text = user?.lastName ?? '';
    _email.text = user?.email ?? '';
    _phone.text = user?.phone ?? '';
    _birthDate = user?.birthDate;
    _imageUrl = user?.profileImageUrl;
    _loadCities(user?.cityId);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadCities(int? currentCityId) async {
    final cities = await context.read<ReferenceDataService>().lookup('Cities');
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _selectedCity = currentCityId == null ? null : cities.where((c) => c.id == currentCityId).firstOrNull;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final typeGroup = XTypeGroup(
      label: AppLocalizations.of(context)!.commonImageTypeLabel,
      extensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    setState(() => _newImage = File(file.path));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();

      var imageUrl = _imageUrl;
      if (_newImage != null) {
        imageUrl = await authService.uploadProfileImage(_newImage!);
      }

      final updated = await authService.updateProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        birthDate: _birthDate,
        profileImageUrl: imageUrl,
        cityId: _selectedCity?.id,
      );

      if (!mounted) return;
      context.read<AuthProvider>().applyUpdatedUser(updated);
      AppFeedback.success(context, AppLocalizations.of(context)!.profileDialogUpdateSuccess);
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.profileDialogLogout,
      message: l10n.profileDialogLogoutConfirmMessage,
    );
    if (!confirmed || !mounted) return;

    Navigator.of(context).pop();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final resolved = AppConfig.resolveImageUrl(_imageUrl);
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.profileDialogTitle,
      subtitle: user?.role == 'Admin' ? l10n.roleAdmin : l10n.roleStaff,
      width: AppSizes.wideDialogWidth,
      actions: [
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: AppSizes.iconSm, color: AppColors.danger),
          label: Text(l10n.profileDialogLogout, style: const TextStyle(color: AppColors.danger)),
        ),
        BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit),
      ],
      child: _isLoading
          ? const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primarySurface,
                        backgroundImage: _newImage != null
                            ? FileImage(_newImage!)
                            : (resolved.isEmpty ? null : NetworkImage(resolved) as ImageProvider),
                        child: (_newImage == null && resolved.isEmpty)
                            ? Text(user?.initials ?? '?', style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w700))
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_outlined, size: AppSizes.iconSm),
                        label: Text(l10n.profileDialogChangePhoto),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                  Row(
                    children: [
                      Expanded(
                        child: AppDateField(
                          label: l10n.profileDialogBirthDateLabel,
                          value: _birthDate,
                          lastDate: DateTime.now(),
                          onChanged: (value) => setState(() => _birthDate = value),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppDropdownField<Lookup>(
                          label: l10n.profileDialogCityLabel,
                          items: _cities,
                          value: _selectedCity,
                          itemLabel: (c) => c.name,
                          onChanged: (value) => setState(() => _selectedCity = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<Locale>(
                          label: AppLocalizations.of(context)!.languageLabel,
                          items: const [Locale('bs'), Locale('en')],
                          value: context.watch<LocaleProvider>().locale,
                          itemLabel: (locale) => locale.languageCode == 'bs'
                              ? AppLocalizations.of(context)!.languageBosnian
                              : AppLocalizations.of(context)!.languageEnglish,
                          onChanged: (value) {
                            if (value != null) context.read<LocaleProvider>().setLocale(value);
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => showDialog<void>(context: context, builder: (_) => const ChangePasswordDialog()),
                      icon: const Icon(Icons.lock_outline_rounded, size: AppSizes.iconSm),
                      label: Text(l10n.profileDialogChangePassword),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
