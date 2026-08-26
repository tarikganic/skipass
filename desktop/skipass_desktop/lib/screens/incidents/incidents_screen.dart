import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/incident.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

const _columns = ['Reported', 'InProgress', 'Resolved', 'Rejected'];

Map<String, String> _columnLabels(AppLocalizations l10n) => {
      'Reported': l10n.incidentsColumnReported,
      'InProgress': l10n.incidentsColumnInProgress,
      'Resolved': l10n.incidentsColumnResolved,
      'Rejected': l10n.incidentsColumnRejected,
    };

/// Incidenti - Kanban tabla po statusu, odgovara mockupu "Incidenti" iz prijave.
class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  late final PagedListController<Incident> _controller;
  String? _query;

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<Incident>(
      fetchPage: (page, pageSize) => context.read<EngagementService>().searchIncidents(page: page, pageSize: pageSize, query: _query),
    );
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(Incident incident, String status) async {
    final l10n = AppLocalizations.of(context)!;
    String? note;

    if (status == 'Resolved' || status == 'Rejected') {
      note = await AppFeedback.promptReason(
        context,
        title: status == 'Resolved' ? l10n.incidentsScreenResolveTitle : l10n.incidentsScreenRejectTitle,
        label: l10n.liftMaintenanceDialogReasonLabel,
        confirmLabel: l10n.commonConfirm,
      );
      if (note == null) return;
    }

    try {
      await context.read<EngagementService>().updateIncidentStatus(incident.id, status, note);
      _controller.refresh();
      if (mounted) AppFeedback.success(context, l10n.incidentsScreenStatusUpdateSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  Future<void> _delete(Incident incident) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.incidentsScreenDeleteConfirmTitle,
      message: l10n.incidentsScreenDeleteConfirmMessage(incident.id),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<EngagementService>().deleteIncident(incident.id);
      _controller.removeWhere((i) => i.id == incident.id);
      if (mounted) AppFeedback.success(context, l10n.incidentsScreenDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.lg),
          child: Row(
            children: [
              Text(l10n.navIncidents, style: theme.textTheme.headlineSmall),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: l10n.commonRefresh, onPressed: _controller.refresh),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.lg),
          child: SizedBox(
            width: 340,
            child: TextField(
              onChanged: (value) {
                _query = value.trim().isEmpty ? null : value.trim();
                _controller.loadFirstPage();
              },
              decoration: InputDecoration(
                hintText: l10n.incidentsScreenSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoadingFirstPage) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.hasError) {
                return ErrorStateView(message: _controller.errorMessage!, onRetry: _controller.loadFirstPage);
              }

              final grouped = {for (final status in _columns) status: <Incident>[]};
              for (final incident in _controller.items) {
                (grouped[incident.status] ??= []).add(incident);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final status in _columns)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.lg, bottom: AppSpacing.xxl),
                          child: _KanbanColumn(
                            status: status,
                            incidents: grouped[status] ?? const [],
                            onStatusChange: _changeStatus,
                            onDelete: _delete,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.incidents,
    required this.onStatusChange,
    required this.onDelete,
  });

  final String status;
  final List<Incident> incidents;
  final void Function(Incident, String) onStatusChange;
  final void Function(Incident) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(_columnLabels(l10n)[status] ?? status, style: theme.textTheme.titleSmall),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text('${incidents.length}', style: theme.textTheme.labelSmall),
                ),
              ],
            ),
          ),
          Expanded(
            child: incidents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(l10n.incidentsColumnEmpty, style: theme.textTheme.bodySmall),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                    itemCount: incidents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _IncidentCard(
                      incident: incidents[index],
                      onStatusChange: (newStatus) => onStatusChange(incidents[index], newStatus),
                      onDelete: () => onDelete(incidents[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onStatusChange, required this.onDelete});

  final Incident incident;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('#${incident.id} · ${incident.incidentTypeName}', style: theme.textTheme.labelLarge)),
              if (incident.isUrgent)
                StatusChip(
                  compact: true,
                  style: StatusStyle(label: l10n.incidentsUrgentLabel, color: AppColors.danger, background: AppColors.dangerSurface, icon: Icons.priority_high_rounded),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(incident.description, style: theme.textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${incident.locationLabel} · ${Formatters.dateTime(incident.reportedAt)}',
            style: theme.textTheme.labelSmall,
          ),
          Text(incident.reportedByUserName, style: theme.textTheme.labelSmall),
          if (incident.resolutionNote != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(incident.resolutionNote!, style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
          if (incident.allowedNextStatuses.isNotEmpty || incident.status == 'Rejected') ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final status in incident.allowedNextStatuses)
                  OutlinedButton(
                    onPressed: () => onStatusChange(status),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 30), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
                    child: Text(_actionLabel(l10n, status), style: theme.textTheme.labelSmall),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.danger),
                  tooltip: l10n.incidentsScreenDeleteTooltip,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  padding: EdgeInsets.zero,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _actionLabel(AppLocalizations l10n, String status) => switch (status) {
        'InProgress' => l10n.incidentsActionTakeOver,
        'Resolved' => l10n.incidentsActionResolve,
        'Rejected' => l10n.incidentsActionReject,
        _ => status,
      };
}
