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
import '../../models/announcement.dart';
import '../../models/paged_result.dart';
import '../../services/engagement_service.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena obavijesti.
class AnnouncementFormDialog extends StatefulWidget {
  const AnnouncementFormDialog({super.key, this.existing});

  final Announcement? existing;

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _content = TextEditingController(text: widget.existing?.content ?? '');

  late DateTime _publishedAt = widget.existing?.publishedAt ?? DateTime.now();
  late DateTime? _expiresAt = widget.existing?.expiresAt;
  late bool _isUrgent = widget.existing?.isUrgent ?? false;
  late bool _isActive = widget.existing?.isActive ?? true;
  File? _newImage;
  String? _imageUrl;

  List<Lookup> _categories = const [];
  List<Lookup> _resorts = const [];
  Lookup? _selectedCategory;
  Lookup? _selectedResort;

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
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final referenceService = context.read<ReferenceDataService>();
    final resortService = context.read<ResortService>();

    final results = await Future.wait([
      referenceService.lookup('AnnouncementCategories'),
      resortService.searchResorts(pageSize: 50),
    ]);

    if (!mounted) return;

    final categories = results[0] as List<Lookup>;
    final List<Lookup> resorts = (results[1] as dynamic).items.map<Lookup>((r) => Lookup(id: r.id, name: r.name)).toList();

    setState(() {
      _categories = categories;
      _resorts = resorts;
      _selectedCategory = categories.isEmpty
          ? null
          : (widget.existing == null
              ? categories.first
              : categories.where((c) => c.id == widget.existing!.categoryId).firstOrNull ?? categories.first);
      _selectedResort = resorts.isEmpty
          ? null
          : (widget.existing == null
              ? resorts.first
              : resorts.where((r) => r.id == widget.existing!.skiResortId).firstOrNull ?? resorts.first);
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategory == null || _selectedResort == null) {
      AppFeedback.error(context, l10n.announcementFormDialogSelectRequired);
      return;
    }
    if (_expiresAt != null && !_expiresAt!.isAfter(_publishedAt)) {
      AppFeedback.error(context, l10n.announcementFormDialogExpiryError);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final engagementService = context.read<EngagementService>();

      var imageUrl = _imageUrl;
      if (_newImage != null) {
        imageUrl = await engagementService.uploadImage('announcements', _newImage!);
      }

      final body = {
        'title': _title.text.trim(),
        'content': _content.text.trim(),
        'imageUrl': imageUrl,
        'publishedAt': _publishedAt.toIso8601String(),
        'expiresAt': _expiresAt?.toIso8601String(),
        'isUrgent': _isUrgent,
        'isActive': _isActive,
        'announcementCategoryId': _selectedCategory!.id,
        'skiResortId': _selectedResort!.id,
      };

      final result = _isEditing
          ? await engagementService.updateAnnouncement(widget.existing!.id, body)
          : await engagementService.createAnnouncement(body);

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickPublishedAt() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDatePicker(
      context: context,
      initialDate: _publishedAt,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: l10n.announcementFormDialogPublishedLabel,
      cancelText: l10n.commonDismiss,
      confirmText: l10n.commonConfirm,
    );
    if (selected != null) setState(() => _publishedAt = selected);
  }

  Future<void> _pickExpiresAt() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? _publishedAt.add(const Duration(days: 7)),
      firstDate: _publishedAt,
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: l10n.announcementFormDialogExpiryHelpText,
      cancelText: l10n.commonDismiss,
      confirmText: l10n.commonConfirm,
    );
    if (selected != null) setState(() => _expiresAt = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: _isEditing ? l10n.announcementFormDialogEditTitle : l10n.announcementFormDialogNewTitle,
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.announcementFormDialogTitleLabel,
                    controller: _title,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.announcementFormDialogTitleLabel, min: 3, max: 200),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: l10n.announcementFormDialogContentLabel,
                    controller: _content,
                    maxLines: 4,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.announcementFormDialogContentShort, min: 10, max: 5000),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<Lookup>(
                          label: l10n.announcementFormDialogCategoryLabel,
                          items: _categories,
                          value: _selectedCategory,
                          isRequired: true,
                          itemLabel: (c) => c.name,
                          onChanged: (value) => setState(() => _selectedCategory = value),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppDropdownField<Lookup>(
                          label: l10n.commonResortLabel,
                          items: _resorts,
                          value: _selectedResort,
                          isRequired: true,
                          itemLabel: (r) => r.name,
                          onChanged: (value) => setState(() => _selectedResort = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppDateField(
                          label: l10n.announcementFormDialogPublishedLabel,
                          value: _publishedAt,
                          isRequired: true,
                          onChanged: (_) => _pickPublishedAt(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppDateField(
                          label: l10n.announcementFormDialogExpiryLabel,
                          value: _expiresAt,
                          onChanged: (_) => _pickExpiresAt(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.announcementFormDialogUrgentSwitch),
                    value: _isUrgent,
                    onChanged: (value) => setState(() => _isUrgent = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.announcementFormDialogActiveSwitch),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ImagePreview(imageUrl: _imageUrl, newImage: _newImage, onPick: _pickImage),
                ],
              ),
            ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.newImage, required this.onPick});

  final String? imageUrl;
  final File? newImage;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final resolved = AppConfig.resolveImageUrl(imageUrl);
    final hasImage = newImage != null || resolved.isNotEmpty;

    return Row(
      children: [
        Container(
          width: 96,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            image: newImage != null
                ? DecorationImage(image: FileImage(newImage!), fit: BoxFit.cover)
                : (resolved.isEmpty ? null : DecorationImage(image: NetworkImage(resolved), fit: BoxFit.cover)),
          ),
          child: hasImage ? null : const Icon(Icons.image_outlined, size: 28),
        ),
        const SizedBox(width: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.upload_outlined, size: AppSizes.iconSm),
          label: Text(hasImage ? l10n.profileDialogChangePhoto : l10n.reportIncidentDialogAddPhoto),
        ),
      ],
    );
  }
}
