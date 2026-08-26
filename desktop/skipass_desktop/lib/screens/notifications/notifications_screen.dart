import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../widgets/list_scaffold.dart';

/// Notifikacije upucene prijavljenom korisniku (osoblje/administrator).
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
      fetchPage: (page, pageSize) => context.read<EngagementService>().searchNotifications(page: page, pageSize: pageSize),
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
      context.read<NotificationProvider>().decrement();
      _controller.refresh();
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  Future<void> _markAllRead() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<NotificationProvider>().markAllRead();
      _controller.refresh();
      if (mounted) AppFeedback.success(context, l10n.notificationsScreenMarkAllSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<AppNotification>(
      title: l10n.navNotifications,
      controller: _controller,
      actions: [
        TextButton.icon(
          onPressed: _markAllRead,
          icon: const Icon(Icons.done_all_rounded, size: AppSizes.iconSm),
          label: Text(l10n.notificationsScreenMarkAllButton),
        ),
      ],
      emptyIcon: Icons.notifications_none_rounded,
      emptyTitle: l10n.notificationsScreenEmptyTitle,
      itemBuilder: (context, notification) => _NotificationRow(
        notification: notification,
        onTap: () => _markRead(notification),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      backgroundColor: notification.isRead ? null : AppColors.primarySurface.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.transparent : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(notification.message, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(Formatters.relative(notification.createdAt), style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
