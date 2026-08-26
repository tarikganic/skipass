import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/benefit.dart';
import '../../models/paged_result.dart';
import '../../models/partner.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/benefit_service.dart';
import '../../services/reference_data_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/list_scaffold.dart';
import 'benefit_form_dialog.dart';
import 'partner_form_dialog.dart';

/// Usluge i pogodnosti - odgovara mockupu "Usluge" iz prijave.
class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> with SingleTickerProviderStateMixin {
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
            tabs: [Tab(text: l10n.navBenefits), Tab(text: l10n.benefitsTabPartners)],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_BenefitsTab(), _PartnersTab()],
          ),
        ),
      ],
    );
  }
}

class _BenefitsTab extends StatefulWidget {
  const _BenefitsTab();

  @override
  State<_BenefitsTab> createState() => _BenefitsTabState();
}

class _BenefitsTabState extends State<_BenefitsTab> {
  late final PagedListController<Benefit> _controller;
  String? _query;
  int? _categoryId;
  List<Lookup> _categories = const [];

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<Benefit>(
      fetchPage: (page, pageSize) => context.read<BenefitService>().searchBenefits(
            page: page,
            pageSize: pageSize,
            query: _query,
            categoryId: _categoryId,
          ),
    );
    _controller.loadFirstPage();
    _loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final items = await context.read<ReferenceDataService>().lookup('BenefitCategories');
    if (mounted) setState(() => _categories = items);
  }

  Future<void> _openForm({Benefit? existing}) async {
    final result = await showDialog<Benefit>(context: context, builder: (_) => BenefitFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(Benefit benefit) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.benefitDeleteConfirmTitle,
      message: l10n.benefitDeleteConfirmMessage(benefit.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<BenefitService>().deleteBenefit(benefit.id);
      _controller.removeWhere((b) => b.id == benefit.id);
      if (mounted) AppFeedback.success(context, l10n.benefitDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<Benefit>(
      title: l10n.navBenefits,
      controller: _controller,
      searchHint: l10n.benefitsSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: DropdownButton<int?>(
        value: _categoryId,
        hint: Text(l10n.announcementsScreenAllCategories),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<int?>(child: Text(l10n.announcementsScreenAllCategories)),
          for (final category in _categories) DropdownMenuItem<int?>(value: category.id, child: Text(category.name)),
        ],
        onChanged: (value) {
          setState(() => _categoryId = value);
          _controller.loadFirstPage();
        },
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.benefitsAddButton),
        ),
      ],
      emptyIcon: Icons.local_offer_outlined,
      emptyTitle: l10n.benefitsEmptyTitle,
      emptyMessage: l10n.benefitsEmptyMessage,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppSizes.cardWidth,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, benefit) => _BenefitCard(
        benefit: benefit,
        onEdit: () => _openForm(existing: benefit),
        onDelete: () => _delete(benefit),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit, required this.onEdit, required this.onDelete});

  final Benefit benefit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: benefit.imageUrl,
                seed: benefit.name,
                height: AppSizes.cardImageHeight,
                width: double.infinity,
                icon: Icons.local_offer_outlined,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              if (!benefit.isActive)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Text(l10n.announcementsScreenInactiveLabel, style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${benefit.categoryName} · ${benefit.skiResortName}', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(Formatters.money(benefit.effectivePrice), style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                    if (benefit.hasDiscount) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        Formatters.money(benefit.price),
                        style: theme.textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnersTab extends StatefulWidget {
  const _PartnersTab();

  @override
  State<_PartnersTab> createState() => _PartnersTabState();
}

class _PartnersTabState extends State<_PartnersTab> {
  late final PagedListController<Partner> _controller;
  String? _query;

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<Partner>(
      fetchPage: (page, pageSize) => context.read<BenefitService>().searchPartners(page: page, pageSize: pageSize, query: _query),
    );
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm({Partner? existing}) async {
    final result = await showDialog<Partner>(context: context, builder: (_) => PartnerFormDialog(existing: existing));
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(Partner partner) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.partnerDeleteConfirmTitle,
      message: l10n.partnerDeleteConfirmMessage(partner.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<BenefitService>().deletePartner(partner.id);
      _controller.removeWhere((p) => p.id == partner.id);
      if (mounted) AppFeedback.success(context, l10n.partnerDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<Partner>(
      title: l10n.benefitsTabPartners,
      controller: _controller,
      searchHint: l10n.partnersSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.partnersAddButton),
        ),
      ],
      emptyIcon: Icons.handshake_outlined,
      emptyTitle: l10n.partnersEmptyTitle,
      itemBuilder: (context, partner) => _PartnerRow(
        partner: partner,
        onEdit: () => _openForm(existing: partner),
        onDelete: () => _delete(partner),
      ),
    );
  }
}

class _PartnerRow extends StatelessWidget {
  const _PartnerRow({required this.partner, required this.onEdit, required this.onDelete});

  final Partner partner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: partner.isActive ? AppColors.successSurface : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.handshake_outlined, color: partner.isActive ? AppColors.success : AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${l10n.partnerBenefitCountLabel(partner.benefitCount)}${partner.address != null ? ' · ${partner.address}' : ''}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!partner.isActive)
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
}
