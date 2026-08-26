import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ski_lift.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/status_chip.dart';

/// Prijava kvara ski lifta i evidencija odrzavanja.
///
/// Prijava kvara koji zahtijeva obustavu rada odmah gasi lift na serverskoj strani;
/// evidencija se osvjezava nakon zatvaranja dijaloga.
class LiftMaintenanceDialog extends StatefulWidget {
  const LiftMaintenanceDialog({super.key, required this.lift});

  final SkiLift lift;

  @override
  State<LiftMaintenanceDialog> createState() => _LiftMaintenanceDialogState();
}

class _LiftMaintenanceDialogState extends State<LiftMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();

  bool _requiresShutdown = false;
  bool _isSubmitting = false;
  bool _changed = false;

  List<LiftMaintenanceRecord> _records = const [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final page = await context.read<ResortService>().searchMaintenance(skiLiftId: widget.lift.id, pageSize: 20);
    if (!mounted) return;
    setState(() {
      _records = page.items;
      _isLoadingHistory = false;
    });
  }

  Future<void> _report() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<ResortService>().reportMaintenance({
        'skiLiftId': widget.lift.id,
        'description': _description.text.trim(),
        'requiresShutdown': _requiresShutdown,
      });

      _description.clear();
      setState(() => _requiresShutdown = false);
      _changed = true;
      await _loadHistory();
      if (mounted) AppFeedback.success(context, AppLocalizations.of(context)!.liftMaintenanceDialogReportSuccess);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _changeStatus(LiftMaintenanceRecord record, String status) async {
    final l10n = AppLocalizations.of(context)!;
    String? note;

    if (status == 'Completed' || status == 'Cancelled') {
      note = await AppFeedback.promptReason(
        context,
        title: status == 'Completed' ? l10n.liftMaintenanceDialogCompleteTitle : l10n.liftMaintenanceDialogCancelTitle,
        label: l10n.liftMaintenanceDialogReasonLabel,
        confirmLabel: l10n.commonConfirm,
      );
      if (note == null) return;
    }

    try {
      await context.read<ResortService>().updateMaintenanceStatus(record.id, status, note);
      _changed = true;
      await _loadHistory();
      if (mounted) AppFeedback.success(context, l10n.liftMaintenanceDialogStatusUpdateSuccess);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.liftMaintenanceDialogTitle(widget.lift.name),
      width: AppSizes.wideDialogWidth,
      actions: [
        FilledButton(onPressed: () => Navigator.of(context).pop(_changed), child: Text(l10n.commonClose)),
      ],
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.liftMaintenanceDialogDescriptionLabel,
                    controller: _description,
                    maxLines: 3,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.liftMaintenanceDialogDescriptionLabel, min: 5, max: 1000),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.liftMaintenanceDialogShutdownSwitch),
                    value: _requiresShutdown,
                    onChanged: (value) => setState(() => _requiresShutdown = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BusyButton(label: l10n.liftMaintenanceDialogReportButton, icon: Icons.report_problem_outlined, isBusy: _isSubmitting, onPressed: _report),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.liftMaintenanceDialogHistoryTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_isLoadingHistory)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(l10n.liftMaintenanceDialogHistoryEmpty, style: theme.textTheme.bodySmall),
              )
            else
              ..._records.map((record) => _MaintenanceRow(record: record, onStatusChange: (status) => _changeStatus(record, status))),
          ],
        ),
    );
  }
}

class _MaintenanceRow extends StatelessWidget {
  const _MaintenanceRow({required this.record, required this.onStatusChange});

  final LiftMaintenanceRecord record;
  final ValueChanged<String> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(record.description, style: theme.textTheme.bodyMedium)),
                StatusChip(style: _statusStyle(l10n, record.status), compact: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${Formatters.dateTime(record.reportedAt)} · ${record.reportedByUserName}'
              '${record.requiresShutdown ? ' · ${l10n.liftMaintenanceDialogShutdownSuffix}' : ''}',
              style: theme.textTheme.labelSmall,
            ),
            if (record.resolutionNote != null) ...[
              const SizedBox(height: 4),
              Text(record.resolutionNote!, style: theme.textTheme.bodySmall),
            ],
            if (record.allowedNextStatuses.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: record.allowedNextStatuses
                    .map(
                      (status) => OutlinedButton(
                        onPressed: () => onStatusChange(status),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                        child: Text(_statusActionLabel(l10n, status), style: theme.textTheme.labelSmall),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  StatusStyle _statusStyle(AppLocalizations l10n, String status) => switch (status) {
        'Reported' => StatusStyle(label: l10n.liftMaintenanceStatusReported, color: AppColors.warning, background: AppColors.warningSurface, icon: Icons.report_outlined),
        'InProgress' => StatusStyle(label: l10n.liftMaintenanceStatusInProgress, color: AppColors.info, background: AppColors.infoSurface, icon: Icons.autorenew_rounded),
        'Completed' => StatusStyle(label: l10n.liftMaintenanceStatusCompleted, color: AppColors.success, background: AppColors.successSurface, icon: Icons.check_circle_rounded),
        _ => StatusStyle(label: l10n.liftMaintenanceStatusCancelled, color: AppColors.textSecondary, background: AppColors.surfaceAlt, icon: Icons.block_rounded),
      };

  String _statusActionLabel(AppLocalizations l10n, String status) => switch (status) {
        'InProgress' => l10n.liftMaintenanceActionStart,
        'Completed' => l10n.commonComplete,
        'Cancelled' => l10n.commonCancel,
        _ => status,
      };
}
