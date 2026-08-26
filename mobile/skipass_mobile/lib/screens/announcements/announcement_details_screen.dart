import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/status_chip.dart';

/// Puni tekst obavijesti sa slikom i datumom objave.
class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.announcementDetailsAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          if (announcement.isUrgent) ...[
            StatusChip(
              style: StatusStyle(
                label: t.announcementUrgentBadge,
                color: AppColors.danger,
                background: AppColors.dangerSurface,
                icon: Icons.warning_amber_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          Text(announcement.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                Formatters.dateTime(announcement.publishedAt),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Text('· ${announcement.categoryName}', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          AppNetworkImage(
            imageUrl: announcement.imageUrl,
            seed: announcement.title,
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(announcement.content, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xxl),

          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                LabeledValue(
                  label: t.skiResortLabel,
                  value: announcement.skiResortName,
                  icon: Icons.terrain_rounded,
                ),
                LabeledValue(
                  label: t.announcementPublishedByLabel,
                  value: announcement.createdByUserName,
                  icon: Icons.person_outline_rounded,
                ),
                if (announcement.expiresAt != null)
                  LabeledValue(
                    label: t.announcementValidUntilLabel,
                    value: Formatters.dateTime(announcement.expiresAt!),
                    icon: Icons.event_busy_rounded,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
