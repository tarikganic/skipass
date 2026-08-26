import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/user_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/list_scaffold.dart';
import 'user_form_dialog.dart';

/// Upravljanje korisnicima - dostupno samo administratoru.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final PagedListController<AppUser> _controller;
  String? _query;
  String? _role;

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<AppUser>(
      fetchPage: (page, pageSize) => context.read<UserService>().search(page: page, pageSize: pageSize, query: _query, role: _role),
    );
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm({AppUser? existing}) async {
    final result = await showDialog<AppUser>(context: context, builder: (_) => UserFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(AppUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = context.read<AuthProvider>().user?.id;
    if (user.id == currentUserId) {
      AppFeedback.error(context, l10n.usersScreenDeleteSelfError);
      return;
    }

    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.usersScreenDeleteConfirmTitle,
      message: l10n.usersScreenDeleteConfirmMessage(user.fullName),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<UserService>().delete(user.id);
      _controller.removeWhere((u) => u.id == user.id);
      if (mounted) AppFeedback.success(context, l10n.usersScreenDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<AppUser>(
      title: l10n.navUsers,
      controller: _controller,
      searchHint: l10n.usersScreenSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: DropdownButton<String?>(
        value: _role,
        hint: Text(l10n.usersScreenAllRoles),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<String?>(child: Text(l10n.usersScreenAllRoles)),
          DropdownMenuItem<String?>(value: 'Skier', child: Text(l10n.roleSkier)),
          DropdownMenuItem<String?>(value: 'Staff', child: Text(l10n.roleStaff)),
          DropdownMenuItem<String?>(value: 'Admin', child: Text(l10n.roleAdmin)),
        ],
        onChanged: (value) {
          setState(() => _role = value);
          _controller.loadFirstPage();
        },
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.person_add_alt_rounded, size: AppSizes.iconSm),
          label: Text(l10n.usersScreenAddButton),
        ),
      ],
      emptyIcon: Icons.people_outline_rounded,
      emptyTitle: l10n.usersScreenEmptyTitle,
      itemBuilder: (context, user) => _UserRow(
        user: user,
        onEdit: () => _openForm(existing: user),
        onDelete: () => _delete(user),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onEdit, required this.onDelete});

  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.primarySurface, child: Text(user.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: theme.textTheme.titleSmall),
                Text(user.email, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(color: _roleColor(user.role).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(
                _roleLabel(l10n, user.role),
                textAlign: TextAlign.center,
                style: TextStyle(color: _roleColor(user.role), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(l10n.usersScreenOrderCount(user.orderCount), style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.lastLoginAt == null ? l10n.usersScreenNeverLoggedIn : l10n.usersScreenLastLogin(Formatters.date(user.lastLoginAt!)),
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (!user.isActive)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(l10n.ticketTypeInactiveLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger), onPressed: onDelete),
        ],
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, String role) => switch (role) {
        'Admin' => l10n.roleAdmin,
        'Staff' => l10n.roleStaff,
        _ => l10n.roleSkier,
      };

  Color _roleColor(String role) => switch (role) {
        'Admin' => AppColors.danger,
        'Staff' => AppColors.info,
        _ => AppColors.success,
      };
}
