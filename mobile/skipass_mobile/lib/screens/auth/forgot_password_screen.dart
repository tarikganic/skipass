import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Reset lozinke u dva koraka: slanje koda pa unos nove lozinke.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _token = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _codeSent = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  /// U razvojnom okruzenju API vraca kod direktno, jer e-mail servis dolazi u narednoj fazi.
  String? _developmentToken;
  String? _tokenServerError;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!(_requestFormKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final token = await context.read<AuthService>().forgotPassword(_email.text.trim());
      if (!mounted) return;

      setState(() {
        _codeSent = true;
        _developmentToken = token;
        if (token != null) _token.text = token;
      });

      AppFeedback.info(
        context,
        AppLocalizations.of(context)!.forgotPasswordCodeSentInfo,
      );
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _tokenServerError = null);

    if (!(_resetFormKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().resetPassword(
            email: _email.text.trim(),
            token: _token.text.trim(),
            newPassword: _newPassword.text,
            confirmNewPassword: _confirmPassword.text,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppFeedback.success(
        context,
        AppLocalizations.of(context)!.forgotPasswordSuccessMessage,
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() => _tokenServerError = error.errorFor('token'));
      _resetFormKey.currentState?.validate();

      if (_tokenServerError == null) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.forgotPasswordAppBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          children: [
            Text(
              _codeSent ? t.forgotPasswordHeadingReset : t.forgotPasswordHeadingRequest,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _codeSent ? t.forgotPasswordSubtitleReset : t.forgotPasswordSubtitleRequest,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),

            Form(
              key: _requestFormKey,
              child: AppTextField(
                label: t.fieldEmailLabel,
                controller: _email,
                hint: t.emailHintExample,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                enabled: !_codeSent,
                isRequired: true,
                validator: Validators.email,
              ),
            ),

            if (!_codeSent) ...[
              const SizedBox(height: AppSpacing.xxl),
              BusyButton(
                label: t.forgotPasswordSendCodeButton,
                icon: Icons.send_rounded,
                isBusy: _isSubmitting,
                onPressed: _requestCode,
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xl),

              if (_developmentToken != null) _DevelopmentTokenNotice(token: _developmentToken!),

              Form(
                key: _resetFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: t.forgotPasswordResetCodeLabel,
                      controller: _token,
                      prefixIcon: Icons.key_outlined,
                      maxLines: 2,
                      isRequired: true,
                      validator: (value) =>
                          _tokenServerError ?? Validators.required(value, 'Kod za reset'),
                      onChanged: (_) {
                        if (_tokenServerError != null) {
                          setState(() => _tokenServerError = null);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: t.fieldNewPasswordLabel,
                      controller: _newPassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      isRequired: true,
                      helperText: t.passwordMinLengthHelper,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) =>
                          Validators.password(value, fieldName: 'Nova lozinka'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: t.fieldConfirmNewPasswordLabel,
                      controller: _confirmPassword,
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: _obscurePassword,
                      isRequired: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          Validators.passwordConfirmation(value, _newPassword.text),
                      onSubmitted: (_) => _resetPassword(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    BusyButton(
                      label: t.forgotPasswordSetNewButton,
                      icon: Icons.check_rounded,
                      isBusy: _isSubmitting,
                      onPressed: _resetPassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() {
                                _codeSent = false;
                                _developmentToken = null;
                                _token.clear();
                              }),
                      child: Text(t.forgotPasswordResendOtherAddress),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vidljivo samo dok API radi u razvojnom okruzenju.
class _DevelopmentTokenNotice extends StatelessWidget {
  const _DevelopmentTokenNotice({required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: AppCard(
        backgroundColor: AppColors.warningSurface,
        borderColor: AppColors.warning.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.construction_rounded,
                  size: AppSizes.iconMd,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    t.devNoticeTitle,
                    style: theme.textTheme.titleSmall?.copyWith(color: AppColors.warning),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: AppSizes.iconSm),
                  tooltip: t.devNoticeCopyTooltip,
                  color: AppColors.warning,
                  onPressed: () => Clipboard.setData(ClipboardData(text: token)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.devNoticeBody,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
