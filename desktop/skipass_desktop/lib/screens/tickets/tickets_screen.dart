import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ticket.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/order_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/status_chip.dart';
import 'order_detail_dialog.dart';
import 'ticket_type_dialog.dart';
import 'validate_ticket_dialog.dart';

/// Karte i tipovi karata - odgovara mockupu "Karte" iz prijave.
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> with SingleTickerProviderStateMixin {
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
            tabs: [Tab(text: l10n.navTickets), Tab(text: l10n.ticketsTabTypes)],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_TicketsTab(), _TicketTypesTab()],
          ),
        ),
      ],
    );
  }
}

class _TicketsTab extends StatefulWidget {
  const _TicketsTab();

  @override
  State<_TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<_TicketsTab> {
  late final PagedListController<SkiPassTicket> _controller;
  String? _status;
  String? _query;

  Map<String, String> _statusOptions(AppLocalizations l10n) => {
        'Pending': l10n.ticketFilterStatusPending,
        'Active': l10n.ticketFilterStatusActive,
        'Used': l10n.ticketFilterStatusUsed,
        'Expired': l10n.ticketFilterStatusExpired,
        'Cancelled': l10n.ticketFilterStatusCancelled,
      };

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<SkiPassTicket>(
      fetchPage: (page, pageSize) => context.read<OrderService>().searchTickets(
            page: page,
            pageSize: pageSize,
            query: _query,
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

  Future<void> _openOrder(int orderId) async {
    await showDialog<void>(context: context, builder: (_) => OrderDetailDialog(orderId: orderId));
    _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusOptions = _statusOptions(l10n);

    return ListScaffold<SkiPassTicket>(
      title: l10n.navTickets,
      controller: _controller,
      searchHint: l10n.ticketsSearchHint,
      onSearchChanged: (value) {
        _query = value.trim().isEmpty ? null : value.trim();
        _controller.loadFirstPage();
      },
      filters: DropdownButton<String?>(
        value: _status,
        hint: Text(l10n.commonAllStatuses),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<String?>(child: Text(l10n.commonAllStatuses)),
          for (final entry in statusOptions.entries)
            DropdownMenuItem<String?>(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (value) {
          setState(() => _status = value);
          _controller.loadFirstPage();
        },
      ),
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await showDialog<void>(context: context, builder: (_) => const ValidateTicketDialog());
            _controller.refresh();
          },
          icon: const Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm),
          label: Text(l10n.ticketsValidateButton),
        ),
      ],
      emptyIcon: Icons.confirmation_number_outlined,
      emptyTitle: l10n.ticketsEmptyTitle,
      itemBuilder: (context, ticket) => _TicketRow(ticket: ticket, onTap: () => _openOrder(ticket.orderId)),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket, required this.onTap});

  final SkiPassTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('#${ticket.id}', style: theme.textTheme.bodySmall)),
          Expanded(
            flex: 3,
            child: Text(ticket.holderFullName, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Formatters.dateRange(ticket.validFrom, ticket.validTo),
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Text(Formatters.days(ticket.numberOfDays), style: theme.textTheme.bodySmall)),
          Expanded(
            flex: 2,
            child: Text(ticket.ticketTypeName, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(ticket.paymentMethodName, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(style: StatusStyles.ticket(ticket.status), compact: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketTypesTab extends StatefulWidget {
  const _TicketTypesTab();

  @override
  State<_TicketTypesTab> createState() => _TicketTypesTabState();
}

class _TicketTypesTabState extends State<_TicketTypesTab> {
  late final PagedListController<TicketType> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PagedListController<TicketType>(
      fetchPage: (page, pageSize) => context.read<OrderService>().searchTicketTypes(page: page, pageSize: pageSize),
      pageSize: 50,
    );
    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm({TicketType? existing}) async {
    final result = await showDialog<TicketType>(
      context: context,
      builder: (_) => TicketTypeDialog(existing: existing),
    );
    if (result != null) _controller.refresh();
  }

  Future<void> _delete(TicketType ticketType) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: l10n.ticketTypeDeleteConfirmTitle,
      message: l10n.ticketTypeDeleteConfirmMessage(ticketType.name),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await context.read<OrderService>().deleteTicketType(ticketType.id);
      _controller.refresh();
      if (mounted) AppFeedback.success(context, l10n.ticketTypeDeleteSuccess);
    } catch (error) {
      if (mounted) AppFeedback.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListScaffold<TicketType>(
      title: l10n.ticketsTabTypes,
      controller: _controller,
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
          label: Text(l10n.ticketTypeAddButton),
        ),
      ],
      emptyIcon: Icons.confirmation_number_outlined,
      emptyTitle: l10n.ticketTypesEmptyTitle,
      emptyMessage: l10n.ticketTypesEmptyMessage,
      itemBuilder: (context, item) {
        final theme = Theme.of(context);
        final rowL10n = AppLocalizations.of(context)!;

        return AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.name, style: theme.textTheme.titleSmall),
                        if (!item.isActive) ...[
                          const SizedBox(width: AppSpacing.sm),
                          StatusChip(
                            compact: true,
                            style: StatusStyle(
                              label: rowL10n.ticketTypeInactiveLabel,
                              color: AppColors.textSecondary,
                              background: AppColors.surfaceAlt,
                              icon: Icons.visibility_off_outlined,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rowL10n.ticketTypePriceLabel(Formatters.money(item.pricePerDay), item.maxDays) +
                          (item.discountPercentage > 0
                              ? rowL10n.ticketTypeDiscountSuffix(item.discountPercentage.toStringAsFixed(0))
                              : ''),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _openForm(existing: item)),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: () => _delete(item),
              ),
            ],
          ),
        );
      },
    );
  }
}
