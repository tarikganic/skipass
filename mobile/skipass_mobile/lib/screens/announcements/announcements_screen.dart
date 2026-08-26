import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/catalog_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import 'announcement_details_screen.dart';

/// Obavijesti skijalista.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final PagedListController<Announcement> _controller;
  bool _urgentOnly = false;

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<Announcement>(
      fetchPage: (page, pageSize) => context.read<CatalogService>().searchAnnouncements(
            page: page,
            pageSize: pageSize,
            isUrgent: _urgentOnly ? true : null,
          ),
    );

    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.announcementsAppBarTitle),
        actions: [
          IconButton(
            icon: Icon(
              _urgentOnly ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
            ),
            tooltip: _urgentOnly ? t.showAllAnnouncementsTooltip : t.showUrgentOnlyTooltip,
            onPressed: () {
              setState(() => _urgentOnly = !_urgentOnly);
              _controller.loadFirstPage();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoadingFirstPage) {
            return const LoadingSkeleton(count: 4, height: 118);
          }

          if (_controller.hasError) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.loadFirstPage,
            );
          }

          if (_controller.isEmpty) {
            return EmptyStateView(
              icon: Icons.campaign_outlined,
              title: _urgentOnly ? t.noUrgentAnnouncementsTitle : t.noActiveAnnouncementsTitle,
              message: t.announcementsEmptyMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              itemCount: _controller.items.length + (_controller.isLoadingNextPage ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index >= _controller.items.length) return const NextPageLoader();
                return _AnnouncementCard(announcement: _controller.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnnouncementDetailsScreen(announcement: announcement),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  announcement.categoryName,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (announcement.isUrgent)
                StatusChip(
                  compact: true,
                  style: StatusStyle(
                    label: t.statusUrgentLabel,
                    color: AppColors.danger,
                    background: AppColors.dangerSurface,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            announcement.title,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            announcement.content,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              // Datum ustupa prostor oznaci "Detaljnije" kada je tekst duzi.
              Expanded(
                child: Text(
                  Formatters.relative(announcement.publishedAt),
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(t.readMoreLabel, style: theme.textTheme.labelSmall),
              const Icon(Icons.chevron_right_rounded, size: AppSizes.iconSm),
            ],
          ),
        ],
      ),
    );
  }
}
