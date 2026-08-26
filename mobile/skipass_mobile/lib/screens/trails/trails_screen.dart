import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/ski_lift.dart';
import '../../models/trail.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/catalog_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import 'trail_details_screen.dart';

/// Pregled staza i ski liftova, sa pretragom i filterima.
class TrailsScreen extends StatefulWidget {
  const TrailsScreen({super.key});

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.trailsAppBarTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.navTrails),
            Tab(text: t.homeLiftsCardTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_TrailsTab(), _LiftsTab()],
      ),
    );
  }
}

class _TrailsTab extends StatefulWidget {
  const _TrailsTab();

  @override
  State<_TrailsTab> createState() => _TrailsTabState();
}

class _TrailsTabState extends State<_TrailsTab> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late final PagedListController<Trail> _controller;
  Timer? _debounce;

  String? _query;
  int? _difficultyId;
  bool? _isOpen;
  List<Lookup> _difficulties = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<Trail>(
      fetchPage: (page, pageSize) => context.read<CatalogService>().searchTrails(
            page: page,
            pageSize: pageSize,
            query: _query,
            difficultyId: _difficultyId,
            isOpen: _isOpen,
          ),
    );

    _scrollController.addListener(_onScroll);
    _controller.loadFirstPage();
    _loadDifficulties();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDifficulties() async {
    final items = await context.read<CatalogService>().lookup('TrailDifficulties');
    if (mounted) setState(() => _difficulties = items);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 320) {
      _controller.loadNextPage();
    }
  }

  /// Pretraga se salje tek kada korisnik prestane kucati, da se ne opterecuje server.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim().isEmpty ? null : value.trim();
      _controller.loadFirstPage();
    });
  }

  void _applyFilter({int? difficultyId, bool? isOpen, bool clear = false}) {
    setState(() {
      if (clear) {
        _difficultyId = null;
        _isOpen = null;
      } else {
        _difficultyId = difficultyId;
        _isOpen = isOpen;
      }
    });
    _controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.trailsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: t.clearSearchTooltip,
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              _FilterChip(
                label: t.commonAll,
                isSelected: _difficultyId == null && _isOpen == null,
                onSelected: () => _applyFilter(clear: true),
              ),
              _FilterChip(
                label: t.trailsFilterOpen,
                isSelected: _isOpen == true,
                onSelected: () => _applyFilter(
                  difficultyId: _difficultyId,
                  isOpen: _isOpen == true ? null : true,
                ),
              ),
              ..._difficulties.map(
                (difficulty) => _FilterChip(
                  label: difficulty.name,
                  isSelected: _difficultyId == difficulty.id,
                  onSelected: () => _applyFilter(
                    difficultyId: _difficultyId == difficulty.id ? null : difficulty.id,
                    isOpen: _isOpen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoadingFirstPage) {
                return const LoadingSkeleton(count: 4, height: 132);
              }

              if (_controller.hasError) {
                return ErrorStateView(
                  message: _controller.errorMessage!,
                  onRetry: _controller.loadFirstPage,
                );
              }

              if (_controller.isEmpty) {
                return EmptyStateView(
                  icon: Icons.downhill_skiing_outlined,
                  title: t.trailsEmptyTitle,
                  message: _query != null || _difficultyId != null || _isOpen != null
                      ? t.trailsEmptyMessageFiltered
                      : t.trailsEmptyMessageNone,
                  actionLabel: t.resetFiltersAction,
                  onAction: () {
                    _searchController.clear();
                    _query = null;
                    _applyFilter(clear: true);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.xxxl,
                  ),
                  itemCount: _controller.items.length + (_controller.isLoadingNextPage ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index >= _controller.items.length) {
                      return const NextPageLoader();
                    }
                    return TrailCard(trail: _controller.items[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Kartica staze - prikazuje tezinu, status, duzinu, guzvu i uslove.
class TrailCard extends StatelessWidget {
  const TrailCard({super.key, required this.trail});

  final Trail trail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final difficultyColor = AppColors.fromHex(trail.difficultyColorHex);

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TrailDetailsScreen(trailId: trail.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: difficultyColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trail.code} · ${trail.difficultyName}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(style: StatusStyles.openClosed(context, isOpen: trail.isOpen)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _TrailMetric(
                  icon: Icons.straighten_rounded,
                  label: t.trailMetricLength,
                  value: trail.lengthLabel,
                ),
              ),
              Expanded(
                child: _TrailMetric(
                  icon: Icons.terrain_rounded,
                  label: t.trailMetricElevation,
                  value: '${trail.verticalDropMeters} m',
                ),
              ),
              Expanded(
                child: _TrailMetric(
                  icon: Icons.ac_unit_rounded,
                  label: t.trailMetricSnow,
                  value: trail.latestSnowDepthCm == null
                      ? '--'
                      : '${trail.latestSnowDepthCm} cm',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusChip(style: StatusStyles.crowd(context, trail.crowdLevel), compact: true),
              if (trail.hasNightSkiing)
                StatusChip(
                  compact: true,
                  style: StatusStyle(
                    label: t.trailNightSkiingLabel,
                    color: AppColors.info,
                    background: AppColors.infoSurface,
                    icon: Icons.nightlight_round,
                  ),
                ),
              if (trail.openIncidentCount > 0)
                StatusChip(
                  compact: true,
                  style: StatusStyle(
                    label: t.trailIncidentReportsCount(trail.openIncidentCount),
                    color: AppColors.warning,
                    background: AppColors.warningSurface,
                    icon: Icons.report_gmailerrorred_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrailMetric extends StatelessWidget {
  const _TrailMetric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _LiftsTab extends StatefulWidget {
  const _LiftsTab();

  @override
  State<_LiftsTab> createState() => _LiftsTabState();
}

class _LiftsTabState extends State<_LiftsTab> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  late final PagedListController<SkiLift> _controller;

  bool? _isOperational;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<SkiLift>(
      fetchPage: (page, pageSize) => context.read<CatalogService>().searchLifts(
            page: page,
            pageSize: pageSize,
            isOperational: _isOperational,
          ),
    );

    _scrollController.addListener(_onScroll);
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 320) {
      _controller.loadNextPage();
    }
  }

  void _setFilter(bool? value) {
    setState(() => _isOperational = value);
    _controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              _FilterChip(
                label: t.liftsFilterAll,
                isSelected: _isOperational == null,
                onSelected: () => _setFilter(null),
              ),
              _FilterChip(
                label: t.liftsFilterOperational,
                isSelected: _isOperational == true,
                onSelected: () => _setFilter(true),
              ),
              _FilterChip(
                label: t.liftsFilterNonOperational,
                isSelected: _isOperational == false,
                onSelected: () => _setFilter(false),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoadingFirstPage) {
                return const LoadingSkeleton(count: 4, height: 108);
              }

              if (_controller.hasError) {
                return ErrorStateView(
                  message: _controller.errorMessage!,
                  onRetry: _controller.loadFirstPage,
                );
              }

              if (_controller.isEmpty) {
                return EmptyStateView(
                  icon: Icons.cable_rounded,
                  title: t.liftsEmptyTitle,
                  message: t.liftsEmptyMessage,
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.xxxl,
                  ),
                  itemCount:
                      _controller.items.length + (_controller.isLoadingNextPage ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index >= _controller.items.length) {
                      return const NextPageLoader();
                    }
                    return _LiftCard(lift: _controller.items[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LiftCard extends StatelessWidget {
  const _LiftCard({required this.lift});

  final SkiLift lift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: lift.isOperational
                      ? AppColors.successSurface
                      : AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.cable_rounded,
                  size: AppSizes.iconMd,
                  color: lift.isOperational ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lift.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lift.liftTypeName} · ${t.liftRideDurationSuffix(lift.rideDurationMinutes)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(
                style: StatusStyles.openClosed(
                  context,
                  isOpen: lift.isOperational,
                  openLabel: t.liftsFilterOperational,
                  closedLabel: t.liftsFilterNonOperational,
                ),
              ),
            ],
          ),
          if (lift.isOperational) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  t.liftCurrentRiders(lift.currentRiders),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  t.liftCapacityLabel(lift.capacityPerHour),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: lift.occupancyRatio,
                minHeight: 5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ] else if (lift.openMaintenanceCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              t.liftOutOfServiceNotice,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: AppColors.primarySurface,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? AppColors.primaryDark
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
