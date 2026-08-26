import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../models/benefit.dart';
import '../../models/home_summary.dart';
import '../../models/recommended_benefit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../announcements/announcement_details_screen.dart';
import '../announcements/announcements_screen.dart';
import '../benefits/benefit_details_screen.dart';
import '../notifications/notifications_screen.dart';

/// Pocetna stranica: trenutni uslovi, stanje liftova i staza, obavijesti i pogodnosti.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  /// Prelazak na jedan od glavnih tabova iz precica na pocetnoj.
  final void Function(int index) onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().load(showSpinner: false),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                greeting: _greeting(),
                userName: user?.firstName ?? '',
                summary: provider.summary,
                onNotificationsTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                ),
              ),
            ),
            if (provider.isLoading && !provider.hasData)
              const SliverToBoxAdapter(child: LoadingSkeleton(count: 3, height: 120))
            else if (provider.errorMessage != null && !provider.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorStateView(
                  message: provider.errorMessage!,
                  onRetry: () => context.read<HomeProvider>().load(),
                ),
              )
            else if (provider.summary != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.xl,
                  AppSpacing.screen,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: _buildContent(context, provider.summary!, provider.recommendedBenefits),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    HomeSummary summary,
    List<RecommendedBenefit> recommendedBenefits,
  ) {
    final t = AppLocalizations.of(context)!;
    return [
      _ConditionsRow(summary: summary),
      const SizedBox(height: AppSpacing.xl),

      _StatusOverview(
        summary: summary,
        onTrailsTap: () => widget.onNavigateToTab(1),
        onLiftsTap: () => widget.onNavigateToTab(1),
      ),
      const SizedBox(height: AppSpacing.xl),

      _QuickActions(
        activeTicketCount: summary.activeTicketCount,
        onBuyTap: () => widget.onNavigateToTab(2),
        onTicketsTap: () => widget.onNavigateToTab(3),
      ),
      const SizedBox(height: AppSpacing.xxl),

      SectionHeader(
        title: t.homeLatestAnnouncements,
        actionLabel: t.commonAll,
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AnnouncementsScreen()),
        ),
      ),
      if (summary.latestAnnouncements.isEmpty)
        _InlineEmpty(
          icon: Icons.campaign_outlined,
          message: t.homeNoActiveAnnouncements,
        )
      else
        ...summary.latestAnnouncements.map(
          (announcement) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _AnnouncementTile(announcement: announcement),
          ),
        ),
      const SizedBox(height: AppSpacing.lg),

      SectionHeader(
        title: t.homeFeaturedBenefits,
        actionLabel: t.commonAll,
        onAction: () => widget.onNavigateToTab(4),
      ),
      if (summary.featuredBenefits.isEmpty)
        _InlineEmpty(
          icon: Icons.local_offer_outlined,
          message: t.homeNoFeaturedBenefits,
        )
      else
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: summary.featuredBenefits.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                _BenefitPreviewCard(benefit: summary.featuredBenefits[index]),
          ),
        ),
      const SizedBox(height: AppSpacing.lg),

      SectionHeader(
        title: t.homeRecommendedTitle,
        actionLabel: t.commonAll,
        onAction: () => widget.onNavigateToTab(4),
      ),
      if (recommendedBenefits.isEmpty)
        _InlineEmpty(
          icon: Icons.auto_awesome_outlined,
          message: t.homeNoRecommendations,
        )
      else
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: recommendedBenefits.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                _RecommendedBenefitCard(benefit: recommendedBenefits[index]),
          ),
        ),
    ];
  }

  String _greeting() {
    final t = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 11) return t.homeGreetingMorning;
    if (hour < 18) return t.homeGreetingAfternoon;
    return t.homeGreetingEvening;
  }
}

