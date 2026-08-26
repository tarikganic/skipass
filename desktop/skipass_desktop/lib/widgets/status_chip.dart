import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/dimens.dart';

/// Vizuelni stil za jedno stanje (status karte, narudzbe, incidenta...).
class StatusStyle {
  const StatusStyle({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
}

/// Prevodi statuse sa servera u lokalizovane oznake sa dosljednim bojama.
///
/// Sve mapiranje statusa drzi se ovdje, pa ekrani ne sadrze rasute uslove
/// niti hardkodirane boje po stanjima.
///
/// NAPOMENA (i18n): Ove metode namjerno ne primaju BuildContext — postojeci
/// test paket (test/widget_test.dart) poziva ih direktno i provjerava tacan
/// bosanski tekst oznaka, pa signatura ostaje nepromijenjena. Oznake su stoga
/// namjerno ostavljene tvrdo kodirane na bosanskom.
class StatusStyles {
  const StatusStyles._();

  static StatusStyle order(String status) => switch (status) {
        'Pending' => const StatusStyle(
            label: 'Ceka placanje',
            color: AppColors.warning,
            background: AppColors.warningSurface,
            icon: Icons.schedule_rounded,
          ),
        'Confirmed' => const StatusStyle(
            label: 'Potvrdena',
            color: AppColors.success,
            background: AppColors.successSurface,
            icon: Icons.check_circle_rounded,
          ),
        'Completed' => const StatusStyle(
            label: 'Zavrsena',
            color: AppColors.info,
            background: AppColors.infoSurface,
            icon: Icons.task_alt_rounded,
          ),
        'Cancelled' => const StatusStyle(
            label: 'Otkazana',
            color: AppColors.danger,
            background: AppColors.dangerSurface,
            icon: Icons.cancel_rounded,
          ),
        _ => _unknown(status),
      };

  static StatusStyle ticket(String status) => switch (status) {
        'Pending' => const StatusStyle(
            label: 'Neaktivna',
            color: AppColors.warning,
            background: AppColors.warningSurface,
            icon: Icons.hourglass_empty_rounded,
          ),
        'Active' => const StatusStyle(
            label: 'Aktivna',
            color: AppColors.success,
            background: AppColors.successSurface,
            icon: Icons.verified_rounded,
          ),
        'Used' => const StatusStyle(
            label: 'U upotrebi',
            color: AppColors.info,
            background: AppColors.infoSurface,
            icon: Icons.confirmation_number_rounded,
          ),
        'Expired' => const StatusStyle(
            label: 'Istekla',
            color: AppColors.textSecondary,
            background: AppColors.surfaceAlt,
            icon: Icons.event_busy_rounded,
          ),
        'Cancelled' => const StatusStyle(
            label: 'Otkazana',
            color: AppColors.danger,
            background: AppColors.dangerSurface,
            icon: Icons.cancel_rounded,
          ),
        _ => _unknown(status),
      };

  static StatusStyle incident(String status) => switch (status) {
        'Reported' => const StatusStyle(
            label: 'Prijavljen',
            color: AppColors.warning,
            background: AppColors.warningSurface,
            icon: Icons.report_gmailerrorred_rounded,
          ),
        'InProgress' => const StatusStyle(
            label: 'U toku',
            color: AppColors.info,
            background: AppColors.infoSurface,
            icon: Icons.autorenew_rounded,
          ),
        'Resolved' => const StatusStyle(
            label: 'Rijesen',
            color: AppColors.success,
            background: AppColors.successSurface,
            icon: Icons.check_circle_rounded,
          ),
        'Rejected' => const StatusStyle(
            label: 'Odbijen',
            color: AppColors.danger,
            background: AppColors.dangerSurface,
            icon: Icons.do_not_disturb_on_rounded,
          ),
        _ => _unknown(status),
      };

  /// Procijenjena guzva na stazi.
  static StatusStyle crowd(String level) => switch (level) {
        'Low' => const StatusStyle(
            label: 'Slaba guzva',
            color: AppColors.success,
            background: AppColors.successSurface,
            icon: Icons.sentiment_satisfied_rounded,
          ),
        'Moderate' => const StatusStyle(
            label: 'Umjerena guzva',
            color: AppColors.info,
            background: AppColors.infoSurface,
            icon: Icons.groups_rounded,
          ),
        'High' => const StatusStyle(
            label: 'Velika guzva',
            color: AppColors.warning,
            background: AppColors.warningSurface,
            icon: Icons.groups_2_rounded,
          ),
        'VeryHigh' => const StatusStyle(
            label: 'Izuzetna guzva',
            color: AppColors.danger,
            background: AppColors.dangerSurface,
            icon: Icons.groups_3_rounded,
          ),
        _ => _unknown(level),
      };

  static StatusStyle openClosed({required bool isOpen, String? openLabel, String? closedLabel}) =>
      isOpen
          ? StatusStyle(
              label: openLabel ?? 'Otvorena',
              color: AppColors.success,
              background: AppColors.successSurface,
              icon: Icons.check_circle_rounded,
            )
          : StatusStyle(
              label: closedLabel ?? 'Zatvorena',
              color: AppColors.danger,
              background: AppColors.dangerSurface,
              icon: Icons.cancel_rounded,
            );

  static StatusStyle _unknown(String raw) => StatusStyle(
        label: raw.isEmpty ? 'Nepoznato' : raw,
        color: AppColors.textSecondary,
        background: AppColors.surfaceAlt,
        icon: Icons.help_outline_rounded,
      );
}

/// Kompaktna oznaka stanja sa ikonom i pozadinom u boji stanja.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.style, this.compact = false});

  final StatusStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // U tamnoj temi svijetle pozadine se zamjenjuju prozirnom bojom stanja.
    final background = isDark ? style.color.withValues(alpha: 0.18) : style.background;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 3 : AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 13 : AppSizes.iconSm - 2, color: style.color),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              style.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: style.color,
                fontSize: compact ? 11 : 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
