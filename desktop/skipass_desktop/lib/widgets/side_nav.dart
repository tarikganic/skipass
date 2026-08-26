import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/dimens.dart';
import '../l10n/app_localizations.dart';

class SideNavItem {
  const SideNavItem({required this.icon, required this.label, this.badgeCount = 0});

  final IconData icon;
  final String label;
  final int badgeCount;
}

/// Bocna navigacija desktop aplikacije, u stilu skice: naziv aplikacije na vrhu,
/// stavke menija u sredini, precica za prijavu problema pri dnu.
class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onReportIncident,
    required this.userName,
    required this.userRole,
    required this.onProfileTap,
  });

  final List<SideNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onReportIncident;
  final String userName;
  final String userRole;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.sidebarWidth,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.downhill_skiing_rounded, color: Colors.white, size: AppSizes.iconMd),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppLocalizations.of(context)!.sideNavAppName,
                  style: theme.textTheme.titleLarge?.copyWith(letterSpacing: -0.3),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
                  child: Material(
                    color: isSelected ? AppColors.primarySurface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => onSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: AppSizes.iconMd,
                              color: isSelected ? AppColors.primaryDark : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                item.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected ? AppColors.primaryDark : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.badgeCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: onReportIncident,
              icon: const Icon(Icons.report_gmailerrorred_rounded, size: AppSizes.iconSm),
              label: Text(AppLocalizations.of(context)!.sideNavReportIncident),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size.fromHeight(40)),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onProfileTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.avatar / 2,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        userName.isEmpty ? '?' : userName[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(userRole, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: AppSizes.iconSm, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
