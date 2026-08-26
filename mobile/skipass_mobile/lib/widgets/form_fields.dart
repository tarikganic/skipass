import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/dimens.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';

/// Tekstualno polje sa oznakom iznad kontrole.
///
/// Validacijska poruka se uvijek prikazuje ispod polja, nikada unutar njega
/// niti kao dijalog.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            counterText: '',
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: AppSizes.iconMd),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Padajuca lista koja se puni podacima iz baze.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.isRequired = false,
    this.validator,
    this.emptyHint,
  });

  final String label;
  final List<T> items;
  final T? value;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final bool isRequired;
  final String? Function(T?)? validator;

  /// Poruka kada referentna tabela nema zapisa, umjesto prazne liste bez objasnjenja.
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final isEmpty = items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          onChanged: isEmpty ? null : onChanged,
          hint: Text(
            isEmpty ? (emptyHint ?? t.commonNoItemsAvailable) : (hint ?? t.commonSelect),
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textDisabled),
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: AppSizes.iconMd),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Odabir datuma preko kalendara; datum se nikada ne unosi rucno kao tekst.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.hint,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final String? hint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () async {
            final now = DateTime.now();
            final selected = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: firstDate ?? DateTime(now.year - 100),
              lastDate: lastDate ?? DateTime(now.year + 2),
              helpText: label,
              cancelText: t.commonDiscard,
              confirmText: t.commonConfirm,
            );
            if (selected != null) onChanged(selected);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              prefixIcon: const Icon(Icons.event_rounded, size: AppSizes.iconMd),
              suffixIcon: const Icon(Icons.expand_more_rounded),
            ),
            child: Text(
              value == null ? (hint ?? t.commonSelect) : Formatters.date(value!),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: value == null
                    ? AppColors.textDisabled
                    : (hasError ? theme.colorScheme.onSurface : null),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Brojac sa dugmadima minus i plus, kako je predvidjeno skicom.
class AppStepperField extends StatelessWidget {
  const AppStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.helperText,
    this.suffixBuilder,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? helperText;
  final String Function(int value)? suffixBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = value > min;
    final canIncrease = value < max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                enabled: canDecrease,
                onPressed: () => onChanged(value - 1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    suffixBuilder?.call(value) ?? '$value',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                enabled: canIncrease,
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(helperText!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 52,
      height: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: AppSizes.iconMd,
            color: enabled ? theme.colorScheme.primary : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        text: label,
        style: theme.textTheme.titleSmall,
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                ),
              ]
            : null,
      ),
    );
  }
}
