import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/catalog_service.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/state_views.dart';

/// Izmjena vlastitog profila.
///
/// Lozinka se ovdje ne trazi - mijenja se na zasebnom ekranu uz potvrdu stare lozinke.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  DateTime? _birthDate;
  Lookup? _selectedCity;
  List<Lookup> _cities = const [];

  File? _newPhoto;
  String? _currentImageUrl;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  final Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final cities = await context.read<CatalogService>().lookup('Cities');
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      setState(() {
        _cities = cities;

        if (user != null) {
          _firstName.text = user.firstName;
          _lastName.text = user.lastName;
          _email.text = user.email;
          _phone.text = user.phone ?? '';
          _birthDate = user.birthDate;
          _currentImageUrl = user.profileImageUrl;

          for (final city in cities) {
            if (city.id == user.cityId) {
              _selectedCity = city;
              break;
            }
          }
        }

        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (picked == null || !mounted) return;
      setState(() => _newPhoto = File(picked.path));
    } on Exception {
      if (mounted) {
        AppFeedback.error(context, AppLocalizations.of(context)!.imagePickFailedMessage);
      }
    }
  }

  Future<void> _removePhoto() async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: t.removeImageConfirmTitle,
      message: t.removeImageConfirmMessage,
      confirmLabel: t.removePhotoAction,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _newPhoto = null;
      _currentImageUrl = null;
    });
  }

  Future<void> _submit() async {
    setState(_serverErrors.clear);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();

      // Nova slika se prvo salje, pa se putanja sprema uz profil.
      var imageUrl = _currentImageUrl;
      if (_newPhoto != null) {
        imageUrl = await authService.uploadProfileImage(_newPhoto!);
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
      Navigator.of(context).pop();
      AppFeedback.success(context, AppLocalizations.of(context)!.profileUpdateSuccessMessage);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        for (final entry in error.fieldErrors.entries) {
          if (entry.value.isNotEmpty) {
            _serverErrors[entry.key.toLowerCase()] = entry.value.first;
          }
        }
      });

      _formKey.currentState?.validate();

      if (_serverErrors.isEmpty) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _serverError(String field) => _serverErrors[field.toLowerCase()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editProfileAppBarTitle)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 4, height: 100);

    if (_loadError != null) {
      return ErrorStateView(message: _loadError!, onRetry: _load);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          Center(
            child: _AvatarPicker(
              newPhoto: _newPhoto,
              currentImageUrl: _currentImageUrl,
              initials: context.read<AuthProvider>().user?.initials ?? '?',
              onPick: _pickPhoto,
              onRemove: _removePhoto,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppTextField(
            label: t.fieldFirstNameLabel,
            controller: _firstName,
            prefixIcon: Icons.badge_outlined,
            isRequired: true,
            validator: (value) => _serverError('firstName') ?? Validators.name(value, 'Ime'),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: t.fieldLastNameLabel,
            controller: _lastName,
            prefixIcon: Icons.badge_outlined,
            isRequired: true,
            validator: (value) =>
                _serverError('lastName') ?? Validators.name(value, 'Prezime'),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: t.fieldEmailLabel,
            controller: _email,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            validator: (value) => _serverError('email') ?? Validators.email(value),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: t.fieldPhoneLabel,
            controller: _phone,
            hint: t.fieldPhoneHint,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => _serverError('phone') ?? Validators.phone(value),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppDateField(
            label: t.fieldBirthDateLabel,
            value: _birthDate,
            lastDate: DateTime.now(),
            onChanged: (value) => setState(() => _birthDate = value),
            hint: t.dateFieldSelectHint,
          ),
          const SizedBox(height: AppSpacing.xl),

          AppDropdownField<Lookup>(
            label: t.fieldCityLabel,
            items: _cities,
            value: _selectedCity,
            itemLabel: (city) => city.name,
            prefixIcon: Icons.location_city_rounded,
            hint: t.cityDropdownHint,
            emptyHint: t.editProfileCitiesUnavailable,
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(height: AppSpacing.xxl),

          BusyButton(
            label: t.saveChangesButton,
            icon: Icons.save_outlined,
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
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.newPhoto,
    required this.currentImageUrl,
    required this.initials,
    required this.onPick,
    required this.onRemove,
  });

  final File? newPhoto;
  final String? currentImageUrl;
  final String initials;
  final void Function(ImageSource source) onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final resolved = AppConfig.resolveImageUrl(currentImageUrl);
    final hasImage = newPhoto != null || resolved.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: newPhoto != null
                  ? FileImage(newPhoto!)
                  : (resolved.isEmpty ? null : NetworkImage(resolved) as ImageProvider),
              onBackgroundImageError: hasImage ? (_, _) {} : null,
              child: hasImage
                  ? null
                  : Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showPicker(context),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: AppSizes.iconSm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasImage) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm),
            label: Text(t.removePhotoAction),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          ),
        ],
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(t.pickerCameraOption),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(t.pickerGalleryOption),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
