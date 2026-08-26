import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/ski_lift.dart';
import '../../models/trail.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/reference_data_service.dart';
import '../../services/resort_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/status_chip.dart';
import 'lift_maintenance_dialog.dart';
import 'ski_lift_form_dialog.dart';
import 'trail_condition_dialog.dart';
import 'trail_form_dialog.dart';

/// Staze i ski liftovi - odgovara mockupu "Staze i ski liftovi" iz prijave.
class ResortsScreen extends StatefulWidget {
  const ResortsScreen({super.key});

  @override
  State<ResortsScreen> createState() => _ResortsScreenState();
}

class _ResortsScreenState extends State<ResortsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.lg, AppSpacing.page, 0),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [Tab(text: l10n.resortsTabTrails), Tab(text: l10n.resortsTabLifts)],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_TrailsTab(), _LiftsTab()],
          ),
        ),
      ],
    );
  }
}

class _TrailsTab extends StatefulWidget {
  const _TrailsTab();

  @override
  State<_TrailsTab> createState() => _TrailsTabState();
}

class _TrailsTabState extends State<_TrailsTab> {
  late final PagedListController<Trail> _controller;
  String? _query;
  int? _difficultyId;
  List<Lookup> _difficulties = const [];

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<Trail>(
      fetchPage: (page, pageSize) => context.read<ResortService>().searchTrails(
            page: page,
            pageSize: pageSize,
            query: _query,
            difficultyId: _difficultyId,
          ),
    );
    _controller.loadFirstPage();
    _loadDifficulties();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDifficulties() async {
    final items = await context.read<ReferenceDataService>().lookup('TrailDifficulties');
    if (mounted) setState(() => _difficulties = items);
  }

  Future<void> _openForm({Trail? existing}) async {
    final result = await showDialog<Trail>(context: context, builder: (_) => TrailFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _openConditions(Trail trail) async {
    final changed = await showDialog<bool>(context: context, builder: (_) => TrailConditionDialog(trail: trail));
    if (changed == true) _controller.refresh();
  }

  Future<void> _delete(Trail trail) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.trailDeleteConfirmTitle,
      message: l10n.trailDeleteConfirmMessage(trail.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<ResortService>().deleteTrail(trail.id);
      _controller.removeWhere((t) => t.id == trail.id);
      if (mounted) AppFeedback.success(context, l10n.trailDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<Trail>(
      title: l10n.resortsTabTrails,
      controller: _controller,
      searchHint: l10n.trailsSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: DropdownButton<int?>(
        value: _difficultyId,
        hint: Text(l10n.trailsAllDifficulties),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<int?>(child: Text(l10n.trailsAllDifficulties)),
          for (final difficulty in _difficulties) DropdownMenuItem<int?>(value: difficulty.id, child: Text(difficulty.name)),
        ],
        onChanged: (value) {
          setState(() => _difficultyId = value);
          _controller.loadFirstPage();
        },
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.trailsAddButton),
        ),
      ],
      emptyIcon: Icons.downhill_skiing_outlined,
      emptyTitle: l10n.trailsEmptyTitle,
      emptyMessage: l10n.trailsEmptyMessage,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppSizes.cardWidth,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, trail) => _TrailCard(
        trail: trail,
        onEdit: () => _openForm(existing: trail),
        onDelete: () => _delete(trail),
        onConditions: () => _openConditions(trail),
      ),
    );
  }
}

class _TrailCard extends StatelessWidget {
  const _TrailCard({required this.trail, required this.onEdit, required this.onDelete, required this.onConditions});

