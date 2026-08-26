import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../models/trail.dart';
import '../../services/catalog_service.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../incidents/report_incident_screen.dart';
import '../reviews/review_section.dart';

/// Detalji staze sa historijom uslova i ocjenama - master-details prikaz.
class TrailDetailsScreen extends StatefulWidget {
  const TrailDetailsScreen({super.key, required this.trailId});

  final int trailId;

  @override
  State<TrailDetailsScreen> createState() => _TrailDetailsScreenState();
}

class _TrailDetailsScreenState extends State<TrailDetailsScreen> {
  Trail? _trail;
  List<TrailConditionLog> _conditions = const [];
  List<Review> _reviews = const [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final catalog = context.read<CatalogService>();
      final engagement = context.read<EngagementService>();

      // Nezavisni pozivi se izvrsavaju paralelno umjesto jedan za drugim.
      final results = await Future.wait([
        catalog.getTrail(widget.trailId),
        catalog.getTrailConditions(widget.trailId, pageSize: 5),
        engagement.searchReviews(trailId: widget.trailId, pageSize: 5),
      ]);

      if (!mounted) return;

      setState(() {
        _trail = results[0] as Trail;
        _conditions = (results[1] as dynamic).items.cast<TrailConditionLog>();
        _reviews = (results[2] as dynamic).items.cast<Review>();
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_trail?.name ?? t.trailDetailsDefaultTitle)),
      body: _buildBody(),
      floatingActionButton: _trail == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final reported = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => ReportIncidentScreen(
                      preselectedTrailId: _trail!.id,
                      preselectedTrailName: _trail!.name,
                    ),
                  ),
                );
                if (reported == true) _load();
              },
              icon: const Icon(Icons.report_gmailerrorred_rounded),
              label: Text(t.trailReportProblemButton),
            ),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 4, height: 120);

    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _load);
    }

    final trail = _trail!;
    final difficultyColor = AppColors.fromHex(trail.difficultyColorHex);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          96,
        ),
        children: [
          _TrailSummaryCard(trail: trail, difficultyColor: difficultyColor),
          const SizedBox(height: AppSpacing.xl),

          if (trail.description != null && trail.description!.isNotEmpty) ...[
            SectionHeader(title: t.trailAboutSectionTitle),
            AppCard(
              child: Text(
                trail.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          SectionHeader(title: t.trailConditionsHistoryTitle),
          if (_conditions.isEmpty)
            AppCard(
              child: Text(t.trailNoConditionsRecorded),
            )
          else
            ..._conditions.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ConditionTile(log: log),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          ReviewSection(
            title: t.trailReviewsTitle,
            reviews: _reviews,
            targetType: 'Trail',
            trailId: trail.id,
            averageRating: trail.averageRating,
            reviewCount: trail.reviewCount,
            onChanged: _load,
          ),
        ],
      ),
    );
  }
}

class _TrailSummaryCard extends StatelessWidget {
  const _TrailSummaryCard({required this.trail, required this.difficultyColor});

  final Trail trail;
  final Color difficultyColor;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      trail.difficultyName,
                      style: theme.textTheme.labelMedium?.copyWith(color: difficultyColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StatusChip(style: StatusStyles.openClosed(context, isOpen: trail.isOpen)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),

          LabeledValue(
            label: t.trailCodeLabel,
            value: trail.code,
            icon: Icons.tag_rounded,
          ),
          LabeledValue(
            label: t.trailMetricLength,
            value: trail.lengthLabel,
            icon: Icons.straighten_rounded,
          ),
          LabeledValue(
            label: t.trailMetricElevation,
            value: '${trail.verticalDropMeters} m',
            icon: Icons.terrain_rounded,
          ),
          LabeledValue(
            label: t.trailCrowdLabel,
            value: StatusStyles.crowd(context, trail.crowdLevel).label,
            icon: Icons.groups_rounded,
          ),
          LabeledValue(
            label: t.trailSnowCoverLabel,
            value: trail.latestSnowDepthCm == null
                ? t.commonNoData
                : '${trail.latestSnowDepthCm} cm',
            icon: Icons.ac_unit_rounded,
          ),
          LabeledValue(
            label: t.trailNightSkiingLabel,
            value: trail.hasNightSkiing ? t.commonYes : t.commonNo,
            icon: Icons.nightlight_round,
          ),
          LabeledValue(
            label: t.trailSnowmakingLabel,
            value: trail.hasSnowmaking ? t.commonYes : t.commonNo,
            icon: Icons.water_drop_outlined,
          ),

          if (trail.latestConditionNote != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconSm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      trail.latestConditionNote!,
                      style: theme.textTheme.bodySmall,
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

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({required this.log});

  final TrailConditionLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text('${log.snowDepthCm}', style: theme.textTheme.titleMedium),
              Text('cm', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.conditionNote, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Formatters.dateTime(log.recordedAt)} · ${log.recordedByUserName}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          StatusChip(
            compact: true,
            style: StatusStyles.openClosed(context, isOpen: log.isTrailOpen),
          ),
        ],
      ),
    );
  }
}
