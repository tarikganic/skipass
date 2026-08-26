import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';
import '../announcements/announcements_screen.dart';
import '../benefits/my_benefits_screen.dart';
import '../incidents/my_incidents_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

/// Profil korisnika sa precicama ka vlastitim zapisima.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: t.logoutDialogTitle,
      message: t.logoutDialogMessage,
      confirmLabel: t.logoutConfirmButton,
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;
    await context.read<AuthProvider>().logout();
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final t = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final locale in const [Locale('bs'), Locale('en')])
              RadioListTile<Locale>(
                title: Text(locale.languageCode == 'bs' ? t.languageBosnian : t.languageEnglish),
                value: locale,
                groupValue: localeProvider.locale,
                onChanged: (value) {
                  if (value != null) localeProvider.setLocale(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.navProfile)),
      body: user == null
          ? const LoadingSkeleton(count: 3, height: 120)
          : RefreshIndicator(
              onRefresh: () => context.read<AuthProvider>().refreshUser(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.xxxl,
                ),
                children: [
                  _ProfileHeader(user: user),
                  const SizedBox(height: AppSpacing.xl),

                  SectionHeader(title: t.myActivitiesSectionTitle),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.receipt_long_outlined,
                          title: t.ordersAppBarTitle,
                          subtitle: t.orderCountSubtitle(user.orderCount),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.shopping_bag_outlined,
                          title: t.myBenefitsTitle,
                          subtitle: t.myBenefitsMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const MyBenefitsScreen(),
                            ),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.report_gmailerrorred_outlined,
                          title: t.myIncidentsAppBarTitle,
                          subtitle: t.myReportsMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const MyIncidentsScreen(),
                            ),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: t.notificationsAppBarTitle,
                          subtitle: t.notificationsMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.campaign_outlined,
                          title: t.resortAnnouncementsMenuTitle,
                          subtitle: t.resortAnnouncementsMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AnnouncementsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SectionHeader(title: t.accountSettingsSectionTitle),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.manage_accounts_outlined,
                          title: t.editProfileMenuTitle,
                          subtitle: t.editProfileMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: t.changePasswordAppBarTitle,
                          subtitle: t.changePasswordMenuSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          ),
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.language_rounded,
                          title: t.languageLabel,
                          subtitle: context.watch<LocaleProvider>().locale.languageCode == 'bs'
                              ? t.languageBosnian
                              : t.languageEnglish,
                          onTap: () => _showLanguagePicker(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  OutlinedButton.icon(
                    onPressed: auth.isBusy ? null : () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(t.logoutConfirmButton),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      t.appVersionFooter,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final imageUrl = AppConfig.resolveImageUrl(user.profileImageUrl);

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(imageUrl: imageUrl, initials: user.initials),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),
          LabeledValue(
            label: t.profileEmailLabel,
            value: user.email,
            icon: Icons.mail_outline_rounded,
          ),
          LabeledValue(
            label: t.profilePhoneLabel,
            value: user.phone ?? t.profilePhoneNotSet,
            icon: Icons.phone_outlined,
          ),
          LabeledValue(
            label: t.fieldCityLabel,
            value: user.cityName ?? t.profileCityNotSet,
            icon: Icons.location_city_rounded,
          ),
          if (user.birthDate != null)
            LabeledValue(
              label: t.fieldBirthDateLabel,
              value: Formatters.date(user.birthDate!),
              icon: Icons.cake_outlined,
            ),
          LabeledValue(
            label: t.profileMemberSinceLabel,
            value: Formatters.date(user.createdAt),
            icon: Icons.event_available_rounded,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.initials});

  final String imageUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: AppSizes.avatar / 2,
        backgroundColor: AppColors.primarySurface,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: AppSizes.avatar / 2,
      backgroundColor: AppColors.primarySurface,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, _) {},
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: AppSizes.iconSm),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: AppSpacing.lg + 38 + AppSpacing.lg,
        color: Theme.of(context).colorScheme.outline,
      );
}
