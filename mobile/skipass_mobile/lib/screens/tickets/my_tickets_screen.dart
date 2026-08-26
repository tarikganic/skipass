import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../models/ticket.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/purchase_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../orders/order_details_screen.dart';
import '../orders/orders_screen.dart';
import 'ticket_qr_screen.dart';

/// Karte prijavljenog korisnika, podijeljene na vazece i ranije.
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  late final PagedListController<SkiPassTicket> _activeController;
  late final PagedListController<SkiPassTicket> _historyController;

  @override
  void initState() {
    super.initState();

    final service = context.read<PurchaseService>();

    _activeController = PagedListController<SkiPassTicket>(
      fetchPage: (page, pageSize) => service.searchTickets(
        page: page,
        pageSize: pageSize,
        status: 'Active',
      ),
    );

    _historyController = PagedListController<SkiPassTicket>(
      fetchPage: (page, pageSize) => service.searchTickets(page: page, pageSize: pageSize),
    );

    _activeController.loadFirstPage();
    _historyController.loadFirstPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.myTicketsAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: t.orderHistoryTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.activeTicketsTab),
            Tab(text: t.allTicketsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TicketList(
            controller: _activeController,
            emptyTitle: t.noActiveTicketsTitle,
            emptyMessage: t.noActiveTicketsMessage,
          ),
          _TicketList(
            controller: _historyController,
            emptyTitle: t.noPurchasedTicketsTitle,
            emptyMessage: t.noPurchasedTicketsMessage,
          ),
        ],
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList({
    required this.controller,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final PagedListController<SkiPassTicket> controller;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoadingFirstPage) {
          return const LoadingSkeleton(count: 3, height: 150);
        }

        if (controller.hasError) {
          return ErrorStateView(
            message: controller.errorMessage!,
            onRetry: controller.loadFirstPage,
          );
        }

        if (controller.isEmpty) {
          return EmptyStateView(
            icon: Icons.confirmation_number_outlined,
            title: emptyTitle,
            message: emptyMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            itemCount: controller.items.length + (controller.hasNextPage ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index >= controller.items.length) {
                if (controller.isLoadingNextPage) return const NextPageLoader();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: OutlinedButton(
                    onPressed: controller.loadNextPage,
                    child: Text(AppLocalizations.of(context)!.loadMoreButton),
                  ),
                );
              }

              return TicketCard(ticket: controller.items[index]);
            },
          ),
        );
      },
    );
  }
}

/// Kartica ski pass karte, u stilu papirne karte sa perforacijom.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.showOrderLink = true});

  final SkiPassTicket ticket;
  final bool showOrderLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final status = StatusStyles.ticket(context, ticket.status);
    final isUsable = ticket.isValidToday;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: isUsable
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => TicketQrScreen(ticket: ticket)),
              )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.ticketTypeName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(ticket.skiResortName, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusChip(style: status),
              ],
            ),
          ),
          const _TicketPerforation(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TicketField(
                        label: t.ticketHolderLabel,
                        value: ticket.holderFullName,
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    Expanded(
                      child: _TicketField(
                        label: t.ticketValidLabel,
                        value: Formatters.dateRange(ticket.validFrom, ticket.validTo),
                        icon: Icons.event_available_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _TicketField(
                        label: t.ticketDurationLabel,
                        value: Formatters.days(ticket.numberOfDays),
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    Expanded(
                      child: _TicketField(
                        label: t.ticketScansLabel,
                        value: '${ticket.validationCount}',
                        icon: Icons.qr_code_scanner_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isUsable)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TicketQrScreen(ticket: ticket),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: Text(t.showQrButton),
                  )
                else
                  // Nedostupna akcija ima onemoguceno stanje uz objasnjenje razloga.
                  Column(
                    children: [
                      FilledButton(
                        onPressed: null,
                        child: Text(t.showQrButton),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _unavailableReason(t),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                if (showOrderLink) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailsScreen(orderId: ticket.orderId),
                      ),
                    ),
                    child: Text(t.orderLinkLabel(ticket.orderNumber)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _unavailableReason(AppLocalizations t) {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);

    return switch (ticket.status) {
      'Pending' => t.ticketUnavailablePending,
      'Cancelled' => t.ticketUnavailableCancelled,
      'Expired' => t.ticketUnavailableExpired(Formatters.date(ticket.validTo)),
      _ when day.isBefore(ticket.validFrom) =>
        t.ticketNotYetValid(Formatters.date(ticket.validFrom)),
      _ when day.isAfter(ticket.validTo) =>
        t.ticketNoLongerValid(Formatters.date(ticket.validTo)),
      _ => t.ticketUnavailableGeneric,
    };
  }
}

class _TicketField extends StatelessWidget {
  const _TicketField({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Isprekidana linija koja karticu vizuelno dijeli kao papirnu kartu.
class _TicketPerforation extends StatelessWidget {
  const _TicketPerforation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          _Notch(color: theme.scaffoldBackgroundColor, alignment: Alignment.centerLeft),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 5.0;
                final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    dashCount,
                    (_) => Container(
                      width: dashWidth,
                      height: 1.2,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                );
              },
            ),
          ),
          _Notch(color: theme.scaffoldBackgroundColor, alignment: Alignment.centerRight),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch({required this.color, required this.alignment});

  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 20,
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

/// Kartica narudzbe u listi historije kupovina.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final SkiPassOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => OrderDetailsScreen(orderId: order.id)),
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
                    Text(order.orderNumber, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(order.orderDate),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(style: StatusStyles.order(context, order.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(Formatters.tickets(order.ticketCount), style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                Formatters.money(order.totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (order.awaitsPayment) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      t.orderAwaitingPaymentBadge,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
