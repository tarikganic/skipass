import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/trail.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/status_chip.dart';

/// Evidentiranje stanja staze (snijeg, uslovi) i pregled historije.
///
/// Novo evidentiranje istovremeno postavlja i status staze na serveru,
/// pa se lista automatski osvjezava nakon uspjesnog unosa.
class TrailConditionDialog extends StatefulWidget {
  const TrailConditionDialog({super.key, required this.trail});

  final Trail trail;

  @override
  State<TrailConditionDialog> createState() => _TrailConditionDialogState();
}

class _TrailConditionDialogState extends State<TrailConditionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _snowDepth = TextEditingController();
  final _note = TextEditingController();

  bool _isTrailOpen = true;
  bool _isSubmitting = false;
  List<TrailConditionLog> _history = const [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _isTrailOpen = widget.trail.isOpen;
    _loadHistory();
  }

  @override
  void dispose() {
    _snowDepth.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final page = await context.read<ResortService>().searchTrailConditions(widget.trail.id, pageSize: 10);
    if (!mounted) return;
    setState(() {
      _history = page.items;
      _isLoadingHistory = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<ResortService>().addTrailCondition({
        'trailId': widget.trail.id,
        'snowDepthCm': int.parse(_snowDepth.text.trim()),
        'conditionNote': _note.text.trim(),
        'isTrailOpen': _isTrailOpen,
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.trailConditionDialogTitle(widget.trail.name),
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.trailConditionDialogSaveButton, isBusy: _isSubmitting, onPressed: _submit)],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.trailConditionDialogSnowDepthLabel,
                    controller: _snowDepth,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null || parsed < 0 || parsed > 800) {
                        return l10n.trailConditionDialogSnowDepthError;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.trailConditionDialogOpenSwitch),
                    value: _isTrailOpen,
                    onChanged: (value) => setState(() => _isTrailOpen = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.trailConditionDialogNoteLabel,
              controller: _note,
              maxLines: 2,
              isRequired: true,
              hint: l10n.trailConditionDialogNoteHint,
              validator: (value) => Validators.lengthRange(value, l10n.trailConditionDialogNoteLabel, min: 3, max: 500),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.trailConditionDialogHistoryTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_isLoadingHistory)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(l10n.trailConditionDialogHistoryEmpty, style: theme.textTheme.bodySmall),
              )
            else
              ..._history.map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Text(l10n.trailConditionDialogSnowDepthValue(log.snowDepthCm), style: theme.textTheme.titleSmall),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.conditionNote, style: theme.textTheme.bodySmall),
                              Text(
                                '${Formatters.dateTime(log.recordedAt)} · ${log.recordedByUserName}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        StatusChip(style: StatusStyles.openClosed(isOpen: log.isTrailOpen), compact: true),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
