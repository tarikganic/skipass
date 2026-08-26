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
import '../../models/benefit.dart';
import '../../models/paged_result.dart';
import '../../services/benefit_service.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena pogodnosti/usluge.
class BenefitFormDialog extends StatefulWidget {
  const BenefitFormDialog({super.key, this.existing, this.initialCategoryId});

  final Benefit? existing;

  /// Kategorija unaprijed odabrana kada se forma otvara iz "+" dugmeta odredjene sekcije.
  final int? initialCategoryId;

  @override
  State<BenefitFormDialog> createState() => _BenefitFormDialogState();
}

class _BenefitFormDialogState extends State<BenefitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _brand = TextEditingController(text: widget.existing?.brand ?? '');
  late final _price = TextEditingController(text: widget.existing == null ? '' : widget.existing!.price.toStringAsFixed(2));
  late final _discount = TextEditingController(
    text: widget.existing == null ? '0' : widget.existing!.discountPercentage.toStringAsFixed(0),
  );

  late bool _isActive = widget.existing?.isActive ?? true;
  String? _imageUrl;
  File? _newImage;

  List<Lookup> _resorts = const [];
  List<Lookup> _categories = const [];
  List<Lookup> _partners = const [];
  Lookup? _selectedResort;
  Lookup? _selectedCategory;
  Lookup? _selectedPartner;

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
    _description.dispose();
    _brand.dispose();
    _price.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final resortService = context.read<ResortService>();
    final referenceService = context.read<ReferenceDataService>();
    final benefitService = context.read<BenefitService>();

    final results = await Future.wait([
      resortService.searchResorts(pageSize: 50),
      referenceService.lookup('BenefitCategories'),
      benefitService.searchPartners(pageSize: 100),
    ]);

    if (!mounted) return;

    final List<Lookup> resorts = (results[0] as dynamic).items.map<Lookup>((r) => Lookup(id: r.id, name: r.name)).toList();
    final categories = results[1] as List<Lookup>;
    final List<Lookup> partners = (results[2] as dynamic).items.map<Lookup>((p) => Lookup(id: p.id, name: p.name)).toList();

    setState(() {
      _resorts = resorts;
      _categories = categories;
      _partners = partners;
      _selectedResort = resorts.isEmpty
          ? null
          : (widget.existing == null
              ? resorts.first
              : resorts.where((r) => r.id == widget.existing!.skiResortId).firstOrNull ?? resorts.first);

      final categoryId = widget.existing?.categoryId ?? widget.initialCategoryId;
      _selectedCategory = categories.isEmpty
          ? null
          : (categoryId == null ? categories.first : categories.where((c) => c.id == categoryId).firstOrNull ?? categories.first);

      _selectedPartner = widget.existing?.partnerId == null
          ? null
          : partners.where((p) => p.id == widget.existing!.partnerId).firstOrNull;

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
    if (_selectedResort == null || _selectedCategory == null) {
      AppFeedback.error(context, AppLocalizations.of(context)!.benefitFormDialogSelectRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final benefitService = context.read<BenefitService>();

      var imageUrl = _imageUrl;
      if (_newImage != null) {
        imageUrl = await benefitService.uploadImage(_newImage!);
      }

      final body = {
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'imageUrl': imageUrl,
        'price': double.parse(_price.text.trim().replaceAll(',', '.')),
        'discountPercentage': double.parse(_discount.text.trim().replaceAll(',', '.')),
        'brand': _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        'isActive': _isActive,
        'benefitCategoryId': _selectedCategory!.id,
        'skiResortId': _selectedResort!.id,
        'partnerId': _selectedPartner?.id,
      };

      final result = _isEditing
          ? await benefitService.updateBenefit(widget.existing!.id, body)
          : await benefitService.createBenefit(body);

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
      title: _isEditing ? l10n.benefitFormDialogEditTitle : l10n.benefitFormDialogNewTitle,
      width: AppSizes.wideDialogWidth,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImagePreview(imageUrl: _imageUrl, newImage: _newImage, onPick: _pickImage),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: l10n.benefitFormDialogNameLabel,
                    controller: _name,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.commonNameLabel, min: 2, max: 150),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: l10n.commonDescriptionLabel,
                    controller: _description,
                    maxLines: 3,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.commonDescriptionLabel, min: 10, max: 2000),
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
                  AppDropdownField<Lookup>(
                    label: l10n.benefitFormDialogPartnerLabel,
                    items: _partners,
                    value: _selectedPartner,
                    itemLabel: (p) => p.name,
                    emptyHint: l10n.partnersEmptyTitle,
                    onChanged: (value) => setState(() => _selectedPartner = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.benefitFormDialogPriceLabel,
                          controller: _price,
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) return l10n.benefitFormDialogPriceError;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogDiscountLabel,
                          controller: _discount,
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                            if (parsed == null || parsed < 0 || parsed > 100) return l10n.benefitFormDialogDiscountError;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(label: l10n.benefitFormDialogBrandLabel, controller: _brand),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.benefitFormDialogActiveSwitch),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
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
          height: 96,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            image: newImage != null
                ? DecorationImage(image: FileImage(newImage!), fit: BoxFit.cover)
                : (resolved.isEmpty ? null : DecorationImage(image: NetworkImage(resolved), fit: BoxFit.cover)),
          ),
          child: hasImage ? null : const Icon(Icons.local_offer_outlined, size: 30),
        ),
        const SizedBox(width: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.upload_outlined, size: AppSizes.iconSm),
          label: Text(hasImage ? l10n.profileDialogChangePhoto : l10n.benefitFormDialogAddPhoto),
        ),
      ],
    );
  }
}