/// Zaglavlje sa gradijentom, pozdravom i statusom skijalista.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.userName,
    required this.summary,
    required this.onNotificationsTap,
  });

  final String greeting;
  final String userName;
  final HomeSummary? summary;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl + 8)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName.isEmpty ? t.homeDefaultUserName : userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _NotificationBell(
                count: summary?.unreadNotificationCount ?? 0,
                onTap: onNotificationsTap,
              ),
            ],
          ),
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    summary!.isResortOpen
                        ? Icons.check_circle_rounded
                        : Icons.nightlight_round,
                    color: Colors.white,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary!.skiResortName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          summary!.isResortOpen
                              ? t.homeResortOpenUntil(summary!.closingTime)
                              : t.homeResortClosed(summary!.openingTime, summary!.closingTime),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: AppSizes.iconMd,
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Trenutni vremenski uslovi, kako je predvidjeno skicom "Trenutno".
class _ConditionsRow extends StatelessWidget {
  const _ConditionsRow({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final weather = summary.weather;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _weatherIcon(weather?.conditions),
              size: AppSizes.iconLg,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.homeCurrentOnTrail, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      weather == null
                          ? '--'
                          : Formatters.temperature(weather.temperatureCelsius),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        weather?.conditions ?? t.commonNoData,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (weather != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _MiniStat(
                        icon: Icons.ac_unit_rounded,
                        label: t.homeSnowDepthLabel(weather.snowDepthCm),
                      ),
                      _MiniStat(
                        icon: Icons.air_rounded,
                        label: '${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String? conditions) {
    final value = (conditions ?? '').toLowerCase();
    if (value.contains('snijeg')) return Icons.ac_unit_rounded;
    if (value.contains('sunc')) return Icons.wb_sunny_rounded;
    if (value.contains('magla')) return Icons.foggy;
    if (value.contains('oblac')) return Icons.cloud_rounded;
    return Icons.thermostat_rounded;
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Pregled otvorenih staza i aktivnih liftova, u dvije kartice jedna do druge.
class _StatusOverview extends StatelessWidget {
  const _StatusOverview({
    required this.summary,
    required this.onTrailsTap,
    required this.onLiftsTap,
  });

  final HomeSummary summary;
  final VoidCallback onTrailsTap;
  final VoidCallback onLiftsTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.downhill_skiing_rounded,
            title: t.navTrails,
            openCount: summary.openTrailCount,
            totalCount: summary.totalTrailCount,
            openLabel: t.homeTrailsOpenLabel,
            onTap: onTrailsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatusCard(
            icon: Icons.cable_rounded,
            title: t.homeLiftsCardTitle,
            openCount: summary.operationalLiftCount,
            totalCount: summary.totalLiftCount,
            openLabel: t.homeLiftsOperationalLabel,
            onTap: onLiftsTap,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.openCount,
    required this.totalCount,
    required this.openLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int openCount;
  final int totalCount;
  final String openLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = totalCount == 0 ? 0.0 : openCount / totalCount;
    final barColor = ratio >= 0.7
        ? AppColors.success
        : (ratio >= 0.4 ? AppColors.warning : AppColors.danger);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$openCount', style: theme.textTheme.displaySmall),
              Text(
                ' / $totalCount',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(openLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Precice ka kupovini i vlastitim kartama.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.activeTicketCount,
    required this.onBuyTap,
    required this.onTicketsTap,
  });

  final int activeTicketCount;
  final VoidCallback onBuyTap;
  final VoidCallback onTicketsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeTicketCount > 0
                      ? t.homeActiveTicketsMessage(Formatters.tickets(activeTicketCount))
                      : t.homeNoActiveTicketMessage,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  activeTicketCount > 0 ? t.homeShowQrHint : t.homeBuyTicketHint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (activeTicketCount > 0)
            FilledButton.tonalIcon(
              onPressed: onTicketsTap,
              icon: const Icon(Icons.qr_code_2_rounded, size: AppSizes.iconMd),
              label: Text(t.homeQrCodeButton),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            )
          else
            FilledButton.icon(
              onPressed: onBuyTap,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: AppSizes.iconMd),
              label: Text(t.commonBuy),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnnouncementDetailsScreen(announcement: announcement),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: announcement.isUrgent
                  ? AppColors.dangerSurface
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              announcement.isUrgent
                  ? Icons.priority_high_rounded
                  : Icons.campaign_outlined,
              size: AppSizes.iconMd,
              color: announcement.isUrgent
                  ? AppColors.danger
                  : theme.colorScheme.onSurfaceVariant,
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
                        announcement.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 3),
                Text(
                  announcement.content,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${announcement.categoryName} · ${Formatters.relative(announcement.publishedAt)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitPreviewCard extends StatelessWidget {
  const _BenefitPreviewCard({required this.benefit});

  final Benefit benefit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 210,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BenefitDetailsScreen(benefitId: benefit.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (benefit.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '-${benefit.discountPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              benefit.name,
              style: theme.textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              benefit.categoryName,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Kartica je uske sirine, pa se cijena smanjuje umjesto da se prelije.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.money(benefit.effectivePrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (benefit.hasDiscount) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        Formatters.money(benefit.price),
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedBenefitCard extends StatelessWidget {
  const _RecommendedBenefitCard({required this.benefit});

  final RecommendedBenefit benefit;

  String? _reasonText(AppLocalizations t) {
    if (benefit.reasons.isEmpty) return null;
    final reason = benefit.reasons.first;
    return switch (reason.code) {
      RecommendationReasonCodes.purchasedCategory =>
        t.recommendationReasonPurchasedCategory(reason.categoryName ?? ''),
      RecommendationReasonCodes.viewedCategory =>
        t.recommendationReasonViewedCategory(reason.categoryName ?? ''),
      RecommendationReasonCodes.usedPartner =>
        t.recommendationReasonUsedPartner(reason.partnerName ?? ''),
      RecommendationReasonCodes.preferredBrand =>
        t.recommendationReasonPreferredBrand(reason.brand ?? ''),
      _ => t.recommendationReasonPopularFallback,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final reasonText = _reasonText(t);

    return SizedBox(
      width: 220,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BenefitDetailsScreen(benefitId: benefit.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (benefit.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '-${benefit.discountPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              benefit.name,
              style: theme.textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              benefit.categoryName,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (reasonText != null)
              Text(
                reasonText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.money(benefit.effectivePrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (benefit.hasDiscount) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        Formatters.money(benefit.price),
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// Slika pogodnosti sa rezervnim prikazom kada putanja nije postavljena.
class BenefitImage extends StatelessWidget {
  const BenefitImage({super.key, required this.imageUrl, this.height = AppSizes.cardImage});

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = AppConfig.resolveImageUrl(imageUrl);

    if (resolved.isEmpty) {
      return Container(
        height: height,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_outlined,
          size: AppSizes.iconLg,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      resolved,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_outlined,
          size: AppSizes.iconLg,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
