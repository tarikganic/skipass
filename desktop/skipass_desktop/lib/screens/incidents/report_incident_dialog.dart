import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

enum _Target { trail, lift }

/// Prijava problema/incidenta od strane osoblja - dostupno iz bocne navigacije.
class ReportIncidentDialog extends StatefulWidget {
  const ReportIncidentDialog({super.key});

  @override
  State<ReportIncidentDialog> createState() => _ReportIncidentDialogState();
}

class _ReportIncidentDialogState extends State<ReportIncidentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();

  List<Lookup> _incidentTypes = const [];
  List<Lookup> _trails = const [];
  List<Lookup> _lifts = const [];

  Lookup? _selectedType;
  Lookup? _selectedTarget;
  _Target _target = _Target.trail;
  File? _image;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final referenceService = context.read<ReferenceDataService>();
    final resortService = context.read<ResortService>();

    final results = await Future.wait([
      referenceService.lookup('IncidentTypes'),
      resortService.searchTrails(pageSize: 100),
      resortService.searchLifts(pageSize: 100),
    ]);

    if (!mounted) return;

    final incidentTypes = results[0] as List<Lookup>;
    final trails = (results[1] as dynamic).items.map<Lookup>((t) => Lookup(id: t.id, name: t.name)).toList();
    final lifts = (results[2] as dynamic).items.map<Lookup>((l) => Lookup(id: l.id, name: l.name)).toList();

    setState(() {
      _incidentTypes = incidentTypes;
      _trails = trails;
      _lifts = lifts;
      _selectedType = incidentTypes.isEmpty ? null : incidentTypes.first;
      _selectedTarget = trails.isEmpty ? null : trails.first;
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
    setState(() => _image = File(file.path));
  }

  Future<void> _removeImage() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.removeImageConfirmTitle,
      message: l10n.removeImageConfirmMessage,
      confirmLabel: l10n.removeImageAction,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _image = null);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final resortService = context.read<ResortService>();
      final engagementService = context.read<EngagementService>();

      String? imageUrl;
      if (_image != null) {
        imageUrl = await resortService.uploadImage('incidents', _image!);
      }

      await engagementService.createIncident({
        'incidentTypeId': _selectedType!.id,
        'description': _description.text.trim(),
        'imageUrl': imageUrl,
        'latitude': 0,
        'longitude': 0,
        'trailId': _target == _Target.trail ? _selectedTarget!.id : null,
        'skiLiftId': _target == _Target.lift ? _selectedTarget!.id : null,
      });

      if (!mounted) return;
      AppFeedback.success(context, AppLocalizations.of(context)!.reportIncidentDialogSuccess);
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = _target == _Target.trail ? _trails : _lifts;
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.sideNavReportIncident,
      subtitle: l10n.reportIncidentDialogSubtitle,
      actions: [BusyButton(label: l10n.reportIncidentDialogSubmitButton, icon: Icons.send_rounded, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDropdownField<Lookup>(
                    label: l10n.reportIncidentDialogTypeLabel,
                    items: _incidentTypes,
                    value: _selectedType,
                    isRequired: true,
                    itemLabel: (t) => t.name,
                    validator: (value) =>
                        value == null ? l10n.selectFieldRequiredError(l10n.reportIncidentDialogTypeLabel) : null,
                    onChanged: (value) => setState(() => _selectedType = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<_Target>(
                    segments: [
                      ButtonSegment(value: _Target.trail, label: Text(l10n.reportIncidentDialogTrailSegment), icon: const Icon(Icons.downhill_skiing_outlined)),
                      ButtonSegment(value: _Target.lift, label: Text(l10n.reportIncidentDialogLiftSegment), icon: const Icon(Icons.cable_rounded)),
                    ],
                    selected: {_target},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _target = selection.first;
                        final list = _target == _Target.trail ? _trails : _lifts;
                        _selectedTarget = list.isEmpty ? null : list.first;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDropdownField<Lookup>(
                    label: _target == _Target.trail ? l10n.reportIncidentDialogTrailSegment : l10n.reportIncidentDialogLiftSegment,
                    items: targets,
                    value: _selectedTarget,
                    isRequired: true,
                    itemLabel: (t) => t.name,
                    emptyHint: l10n.reportIncidentDialogNoRecords,
                    validator: (value) => value == null
                        ? l10n.selectFieldRequiredError(
                            _target == _Target.trail ? l10n.reportIncidentDialogTrailSegment : l10n.reportIncidentDialogLiftSegment)
                        : null,
                    onChanged: (value) => setState(() => _selectedTarget = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: l10n.reportIncidentDialogDescriptionLabel,
                    controller: _description,
                    maxLines: 4,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.reportIncidentDialogDescriptionLabel, min: 10, max: 2000),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_outlined, size: AppSizes.iconSm),
                        label: Text(_image == null ? l10n.reportIncidentDialogAddPhoto : l10n.reportIncidentDialogPhotoSelected),
                      ),
                      if (_image != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                          tooltip: l10n.removeImageAction,
                          onPressed: _removeImage,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
