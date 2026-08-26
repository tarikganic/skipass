import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/partner.dart';
import '../../services/benefit_service.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';

/// Kreiranje ili izmjena partnera koji nude pogodnosti.
class PartnerFormDialog extends StatefulWidget {
  const PartnerFormDialog({super.key, this.existing});

  final Partner? existing;

  @override
  State<PartnerFormDialog> createState() => _PartnerFormDialogState();
}

class _PartnerFormDialogState extends State<PartnerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _contactEmail = TextEditingController(text: widget.existing?.contactEmail ?? '');
  late final _contactPhone = TextEditingController(text: widget.existing?.contactPhone ?? '');
  late final _website = TextEditingController(text: widget.existing?.website ?? '');
  late final _address = TextEditingController(text: widget.existing?.address ?? '');

  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _contactEmail.dispose();
    _contactPhone.dispose();
    _website.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final body = {
      'name': _name.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'contactEmail': _contactEmail.text.trim().isEmpty ? null : _contactEmail.text.trim(),
      'contactPhone': _contactPhone.text.trim().isEmpty ? null : _contactPhone.text.trim(),
      'website': _website.text.trim().isEmpty ? null : _website.text.trim(),
      'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
      'isActive': _isActive,
    };

    try {
      final service = context.read<BenefitService>();
      final result = _isEditing ? await service.updatePartner(widget.existing!.id, body) : await service.createPartner(body);
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
      title: _isEditing ? l10n.partnerFormDialogEditTitle : l10n.partnerFormDialogNewTitle,
      actions: [BusyButton(label: l10n.commonSave, isBusy: _isSubmitting, onPressed: _submit)],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.partnerFormDialogNameLabel,
              controller: _name,
              isRequired: true,
              validator: (value) => Validators.lengthRange(value, l10n.commonNameLabel, min: 2, max: 150),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(label: l10n.commonDescriptionLabel, controller: _description, maxLines: 3, maxLength: 1000),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.partnerFormDialogContactEmailLabel,
                    controller: _contactEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.trim().isEmpty ? null : Validators.email(value),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(label: l10n.partnerFormDialogContactPhoneLabel, controller: _contactPhone, keyboardType: TextInputType.phone),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(label: l10n.partnerFormDialogWebsiteLabel, controller: _website, keyboardType: TextInputType.url),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(label: l10n.partnerFormDialogAddressLabel, controller: _address),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.partnerFormDialogActiveSwitch),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
    );
  }
}
