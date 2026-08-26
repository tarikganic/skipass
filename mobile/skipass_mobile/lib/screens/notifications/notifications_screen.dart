import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../providers/notification_provider.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';

/// Sistemske notifikacije korisnika, sa oznakom procitano.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final PagedListController<AppNotification> _controller;

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<AppNotification>(
      fetchPage: (page, pageSize) => context
          .read<EngagementService>()
          .searchNotifications(page: page, pageSize: pageSize),
    );

    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      await context.read<EngagementService>().markNotificationRead(notification.id);
      if (!mounted) return;

      context.read<NotificationProvider>().decrement();
      await _controller.refresh();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await context.read<NotificationProvider>().markAllRead();
      if (!mounted) return;

      AppFeedback.success(context, AppLocalizations.of(context)!.markAllReadSuccessMessage);
      await _controller.refresh();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsAppBarTitle),
        actions: [
          // Akcija je onemogucena kada nema neprocitanih notifikacija.
          TextButton(
            onPressed: unreadCount == 0 ? null : _markAllRead,
            child: Text(t.markAllReadAction),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoadingFirstPage) {
            return const LoadingSkeleton(count: 5, height: 88);
          }

          if (_controller.hasError) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.loadFirstPage,
            );
          }

          if (_controller.isEmpty) {
            return EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: t.notificationsEmptyTitle,
              message: t.notificationsEmptyMessage,
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
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index >= _controller.items.length) return const NextPageLoader();

                final notification = _controller.items[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => _markRead(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: isUnread ? AppColors.primary.withValues(alpha: 0.35) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isUnread
                  ? AppColors.primarySurface
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _iconFor(notification.type),
              size: AppSizes.iconSm,
              color: isUnread ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(notification.message, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Formatters.relative(notification.createdAt),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'OrderConfirmed' => Icons.check_circle_outline_rounded,
        'OrderCancelled' => Icons.cancel_outlined,
        'PaymentCompleted' => Icons.payments_outlined,
        'PaymentRefunded' => Icons.undo_rounded,
        'TicketActivated' => Icons.confirmation_number_outlined,
        'TicketExpiring' => Icons.hourglass_bottom_rounded,
        'IncidentStatusChanged' => Icons.report_gmailerrorred_outlined,
        'TrailStatusChanged' => Icons.downhill_skiing_rounded,
        'LiftStatusChanged' => Icons.cable_rounded,
        'NewAnnouncement' => Icons.campaign_outlined,
        'BenefitRecommendation' => Icons.local_offer_outlined,
        _ => Icons.notifications_none_rounded,
      };
}
