import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/ticket.dart';
import '../../services/order_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena tipa ski pass karte, ukljucujuci cijenu i popust.
class TicketTypeDialog extends StatefulWidget {
  const TicketTypeDialog({super.key, this.existing});

  final TicketType? existing;

  @override
  State<TicketTypeDialog> createState() => _TicketTypeDialogState();
}

class _TicketTypeDialogState extends State<TicketTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _pricePerDay = TextEditingController(
    text: widget.existing == null ? '' : widget.existing!.pricePerDay.toStringAsFixed(2),
  );
  late final _maxDays = TextEditingController(text: '${widget.existing?.maxDays ?? 7}');
  late final _discount = TextEditingController(
    text: widget.existing == null ? '0' : widget.existing!.discountPercentage.toStringAsFixed(0),
  );
  late final _minAge = TextEditingController(text: widget.existing?.minAge?.toString() ?? '');
  late final _maxAge = TextEditingController(text: widget.existing?.maxAge?.toString() ?? '');

  late bool _isActive = widget.existing?.isActive ?? true;
  List<Lookup> _resorts = const [];
  Lookup? _selectedResort;
  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadResorts();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _pricePerDay.dispose();
    _maxDays.dispose();
    _discount.dispose();
    _minAge.dispose();
    _maxAge.dispose();
    super.dispose();
  }

  Future<void> _loadResorts() async {
    final resorts = await context.read<ResortService>().searchResorts(pageSize: 50);
    if (!mounted) return;
    setState(() {
      _resorts = resorts.items.map((r) => Lookup(id: r.id, name: r.name)).toList();
      _selectedResort = _resorts.isEmpty
          ? null
          : (widget.existing == null
              ? _resorts.first
              : _resorts.firstWhere(
                  (r) => r.id == widget.existing!.skiResortId,
                  orElse: () => _resorts.first,
                ));
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final body = {
      'name': _name.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'pricePerDay': double.parse(_pricePerDay.text.trim().replaceAll(',', '.')),
      'maxDays': int.parse(_maxDays.text.trim()),
      'discountPercentage': double.parse(_discount.text.trim().replaceAll(',', '.')),
      'minAge': _minAge.text.trim().isEmpty ? null : int.parse(_minAge.text.trim()),
      'maxAge': _maxAge.text.trim().isEmpty ? null : int.parse(_maxAge.text.trim()),
      'isActive': _isActive,
      'skiResortId': _selectedResort!.id,
    };

    try {
      final service = context.read<OrderService>();
      final result = _isEditing
          ? await service.updateTicketType(widget.existing!.id, body)
          : await service.createTicketType(body);

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
      title: _isEditing ? l10n.ticketTypeDialogEditTitle : l10n.ticketTypeAddButton,
      actions: [
        BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit),
      ],
      child: _isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.commonNameLabel,
                    controller: _name,
                    isRequired: true,
                    validator: (value) => Validators.lengthRange(value, l10n.commonNameLabel, min: 2, max: 120),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(label: l10n.commonDescriptionLabel, controller: _description, maxLines: 2),
                  const SizedBox(height: AppSpacing.lg),
                  AppDropdownField<Lookup>(
                    label: l10n.commonResortLabel,
                    items: _resorts,
                    value: _selectedResort,
                    isRequired: true,
                    itemLabel: (r) => r.name,
                    validator: (value) => value == null ? l10n.selectFieldRequiredError(l10n.commonResortLabel) : null,
                    onChanged: (value) => setState(() => _selectedResort = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogPricePerDayLabel,
                          controller: _pricePerDay,
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => _validatePositiveNumber(value, l10n.ticketTypeDialogPriceShort, max: 100000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogMaxDaysLabel,
                          controller: _maxDays,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateIntRange(value, l10n.ticketTypeDialogMaxDaysLabel, min: 1, max: 180),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogDiscountLabel,
                          controller: _discount,
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => _validateIntRange(value, l10n.ticketTypeDialogDiscountLabel, min: 0, max: 100),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogMinAgeLabel,
                          controller: _minAge,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppTextField(
                          label: l10n.ticketTypeDialogMaxAgeLabel,
                          controller: _maxAge,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.ticketTypeDialogActiveSwitch),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ),
    );
  }

  String? _validatePositiveNumber(String? value, String label, {required double max}) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null) return l10n.commonNumberRequiredMessage(label);
    if (parsed <= 0 || parsed > max) return l10n.commonPositiveRangeMessage(label, max);
    return null;
  }

  String? _validateIntRange(String? value, String label, {required int min, required int max}) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) return l10n.commonIntRequiredMessage(label);
    if (parsed < min || parsed > max) return l10n.commonIntRangeMessage(label, min, max);
    return null;
  }
}
