import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/incident.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import 'report_incident_screen.dart';

/// Prijave incidenata koje je korisnik podnio.
class MyIncidentsScreen extends StatefulWidget {
  const MyIncidentsScreen({super.key});

  @override
  State<MyIncidentsScreen> createState() => _MyIncidentsScreenState();
}

class _MyIncidentsScreenState extends State<MyIncidentsScreen> {
  late final PagedListController<Incident> _controller;
  String? _status;

  Map<String, String> _statusFilters(AppLocalizations t) => <String, String>{
        'Reported': t.incidentStatusReportedFilter,
        'InProgress': t.statusIncidentInProgress,
        'Resolved': t.incidentStatusResolvedFilter,
        'Rejected': t.incidentStatusRejectedFilter,
      };

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<Incident>(
      fetchPage: (page, pageSize) => context.read<EngagementService>().searchIncidents(
            page: page,
            pageSize: pageSize,
            status: _status,
          ),
    );

    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setStatus(String? status) {
    setState(() => _status = status);
    _controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.myIncidentsAppBarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final reported = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const ReportIncidentScreen()),
          );
          if (reported == true) _controller.refresh();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(t.incidentNewReportButton),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(t.commonAll),
                    selected: _status == null,
                    showCheckmark: false,
                    onSelected: (_) => _setStatus(null),
                  ),
                ),
                ..._statusFilters(t).entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: _status == entry.key,
                      showCheckmark: false,
                      onSelected: (_) =>
                          _setStatus(_status == entry.key ? null : entry.key),
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
                  return const LoadingSkeleton(count: 3, height: 130);
                }

                if (_controller.hasError) {
                  return ErrorStateView(
                    message: _controller.errorMessage!,
                    onRetry: _controller.loadFirstPage,
                  );
                }

                if (_controller.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.report_gmailerrorred_outlined,
                    title: _status == null
                        ? t.incidentsEmptyTitleNone
                        : t.incidentsEmptyTitleFiltered,
                    message: t.incidentsEmptyMessage,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.sm,
                      AppSpacing.screen,
                      96,
                    ),
                    itemCount:
                        _controller.items.length + (_controller.isLoadingNextPage ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index >= _controller.items.length) {
                        return const NextPageLoader();
                      }
                      return _IncidentCard(incident: _controller.items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final imageUrl = AppConfig.resolveImageUrl(incident.imageUrl);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incident.incidentTypeName, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${incident.locationLabel} · ${Formatters.relative(incident.reportedAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(style: StatusStyles.incident(context, incident.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            incident.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          if (incident.resolutionNote != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: incident.status == 'Rejected'
                    ? AppColors.dangerSurface
                    : AppColors.successSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.status == 'Rejected'
                        ? t.incidentRejectionReasonTitle
                        : t.incidentStaffNoteTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    incident.resolutionNote!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (incident.handledByUserName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${incident.handledByUserName} · '
                      '${incident.handledAt == null ? '' : Formatters.dateTime(incident.handledAt!)}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
