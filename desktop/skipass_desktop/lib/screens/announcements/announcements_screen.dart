import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../models/paged_result.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/engagement_service.dart';
import '../../services/reference_data_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/state_views.dart';
import 'announcement_form_dialog.dart';

/// Obavijesti - odgovara mockupu "Obavijesti" (hitne + aktivne obavijesti).
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final PagedListController<Announcement> _controller;
  String? _query;
  int? _categoryId;
  List<Lookup> _categories = const [];

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<Announcement>(
      fetchPage: (page, pageSize) => context.read<EngagementService>().searchAnnouncements(
            page: page,
            pageSize: pageSize,
            query: _query,
            categoryId: _categoryId,
          ),
    );
    _controller.loadFirstPage();
    _loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final items = await context.read<ReferenceDataService>().lookup('AnnouncementCategories');
    if (mounted) setState(() => _categories = items);
  }

  Future<void> _openForm({Announcement? existing}) async {
    final result = await showDialog<Announcement>(context: context, builder: (_) => AnnouncementFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(Announcement announcement) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.announcementsScreenDeleteConfirmTitle,
      message: l10n.announcementsScreenDeleteConfirmMessage(announcement.title),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<EngagementService>().deleteAnnouncement(announcement.id);
      _controller.removeWhere((a) => a.id == announcement.id);
      if (mounted) AppFeedback.success(context, l10n.announcementsScreenDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.lg),
          child: Row(
            children: [
              Text(l10n.navAnnouncements, style: theme.textTheme.headlineSmall),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: l10n.commonRefresh, onPressed: _controller.refresh),
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                label: Text(l10n.announcementsScreenAddButton),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: TextField(
                  onChanged: (value) {
                    _query = value.trim().isEmpty ? null : value.trim();
                    _controller.loadFirstPage();
                  },
                  decoration: InputDecoration(
                    hintText: l10n.announcementsScreenSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              DropdownButton<int?>(
                value: _categoryId,
                hint: Text(l10n.announcementsScreenAllCategories),
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem<int?>(child: Text(l10n.announcementsScreenAllCategories)),
                  for (final category in _categories) DropdownMenuItem<int?>(value: category.id, child: Text(category.name)),
                ],
                onChanged: (value) {
                  setState(() => _categoryId = value);
                  _controller.loadFirstPage();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoadingFirstPage) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.hasError) {
                return ErrorStateView(message: _controller.errorMessage!, onRetry: _controller.loadFirstPage);
              }
              if (_controller.isEmpty) {
                return EmptyStateView(icon: Icons.campaign_outlined, title: l10n.announcementsScreenEmptyTitle);
              }

              final urgent = _controller.items.where((a) => a.isUrgent).toList();
              final others = _controller.items.where((a) => !a.isUrgent).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxxl),
                children: [
                  if (urgent.isNotEmpty) ...[
                    Text(l10n.announcementsScreenUrgentSectionTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    ...urgent.map((a) => _AnnouncementCard(
                          announcement: a,
                          onEdit: () => _openForm(existing: a),
                          onDelete: () => _delete(a),
                        )),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Text(l10n.announcementsScreenActiveSectionTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  if (others.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(l10n.announcementsScreenOthersEmpty, style: theme.textTheme.bodySmall),
                    )
                  else
                    ...others.map((a) => _AnnouncementCard(
                          announcement: a,
                          onEdit: () => _openForm(existing: a),
                          onDelete: () => _delete(a),
                        )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, required this.onEdit, required this.onDelete});

  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = announcement.isUrgent ? AppColors.danger : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderColor: announcement.isUrgent ? AppColors.danger : null,
        backgroundColor: announcement.isUrgent ? AppColors.dangerSurface.withValues(alpha: 0.4) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: announcement.imageUrl,
              seed: announcement.title,
              width: 96,
              height: 96,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.lg), bottomLeft: Radius.circular(AppRadius.lg)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (announcement.isUrgent) ...[
                          const Icon(Icons.priority_high_rounded, color: AppColors.danger, size: AppSizes.iconSm),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(child: Text(announcement.title, style: theme.textTheme.titleSmall)),
                        if (!announcement.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.pill)),
                            child: Text(l10n.announcementsScreenInactiveLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(announcement.content, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: Text(announcement.categoryName, style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${announcement.skiResortName} · ${l10n.announcementsScreenPublishedLabel(Formatters.date(announcement.publishedAt))}'
                            '${announcement.expiresAt != null ? ' · ${l10n.announcementsScreenExpiresLabel(Formatters.date(announcement.expiresAt!))}' : ''}',
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger), onPressed: onDelete),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
