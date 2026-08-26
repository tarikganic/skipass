import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../services/order_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import 'qr_scanner_dialog.dart';

/// Rucni unos QR koda karte - koristi se sa citacem barkoda na blagajni
/// ili kada osoblje unese kod direktno.
class ValidateTicketDialog extends StatefulWidget {
  const ValidateTicketDialog({super.key});

  @override
  State<ValidateTicketDialog> createState() => _ValidateTicketDialogState();
}

class _ValidateTicketDialogState extends State<ValidateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qrController = TextEditingController();
  final _focusNode = FocusNode();

  List<Lookup> _lifts = const [];
  Lookup? _selectedLift;
  bool _isLoading = true;
  bool _isSubmitting = false;

  TicketValidationResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _loadLifts();
  }

  @override
  void dispose() {
    _qrController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadLifts() async {
    final lifts = await context.read<ResortService>().searchLifts(pageSize: 100, isOperational: true);
    if (!mounted) return;
    setState(() {
      _lifts = lifts.items.map((l) => Lookup(id: l.id, name: l.name)).toList();
      _selectedLift = _lifts.isEmpty ? null : _lifts.first;
      _isLoading = false;
    });
    _focusNode.requestFocus();
  }

  Future<void> _scanQr() async {
    final scanned = await showDialog<String>(context: context, builder: (_) => const QrScannerDialog());
    if (scanned == null || !mounted) return;
    setState(() => _qrController.text = scanned);
    _submit();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await context.read<OrderService>().validateTicket(_qrController.text.trim(), _selectedLift!.id);
      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _qrController.clear();
      });
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.validateTicketDialogTitle,
      subtitle: l10n.validateTicketDialogSubtitle,
      width: AppSizes.dialogWidth,
      child: _isLoading
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDropdownField<Lookup>(
                    label: l10n.validateTicketDialogLiftLabel,
                    items: _lifts,
                    value: _selectedLift,
                    isRequired: true,
                    itemLabel: (lift) => lift.name,
                    emptyHint: l10n.validateTicketDialogNoLiftsAvailable,
                    validator: (value) =>
                        value == null ? l10n.selectFieldRequiredError(l10n.validateTicketDialogLiftLabel) : null,
                    onChanged: (value) => setState(() => _selectedLift = value),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: l10n.validateTicketDialogQrLabel,
                    controller: _qrController,
                    hint: 'SP-XXXXXXXXXXXXXXXX',
                    prefixIcon: Icons.qr_code_2_rounded,
                    suffix: IconButton(
                      icon: const Icon(Icons.camera_alt_rounded),
                      tooltip: l10n.validateTicketDialogScanTooltip,
                      onPressed: _scanQr,
                    ),
                    isRequired: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => value == null || value.trim().length < 8
                        ? l10n.validateTicketDialogQrMinLengthError
                        : null,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BusyButton(
                    label: l10n.validateTicketDialogSubmitButton,
                    icon: Icons.check_circle_outline_rounded,
                    isBusy: _isSubmitting,
                    onPressed: _submit,
                  ),
                  if (_lastResult != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _ResultBanner(result: _lastResult!),
                  ],
                ],
              ),
            ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result});

  final TicketValidationResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = result.isSuccessful ? AppColors.success : AppColors.danger;
    final background = result.isSuccessful ? AppColors.successSurface : AppColors.dangerSurface;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.isSuccessful ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isSuccessful ? l10n.validateTicketDialogResultValid : l10n.validateTicketDialogResultInvalid,
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                if (result.ticketHolderName != null)
                  Text(l10n.validateTicketDialogHolderLabel(result.ticketHolderName!), style: theme.textTheme.bodySmall),
                if (result.failureReason != null)
                  Text(result.failureReason!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
