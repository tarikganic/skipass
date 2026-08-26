import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/reference_item.dart';
import '../../services/reference_data_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Genericka forma za kreiranje/izmjenu jednog zapisa u referentnoj tabeli.
///
/// Polja se prikazuju/skrivaju prema zastavicama iz [ReferenceTableConfig],
/// umjesto da svaka od osam tabela ima vlastitu skoro identicnu formu.
class ReferenceItemFormDialog extends StatefulWidget {
  const ReferenceItemFormDialog({super.key, required this.config, this.existing});

  final ReferenceTableConfig config;
  final ReferenceItem? existing;

  @override
  State<ReferenceItemFormDialog> createState() => _ReferenceItemFormDialogState();
}

class _ReferenceItemFormDialogState extends State<ReferenceItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _isoCode = TextEditingController(text: widget.existing?.isoCode ?? '');
  late final _postalCode = TextEditingController(text: widget.existing?.postalCode ?? '');
  late final _colorHex = TextEditingController(text: widget.existing?.colorHex ?? '#1E88E5');
  late final _sortOrder = TextEditingController(text: widget.existing?.sortOrder?.toString() ?? '0');
  late final _iconName = TextEditingController(text: widget.existing?.iconName ?? '');
  late final _code = TextEditingController(text: widget.existing?.code ?? '');

  late bool _isUrgentByDefault = widget.existing?.isUrgentByDefault ?? false;
  late bool _isOnline = widget.existing?.isOnline ?? false;
  late bool _isActive = widget.existing?.isActive ?? true;

  List<Lookup> _countries = const [];
  Lookup? _selectedCountry;
  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.config.hasCountry) {
      _loadCountries();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _isoCode.dispose();
    _postalCode.dispose();
    _colorHex.dispose();
    _sortOrder.dispose();
    _iconName.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final countries = await context.read<ReferenceDataService>().lookup('Countries');
    if (!mounted) return;
    setState(() {
      _countries = countries;
      _selectedCountry = countries.isEmpty
          ? null
          : (widget.existing?.countryId == null
              ? countries.first
              : countries.where((c) => c.id == widget.existing!.countryId).firstOrNull ?? countries.first);
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.config.hasCountry && _selectedCountry == null) {
      AppFeedback.error(context, AppLocalizations.of(context)!.referenceItemFormDialogSelectCountryRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    final body = <String, dynamic>{'name': _name.text.trim()};
    if (widget.config.hasDescription) {
      body['description'] = _description.text.trim().isEmpty ? null : _description.text.trim();
    }
    if (widget.config.hasIsoCode) body['isoCode'] = _isoCode.text.trim().toUpperCase();
    if (widget.config.hasPostalCode) {
      body['postalCode'] = _postalCode.text.trim().isEmpty ? null : _postalCode.text.trim();
      body['countryId'] = _selectedCountry?.id;
    }
    if (widget.config.hasColor) body['colorHex'] = _colorHex.text.trim();
    if (widget.config.hasSortOrder) body['sortOrder'] = int.tryParse(_sortOrder.text.trim()) ?? 0;
    if (widget.config.hasIcon) body['iconName'] = _iconName.text.trim().isEmpty ? null : _iconName.text.trim();
    if (widget.config.hasCode) body['code'] = _code.text.trim().toUpperCase();
    if (widget.config.hasUrgentFlag) body['isUrgentByDefault'] = _isUrgentByDefault;
    if (widget.config.hasOnlineFlag) body['isOnline'] = _isOnline;
    if (widget.config.hasActiveFlag) body['isActive'] = _isActive;

    try {
      final service = context.read<ReferenceDataService>();
      final result = _isEditing
          ? await service.update(widget.config.resource, widget.existing!.id, body)
          : await service.create(widget.config.resource, body);

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
    final config = widget.config;
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: _isEditing ? l10n.referenceItemFormDialogEditTitle(config.singularLabel) : l10n.referenceItemFormDialogNewTitle(config.singularLabel),
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: _isLoading
          ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.commonNameLabel,
                    controller: _name,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.commonNameLabel, min: 2, max: 100),
                  ),
                  if (config.hasIsoCode) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.referenceItemFormDialogIsoCodeLabel,
                      controller: _isoCode,
                      hint: 'BA',
                      isRequired: true,
                      validator: (value) {
                        final trimmed = (value ?? '').trim();
                        if (!RegExp(r'^[A-Za-z]{2,3}$').hasMatch(trimmed)) {
                          return l10n.referenceItemFormDialogIsoCodeError;
                        }
                        return null;
                      },
                    ),
                  ],
                  if (config.hasCountry) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppDropdownField<Lookup>(
                      label: l10n.referenceItemFormDialogCountryLabel,
                      items: _countries,
                      value: _selectedCountry,
                      isRequired: true,
                      itemLabel: (c) => c.name,
                      emptyHint: l10n.referenceItemFormDialogNoCountriesHint,
                      onChanged: (value) => setState(() => _selectedCountry = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.referenceItemFormDialogPostalCodeLabel,
                      controller: _postalCode,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final trimmed = (value ?? '').trim();
                        if (trimmed.isEmpty) return null;
                        return RegExp(r'^[0-9]{5}$').hasMatch(trimmed) ? null : l10n.referenceItemFormDialogPostalCodeError;
                      },
                    ),
                  ],
                  if (config.hasDescription) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(label: l10n.referenceItemFormDialogDescriptionLabel, controller: _description, maxLines: 2, maxLength: 300),
                  ],
                  if (config.hasColor) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: l10n.referenceItemFormDialogColorLabel,
                            controller: _colorHex,
                            hint: '#1E88E5',
                            isRequired: true,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final trimmed = (value ?? '').trim();
                              return RegExp(r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(trimmed)
                                  ? null
                                  : l10n.referenceItemFormDialogColorError;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: AppSizes.inputHeight,
                          height: AppSizes.inputHeight,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: AppColors.fromHex(_colorHex.text),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (config.hasSortOrder) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.referenceItemFormDialogSortOrderLabel,
                      controller: _sortOrder,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 0 || parsed > 100) return l10n.referenceItemFormDialogSortOrderError;
                        return null;
                      },
                    ),
                  ],
                  if (config.hasIcon) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(label: l10n.referenceItemFormDialogIconLabel, controller: _iconName, hint: 'local_offer'),
                  ],
                  if (config.hasCode) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.commonCodeLabel,
                      controller: _code,
                      hint: 'PAYPAL',
                      isRequired: true,
                      validator: (value) {
                        final trimmed = (value ?? '').trim();
                        return RegExp(r'^[A-Za-z0-9_]{2,30}$').hasMatch(trimmed)
                            ? null
                            : l10n.referenceItemFormDialogCodeError;
                      },
                    ),
                  ],
                  if (config.hasUrgentFlag) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.referenceItemFormDialogUrgentSwitch),
                      value: _isUrgentByDefault,
                      onChanged: (value) => setState(() => _isUrgentByDefault = value),
                    ),
                  ],
                  if (config.hasOnlineFlag)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.referenceItemFormDialogOnlineSwitch),
                      value: _isOnline,
                      onChanged: (value) => setState(() => _isOnline = value),
                    ),
                  if (config.hasActiveFlag)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.referenceItemFormDialogActiveSwitch),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                ],
              ),
            ),
    );
  }
}
