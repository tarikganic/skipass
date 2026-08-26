import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Prijava za osoblje i administratore skijalista.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _usernameServerError;
  String? _passwordServerError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _usernameServerError = null;
      _passwordServerError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _usernameServerError = error.errorFor('username');
        _passwordServerError = error.errorFor('password');
      });
      _formKey.currentState?.validate();

      if (_usernameServerError == null && _passwordServerError == null) {
        AppFeedback.error(context, error.message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              padding: const EdgeInsets.all(AppSpacing.xxxl * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.downhill_skiing_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        l10n.sideNavAppName,
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    l10n.loginScreenTagline,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, height: 1.3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.loginScreenDescription,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.loginScreenTitle, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.loginScreenSubtitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        AppTextField(
                          label: l10n.loginScreenUsernameLabel,
                          controller: _usernameController,
                          hint: l10n.loginScreenUsernameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          isRequired: true,
                          validator: (value) => _usernameServerError ?? Validators.required(value, l10n.loginScreenUsernameLabel),
                          onChanged: (_) {
                            if (_usernameServerError != null) setState(() => _usernameServerError = null);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: l10n.loginScreenPasswordLabel,
                          controller: _passwordController,
                          hint: l10n.loginScreenPasswordHint,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          isRequired: true,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) => _passwordServerError ?? Validators.required(value, l10n.loginScreenPasswordLabel),
                          onChanged: (_) {
                            if (_passwordServerError != null) setState(() => _passwordServerError = null);
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        BusyButton(label: l10n.loginScreenSubmit, icon: Icons.login_rounded, isBusy: _isSubmitting, onPressed: _submit),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
