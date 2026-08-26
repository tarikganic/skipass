import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/ski_lift.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena ski lifta.
class SkiLiftFormDialog extends StatefulWidget {
  const SkiLiftFormDialog({super.key, this.existing});

  final SkiLift? existing;

  @override
  State<SkiLiftFormDialog> createState() => _SkiLiftFormDialogState();
}

class _SkiLiftFormDialogState extends State<SkiLiftFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _code = TextEditingController(text: widget.existing?.code ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _length = TextEditingController(text: widget.existing?.lengthMeters.toString() ?? '');
  late final _capacity = TextEditingController(text: widget.existing?.capacityPerHour.toString() ?? '');
  late final _duration = TextEditingController(text: widget.existing?.rideDurationMinutes.toString() ?? '');

  late bool _isOperational = widget.existing?.isOperational ?? true;

  List<Lookup> _resorts = const [];
  List<Lookup> _liftTypes = const [];
  Lookup? _selectedResort;
  Lookup? _selectedLiftType;

  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _length.dispose();
    _capacity.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final resortService = context.read<ResortService>();
    final referenceService = context.read<ReferenceDataService>();

    final results = await Future.wait([
      resortService.searchResorts(pageSize: 50),
      referenceService.lookup('LiftTypes'),
    ]);

    if (!mounted) return;

    final List<Lookup> resorts = (results[0] as dynamic).items.map<Lookup>((r) => Lookup(id: r.id, name: r.name)).toList();
    final liftTypes = results[1] as List<Lookup>;

    setState(() {
      _resorts = resorts;
      _liftTypes = liftTypes;
      _selectedResort = widget.existing == null
          ? (resorts.isEmpty ? null : resorts.first)
          : resorts.where((r) => r.id == widget.existing!.skiResortId).firstOrNull ?? (resorts.isEmpty ? null : resorts.first);
      _selectedLiftType = liftTypes.isEmpty ? null : liftTypes.first;
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final body = {
      'name': _name.text.trim(),
      'code': _code.text.trim().toUpperCase(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'lengthMeters': int.parse(_length.text.trim()),
      'capacityPerHour': int.parse(_capacity.text.trim()),
      'rideDurationMinutes': int.parse(_duration.text.trim()),
      'isOperational': _isOperational,
      'skiResortId': _selectedResort!.id,
      'liftTypeId': _selectedLiftType!.id,
    };

    try {
      final service = context.read<ResortService>();
      final result = _isEditing ? await service.updateLift(widget.existing!.id, body) : await service.createLift(body);
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

    return AppDialog(
      title: _isEditing ? l10n.skiLiftFormDialogEditTitle : l10n.skiLiftFormDialogNewTitle,
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          label: l10n.skiLiftFormDialogNameLabel,
                          controller: _name,
                          isRequired: true,
                          validator: (value) => Validators.lengthRange(value, l10n.skiLiftFormDialogNameLabel, min: 2, max: 150),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.commonCodeLabel,
                          controller: _code,
                          hint: l10n.skiLiftFormDialogCodeHint,
                          isRequired: true,
                          validator: (value) => Validators.lengthRange(value, l10n.commonCodeLabel, min: 2, max: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(label: l10n.commonDescriptionLabel, controller: _description, maxLines: 2, maxLength: 1000),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<Lookup>(
                          label: l10n.commonResortLabel,
                          items: _resorts,
                          value: _selectedResort,
                          isRequired: true,
                          itemLabel: (r) => r.name,
                          validator: (value) => value == null ? l10n.selectFieldRequiredError(l10n.commonResortLabel) : null,
                          onChanged: (value) => setState(() => _selectedResort = value),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppDropdownField<Lookup>(
                          label: l10n.skiLiftFormDialogLiftTypeLabel,
                          items: _liftTypes,
                          value: _selectedLiftType,
                          isRequired: true,
                          itemLabel: (t) => t.name,
                          validator: (value) =>
                              value == null ? l10n.selectFieldRequiredError(l10n.skiLiftFormDialogLiftTypeLabel) : null,
                          onChanged: (value) => setState(() => _selectedLiftType = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.commonLengthLabel,
                          controller: _length,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateIntRange(value, l10n.commonLengthShort, min: 50, max: 20000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.skiLiftFormDialogCapacityLabel,
                          controller: _capacity,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateIntRange(value, l10n.skiLiftFormDialogCapacityShort, min: 1, max: 10000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.skiLiftFormDialogDurationLabel,
                          controller: _duration,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateIntRange(value, l10n.skiLiftFormDialogDurationShort, min: 1, max: 120),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.skiLiftFormDialogOperationalSwitch),
                    value: _isOperational,
                    onChanged: (value) => setState(() => _isOperational = value),
                  ),
                ],
              ),
            ),
    );
  }

  String? _validateIntRange(String? value, String label, {required int min, required int max}) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) return l10n.commonIntRequiredMessage(label);
    if (parsed < min || parsed > max) return l10n.commonIntRangeMessage(label, min, max);
    return null;
  }
}
