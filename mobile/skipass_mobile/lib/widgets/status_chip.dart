import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/dimens.dart';
import '../l10n/app_localizations.dart';

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
class StatusStyles {
  const StatusStyles._();

  static StatusStyle order(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;
    return switch (status) {
      'Pending' => StatusStyle(
          label: t.statusOrderPending,
          color: AppColors.warning,
          background: AppColors.warningSurface,
          icon: Icons.schedule_rounded,
        ),
      'Confirmed' => StatusStyle(
          label: t.statusOrderConfirmed,
          color: AppColors.success,
          background: AppColors.successSurface,
          icon: Icons.check_circle_rounded,
        ),
      'Completed' => StatusStyle(
          label: t.statusOrderCompleted,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.task_alt_rounded,
        ),
      'Cancelled' => StatusStyle(
          label: t.statusOrderCancelled,
          color: AppColors.danger,
          background: AppColors.dangerSurface,
          icon: Icons.cancel_rounded,
        ),
      _ => _unknown(context, status),
    };
  }

  static StatusStyle ticket(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;
    return switch (status) {
      'Pending' => StatusStyle(
          label: t.statusTicketPending,
          color: AppColors.warning,
          background: AppColors.warningSurface,
          icon: Icons.hourglass_empty_rounded,
        ),
      'Active' => StatusStyle(
          label: t.statusTicketActive,
          color: AppColors.success,
          background: AppColors.successSurface,
          icon: Icons.verified_rounded,
        ),
      'Used' => StatusStyle(
          label: t.statusTicketUsed,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.confirmation_number_rounded,
        ),
      'Expired' => StatusStyle(
          label: t.statusTicketExpired,
          color: AppColors.textSecondary,
          background: AppColors.surfaceAlt,
          icon: Icons.event_busy_rounded,
        ),
      'Cancelled' => StatusStyle(
          label: t.statusOrderCancelled,
          color: AppColors.danger,
          background: AppColors.dangerSurface,
          icon: Icons.cancel_rounded,
        ),
      _ => _unknown(context, status),
    };
  }

  static StatusStyle incident(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;
    return switch (status) {
      'Reported' => StatusStyle(
          label: t.statusIncidentReported,
          color: AppColors.warning,
          background: AppColors.warningSurface,
          icon: Icons.report_gmailerrorred_rounded,
        ),
      'InProgress' => StatusStyle(
          label: t.statusIncidentInProgress,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.autorenew_rounded,
        ),
      'Resolved' => StatusStyle(
          label: t.statusIncidentResolved,
          color: AppColors.success,
          background: AppColors.successSurface,
          icon: Icons.check_circle_rounded,
        ),
      'Rejected' => StatusStyle(
          label: t.statusIncidentRejected,
          color: AppColors.danger,
          background: AppColors.dangerSurface,
          icon: Icons.do_not_disturb_on_rounded,
        ),
      _ => _unknown(context, status),
    };
  }

  /// Procijenjena guzva na stazi.
  static StatusStyle crowd(BuildContext context, String level) {
    final t = AppLocalizations.of(context)!;
    return switch (level) {
      'Low' => StatusStyle(
          label: t.statusCrowdLow,
          color: AppColors.success,
          background: AppColors.successSurface,
          icon: Icons.sentiment_satisfied_rounded,
        ),
      'Moderate' => StatusStyle(
          label: t.statusCrowdModerate,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.groups_rounded,
        ),
      'High' => StatusStyle(
          label: t.statusCrowdHigh,
          color: AppColors.warning,
          background: AppColors.warningSurface,
          icon: Icons.groups_2_rounded,
        ),
      'VeryHigh' => StatusStyle(
          label: t.statusCrowdVeryHigh,
          color: AppColors.danger,
          background: AppColors.dangerSurface,
          icon: Icons.groups_3_rounded,
        ),
      _ => _unknown(context, level),
    };
  }

  static StatusStyle openClosed(
    BuildContext context, {
    required bool isOpen,
    String? openLabel,
    String? closedLabel,
  }) {
    final t = AppLocalizations.of(context)!;
    return isOpen
        ? StatusStyle(
            label: openLabel ?? t.statusOpen,
            color: AppColors.success,
            background: AppColors.successSurface,
            icon: Icons.check_circle_rounded,
          )
        : StatusStyle(
            label: closedLabel ?? t.statusClosed,
            color: AppColors.danger,
            background: AppColors.dangerSurface,
            icon: Icons.cancel_rounded,
          );
  }

  static StatusStyle _unknown(BuildContext context, String raw) => StatusStyle(
        label: raw.isEmpty ? AppLocalizations.of(context)!.statusUnknown : raw,
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
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
