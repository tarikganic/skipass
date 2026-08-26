import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/trail.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena ski staze.
class TrailFormDialog extends StatefulWidget {
  const TrailFormDialog({super.key, this.existing});

  final Trail? existing;

  @override
  State<TrailFormDialog> createState() => _TrailFormDialogState();
}

class _TrailFormDialogState extends State<TrailFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _code = TextEditingController(text: widget.existing?.code ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _length = TextEditingController(text: widget.existing?.lengthMeters.toString() ?? '');
  late final _verticalDrop = TextEditingController(text: widget.existing?.verticalDropMeters.toString() ?? '');

  late bool _hasNightSkiing = widget.existing?.hasNightSkiing ?? false;
  late bool _hasSnowmaking = widget.existing?.hasSnowmaking ?? true;
  late bool _isOpen = widget.existing?.isOpen ?? true;

  String? _imageUrl;
  File? _newImage;

  List<Lookup> _resorts = const [];
  List<Lookup> _difficulties = const [];
  Lookup? _selectedResort;
  Lookup? _selectedDifficulty;

  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.existing?.imageUrl;
    _loadReferenceData();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _length.dispose();
    _verticalDrop.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final resortService = context.read<ResortService>();
    final referenceService = context.read<ReferenceDataService>();

    final results = await Future.wait([
      resortService.searchResorts(pageSize: 50),
      referenceService.lookup('TrailDifficulties'),
    ]);

    if (!mounted) return;

    final List<Lookup> resorts = (results[0] as dynamic).items.map<Lookup>((r) => Lookup(id: r.id, name: r.name)).toList();
    final difficulties = results[1] as List<Lookup>;

    setState(() {
      _resorts = resorts;
      _difficulties = difficulties;
      _selectedResort = widget.existing == null
          ? (resorts.isEmpty ? null : resorts.first)
          : resorts.where((r) => r.id == widget.existing!.skiResortId).firstOrNull ?? (resorts.isEmpty ? null : resorts.first);
      _selectedDifficulty = widget.existing == null
          ? (difficulties.isEmpty ? null : difficulties.first)
          : difficulties.where((d) => d.id == widget.existing!.difficultyId).firstOrNull ??
              (difficulties.isEmpty ? null : difficulties.first);
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
    setState(() => _newImage = File(file.path));
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
    setState(() {
      _imageUrl = null;
      _newImage = null;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final resortService = context.read<ResortService>();

      var imageUrl = _imageUrl;
      if (_newImage != null) {
        imageUrl = await resortService.uploadImage('trails', _newImage!);
      }

      final body = {
        'name': _name.text.trim(),
        'code': _code.text.trim().toUpperCase(),
        'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
        'imageUrl': imageUrl,
        'lengthMeters': int.parse(_length.text.trim()),
        'verticalDropMeters': int.parse(_verticalDrop.text.trim()),
        'isOpen': _isOpen,
        'hasNightSkiing': _hasNightSkiing,
        'hasSnowmaking': _hasSnowmaking,
        'skiResortId': _selectedResort!.id,
        'trailDifficultyId': _selectedDifficulty!.id,
      };

      final result = _isEditing
          ? await resortService.updateTrail(widget.existing!.id, body)
          : await resortService.createTrail(body);

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
      title: _isEditing ? l10n.trailFormDialogEditTitle : l10n.trailFormDialogNewTitle,
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImagePickerField(
                    imageUrl: _imageUrl,
                    newImage: _newImage,
                    onPick: _pickImage,
                    onRemove: _removeImage,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          label: l10n.trailFormDialogNameLabel,
                          controller: _name,
                          isRequired: true,
                          validator: (value) => Validators.lengthRange(value, l10n.trailFormDialogNameLabel, min: 2, max: 150),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.commonCodeLabel,
                          controller: _code,
                          hint: l10n.trailFormDialogCodeHint,
                          isRequired: true,
                          validator: (value) => Validators.lengthRange(value, l10n.commonCodeLabel, min: 2, max: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(label: l10n.commonDescriptionLabel, controller: _description, maxLines: 3, maxLength: 1500),
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
                          label: l10n.trailFormDialogDifficultyLabel,
                          items: _difficulties,
                          value: _selectedDifficulty,
                          isRequired: true,
                          itemLabel: (d) => d.name,
                          validator: (value) =>
                              value == null ? l10n.selectFieldRequiredError(l10n.trailFormDialogDifficultyLabel) : null,
                          onChanged: (value) => setState(() => _selectedDifficulty = value),
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
                          validator: (value) => _validateIntRange(value, l10n.commonLengthShort, min: 50, max: 50000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.trailFormDialogVerticalDropLabel,
                          controller: _verticalDrop,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateIntRange(value, l10n.trailFormDialogVerticalDropShort, min: 0, max: 3000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.trailFormDialogOpenSwitch),
                    value: _isOpen,
                    onChanged: (value) => setState(() => _isOpen = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.trailFormDialogNightSkiingSwitch),
                    value: _hasNightSkiing,
                    onChanged: (value) => setState(() => _hasNightSkiing = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.trailFormDialogSnowmakingSwitch),
                    value: _hasSnowmaking,
                    onChanged: (value) => setState(() => _hasSnowmaking = value),
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

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.imageUrl,
    required this.newImage,
    required this.onPick,
    required this.onRemove,
  });

  final String? imageUrl;
  final File? newImage;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final resolved = AppConfig.resolveImageUrl(imageUrl);
    final hasImage = newImage != null || resolved.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.trailFormDialogPhotoLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            image: newImage != null
                ? DecorationImage(image: FileImage(newImage!), fit: BoxFit.cover)
                : (resolved.isEmpty ? null : DecorationImage(image: NetworkImage(resolved), fit: BoxFit.cover)),
          ),
          child: hasImage
              ? null
              : Icon(Icons.image_outlined, size: 40, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_outlined, size: AppSizes.iconSm),
              label: Text(hasImage ? l10n.profileDialogChangePhoto : l10n.trailFormDialogAddPhoto),
            ),
            if (hasImage) ...[
              const SizedBox(width: AppSpacing.md),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm),
                label: Text(l10n.commonRemove),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
