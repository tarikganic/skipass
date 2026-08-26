import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/catalog_service.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  DateTime? _birthDate;
  Lookup? _selectedCity;
  List<Lookup> _cities = const [];

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isLoadingCities = true;

  final Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

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

  /// Gradovi se pune iz baze; korisnik ih bira iz liste, ne unosi kao tekst.
  Future<void> _loadCities() async {
    try {
      final cities = await context.read<CatalogService>().lookup('Cities');
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _submit() async {
    setState(_serverErrors.clear);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().register(
            username: _username.text.trim(),
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            confirmPassword: _confirmPassword.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            birthDate: _birthDate,
            cityId: _selectedCity?.id,
          );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppFeedback.success(context, AppLocalizations.of(context)!.registerSuccessMessage);
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

      if (_serverErrors.isEmpty) {
        AppFeedback.error(context, error.message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _serverError(String field) => _serverErrors[field.toLowerCase()];

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field.toLowerCase())) {
      setState(() => _serverErrors.remove(field.toLowerCase()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eighteenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 18));
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.registerAppBarTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            children: [
              Text(
                t.registerHeading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                t.registerRequiredFieldsNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                label: t.fieldUsernameLabel,
                controller: _username,
                hint: t.registerUsernameHint,
                prefixIcon: Icons.alternate_email_rounded,
                textInputAction: TextInputAction.next,
                isRequired: true,
                validator: (value) => _serverError('username') ?? Validators.username(value),
                onChanged: (_) => _clearServerError('username'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldFirstNameLabel,
                controller: _firstName,
                prefixIcon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                isRequired: true,
                validator: (value) => _serverError('firstName') ?? Validators.name(value, 'Ime'),
                onChanged: (_) => _clearServerError('firstName'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldLastNameLabel,
                controller: _lastName,
                prefixIcon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                isRequired: true,
                validator: (value) =>
                    _serverError('lastName') ?? Validators.name(value, 'Prezime'),
                onChanged: (_) => _clearServerError('lastName'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldEmailLabel,
                controller: _email,
                hint: t.emailHintExample,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                isRequired: true,
                validator: (value) => _serverError('email') ?? Validators.email(value),
                onChanged: (_) => _clearServerError('email'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldPhoneLabel,
                controller: _phone,
                hint: t.fieldPhoneHint,
                helperText: t.registerPhoneHelper,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => _serverError('phone') ?? Validators.phone(value),
                onChanged: (_) => _clearServerError('phone'),
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

              if (_isLoadingCities)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              else
                AppDropdownField<Lookup>(
                  label: t.fieldCityLabel,
                  items: _cities,
                  value: _selectedCity,
                  itemLabel: (city) => city.name,
                  prefixIcon: Icons.location_city_rounded,
                  hint: t.cityDropdownHint,
                  emptyHint: t.registerCitiesUnavailable,
                  onChanged: (value) => setState(() => _selectedCity = value),
                ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldPasswordLabel,
                controller: _password,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                isRequired: true,
                helperText: t.passwordMinLengthHelper,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) => _serverError('password') ?? Validators.password(value),
                onChanged: (_) => _clearServerError('password'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: t.fieldConfirmPasswordLabel,
                controller: _confirmPassword,
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                isRequired: true,
                validator: (value) =>
                    Validators.passwordConfirmation(value, _password.text),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              BusyButton(
                label: t.registerSubmitButton,
                icon: Icons.person_add_alt_rounded,
                isBusy: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: Text(t.registerBackToLogin),
              ),
              // Datum rodjenja se koristi za provjeru uslova kod djecijih i studentskih karata.
              if (_birthDate != null && _birthDate!.isAfter(eighteenYearsAgo)) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t.registerMinorNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
