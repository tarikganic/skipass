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
import 'forgot_password_screen.dart';
import 'register_screen.dart';

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

  /// Greske koje je server vratio po polju; brisu se cim korisnik ispravi unos.
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

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
      // Preusmjeravanje obavlja korijenski widget koji prati stanje prijave.
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _usernameServerError = error.errorFor('username');
        _passwordServerError = error.errorFor('password');
      });

      // Polja se ponovo validiraju da bi se serverske poruke prikazale ispod njih.
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _AuthHeader(
                      title: t.loginHeaderTitle,
                      subtitle: t.loginHeaderSubtitle,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.lg,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                label: t.fieldUsernameLabel,
                                controller: _usernameController,
                                hint: t.loginUsernameHint,
                                prefixIcon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                isRequired: true,
                                autofillHints: const [AutofillHints.username],
                                validator: (value) =>
                                    _usernameServerError ??
                                    Validators.required(value, 'Korisnicko ime'),
                                onChanged: (_) {
                                  if (_usernameServerError != null) {
                                    setState(() => _usernameServerError = null);
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppTextField(
                                label: t.fieldPasswordLabel,
                                controller: _passwordController,
                                hint: t.loginPasswordHint,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                isRequired: true,
                                autofillHints: const [AutofillHints.password],
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  tooltip: _obscurePassword
                                      ? t.showPasswordTooltip
                                      : t.hidePasswordTooltip,
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (value) =>
                                    _passwordServerError ??
                                    Validators.required(value, 'Lozinka'),
                                onChanged: (_) {
                                  if (_passwordServerError != null) {
                                    setState(() => _passwordServerError = null);
                                  }
                                },
                                onSubmitted: (_) => _submit(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => const ForgotPasswordScreen(),
                                            ),
                                          ),
                                  child: Text(t.loginForgotPasswordLink),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              BusyButton(
                                label: t.loginSubmitButton,
                                icon: Icons.login_rounded,
                                isBusy: _isSubmitting,
                                onPressed: _submit,
                              ),
                              const Spacer(),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(t.loginNoAccountLabel, style: theme.textTheme.bodyMedium),
                                  TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => const RegisterScreen(),
                                              ),
                                            ),
                                    child: Text(t.loginRegisterLink),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zajednicko zaglavlje ekrana prijave i registracije.
class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxxl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl + 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.downhill_skiing_rounded,
                  color: Colors.white,
                  size: AppSizes.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'SkiPass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Zaglavlje dostupno i drugim ekranima autentifikacije.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => _AuthHeader(title: title, subtitle: subtitle);
}