  final Trail trail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConditions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final difficultyColor = AppColors.fromHex(trail.difficultyColorHex);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: trail.imageUrl,
                seed: trail.name,
                height: AppSizes.cardImageHeight,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: StatusChip(style: StatusStyles.openClosed(isOpen: trail.isOpen), compact: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: difficultyColor, shape: BoxShape.circle)),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(trail.name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${trail.code} · ${trail.lengthLabel}', style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: EdgeInsets.zero),
                        child: Text(l10n.commonEditShort),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          padding: EdgeInsets.zero,
                          foregroundColor: AppColors.danger,
                        ),
                        child: Text(l10n.commonDelete),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onConditions,
                    icon: const Icon(Icons.ac_unit_rounded, size: AppSizes.iconSm),
                    label: Text(l10n.trailConditionButton),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftsTab extends StatefulWidget {
  const _LiftsTab();

  @override
  State<_LiftsTab> createState() => _LiftsTabState();
}

class _LiftsTabState extends State<_LiftsTab> {
  late final PagedListController<SkiLift> _controller;
  String? _query;
  bool? _isOperational;

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<SkiLift>(
      fetchPage: (page, pageSize) => context.read<ResortService>().searchLifts(
            page: page,
            pageSize: pageSize,
            query: _query,
            isOperational: _isOperational,
          ),
    );
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm({SkiLift? existing}) async {
    final result = await showDialog<SkiLift>(context: context, builder: (_) => SkiLiftFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _openMaintenance(SkiLift lift) async {
    final changed = await showDialog<bool>(context: context, builder: (_) => LiftMaintenanceDialog(lift: lift));
    if (changed == true) _controller.refresh();
  }

  Future<void> _toggleOperational(SkiLift lift) async {
    try {
      await context.read<ResortService>().updateLiftStatus(lift.id, !lift.isOperational);
      _controller.refresh();
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  Future<void> _delete(SkiLift lift) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.liftDeleteConfirmTitle,
      message: l10n.liftDeleteConfirmMessage(lift.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<ResortService>().deleteLift(lift.id);
      _controller.removeWhere((l) => l.id == lift.id);
      if (mounted) AppFeedback.success(context, l10n.liftDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<SkiLift>(
      title: l10n.resortsTabLifts,
      controller: _controller,
      searchHint: l10n.liftsSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: DropdownButton<bool?>(
        value: _isOperational,
        hint: Text(l10n.commonAllStatuses),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<bool?>(child: Text(l10n.commonAllStatuses)),
          DropdownMenuItem<bool?>(value: true, child: Text(l10n.liftStatusOperational)),
          DropdownMenuItem<bool?>(value: false, child: Text(l10n.liftStatusNotOperational)),
        ],
        onChanged: (value) {
          setState(() => _isOperational = value);
          _controller.loadFirstPage();
        },
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.liftsAddButton),
        ),
      ],
      emptyIcon: Icons.cable_rounded,
      emptyTitle: l10n.liftsEmptyTitle,
      itemBuilder: (context, lift) => _LiftCard(
        lift: lift,
        onEdit: () => _openForm(existing: lift),
        onDelete: () => _delete(lift),
        onToggle: () => _toggleOperational(lift),
        onMaintenance: () => _openMaintenance(lift),
      ),
    );
  }
}

class _LiftCard extends StatelessWidget {
  const _LiftCard({
    required this.lift,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onMaintenance,
  });

  final SkiLift lift;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onMaintenance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: lift.isOperational ? AppColors.successSurface : AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.cable_rounded, color: lift.isOperational ? AppColors.success : AppColors.danger),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lift.name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                    Text('${lift.code} · ${lift.liftTypeName}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Switch(value: lift.isOperational, onChanged: (_) => onToggle()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.people_alt_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(l10n.liftRidersLabel(lift.currentRiders, lift.capacityPerHour), style: theme.textTheme.bodySmall),
              if (lift.openMaintenanceCount > 0) ...[
                const SizedBox(width: AppSpacing.md),
                StatusChip(
                  compact: true,
                  style: StatusStyle(
                    label: l10n.liftOpenMaintenanceCount(lift.openMaintenanceCount),
                    color: AppColors.warning,
                    background: AppColors.warningSurface,
                    icon: Icons.report_problem_outlined,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                label: Text(l10n.commonEditShort),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onMaintenance,
                icon: const Icon(Icons.build_outlined, size: AppSizes.iconSm),
                label: Text(l10n.liftMaintenanceButton),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
