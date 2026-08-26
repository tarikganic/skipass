import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/reference_item.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/reference_data_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/list_scaffold.dart';
import 'reference_item_form_dialog.dart';

/// Referentni podaci - CRUD nad svih osam sifarnika, dostupno samo administratoru.
class ReferenceDataScreen extends StatefulWidget {
  const ReferenceDataScreen({super.key});

  @override
  State<ReferenceDataScreen> createState() => _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends State<ReferenceDataScreen> {
  ReferenceTableConfig _selected = ReferenceTableConfig.all.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.lg),
          child: Text(l10n.navReferenceData, style: theme.textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final config in ReferenceTableConfig.all)
                ChoiceChip(
                  label: Text(config.label),
                  selected: _selected.resource == config.resource,
                  onSelected: (_) => setState(() => _selected = config),
                ),
            ],
          ),
        ),
        Expanded(
          child: _ReferenceTableView(key: ValueKey(_selected.resource), config: _selected),
        ),
      ],
    );
  }
}

class _ReferenceTableView extends StatefulWidget {
  const _ReferenceTableView({super.key, required this.config});

  final ReferenceTableConfig config;

  @override
  State<_ReferenceTableView> createState() => _ReferenceTableViewState();
}

class _ReferenceTableViewState extends State<_ReferenceTableView> {
  late final PagedListController<ReferenceItem> _controller;
  String? _query;
  int? _countryId;
  List<Lookup> _countries = const [];

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<ReferenceItem>(
      fetchPage: (page, pageSize) => context.read<ReferenceDataService>().search(
            widget.config.resource,
            page: page,
            pageSize: pageSize,
            query: _query,
            countryId: widget.config.hasCountry ? _countryId : null,
          ),
      pageSize: 50,
    );
    _controller.loadFirstPage();
    if (widget.config.hasCountry) _loadCountries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final items = await context.read<ReferenceDataService>().lookup('Countries');
    if (mounted) setState(() => _countries = items);
  }

  Future<void> _openForm({ReferenceItem? existing}) async {
    final result = await showDialog<ReferenceItem>(
      context: context,
      builder: (_) => ReferenceItemFormDialog(config: widget.config, existing: existing),
    );
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(ReferenceItem item) async {
    final l10n = AppLocalizations.of(context)!;
    if ((item.relatedCount ?? 0) > 0) {
      AppFeedback.error(context, l10n.referenceDataScreenDeleteBlockedError(item.relatedCount ?? 0));
      return;
    }

    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.referenceDataScreenDeleteConfirmTitle,
      message: l10n.referenceDataScreenDeleteConfirmMessage(item.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<ReferenceDataService>().delete(widget.config.resource, item.id);
      _controller.removeWhere((i) => i.id == item.id);
      if (mounted) AppFeedback.success(context, l10n.referenceDataScreenDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<ReferenceItem>(
      title: widget.config.label,
      controller: _controller,
      searchHint: l10n.referenceDataScreenSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: !widget.config.hasCountry
          ? null
          : DropdownButton<int?>(
              value: _countryId,
              hint: Text(l10n.referenceDataScreenAllCountries),
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem<int?>(child: Text(l10n.referenceDataScreenAllCountries)),
                for (final country in _countries) DropdownMenuItem<int?>(value: country.id, child: Text(country.name)),
              ],
              onChanged: (value) {
                setState(() => _countryId = value);
                _controller.loadFirstPage();
              },
            ),
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.referenceDataScreenAddButton(widget.config.singularLabel)),
        ),
      ],
      emptyIcon: Icons.list_alt_rounded,
      emptyTitle: l10n.reportIncidentDialogNoRecords,
      itemBuilder: (context, item) => _ReferenceItemRow(
        config: widget.config,
        item: item,
        onEdit: () => _openForm(existing: item),
        onDelete: () => _delete(item),
      ),
    );
  }
}

class _ReferenceItemRow extends StatelessWidget {
  const _ReferenceItemRow({required this.config, required this.item, required this.onEdit, required this.onDelete});

  final ReferenceTableConfig config;
  final ReferenceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          if (config.hasColor)
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.fromHex(item.colorHex), shape: BoxShape.circle),
            ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleSmall),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(item.description!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (config.hasIsoCode) Expanded(child: Text(item.isoCode ?? '', style: theme.textTheme.bodySmall)),
          if (config.hasPostalCode)
            Expanded(child: Text(item.countryName ?? '', style: theme.textTheme.bodySmall)),
          if (config.hasCode) Expanded(child: Text(item.code ?? '', style: theme.textTheme.bodySmall)),
          if (config.hasSortOrder) Expanded(child: Text(l10n.referenceDataScreenSortOrderLabel(item.sortOrder ?? 0), style: theme.textTheme.bodySmall)),
          if (config.hasUrgentFlag && item.isUrgentByDefault == true)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(Icons.priority_high_rounded, color: AppColors.warning, size: AppSizes.iconSm),
            ),
          if (config.hasOnlineFlag && item.isOnline == true)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(Icons.wifi_rounded, color: AppColors.info, size: AppSizes.iconSm),
            ),
          if (config.hasActiveFlag && item.isActive == false)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(l10n.ticketTypeInactiveLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          Text(l10n.referenceDataScreenRelatedCountLabel(item.relatedCount ?? 0), style: theme.textTheme.bodySmall),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger), onPressed: onDelete),
        ],
      ),
    );
  }
}
