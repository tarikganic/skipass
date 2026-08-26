import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/purchase_service.dart';
import '../../widgets/state_views.dart';
import '../tickets/my_tickets_screen.dart';

/// Historija narudzbi prijavljenog korisnika.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final PagedListController<SkiPassOrder> _controller;
  final _scrollController = ScrollController();

  String? _status;

  Map<String, String> _statusFilters(AppLocalizations t) => <String, String>{
        'Pending': t.statusOrderPending,
        'Confirmed': t.orderStatusConfirmedFilter,
        'Completed': t.orderStatusCompletedFilter,
        'Cancelled': t.orderStatusCancelledFilter,
      };

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<SkiPassOrder>(
      fetchPage: (page, pageSize) => context.read<PurchaseService>().searchOrders(
            page: page,
            pageSize: pageSize,
            status: _status,
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
        _scrollController.position.maxScrollExtent - 280) {
      _controller.loadNextPage();
    }
  }

  void _setStatus(String? status) {
    setState(() => _status = status);
    _controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.ordersAppBarTitle)),
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
                  return const LoadingSkeleton(count: 4, height: 118);
                }

                if (_controller.hasError) {
                  return ErrorStateView(
                    message: _controller.errorMessage!,
                    onRetry: _controller.loadFirstPage,
                  );
                }

                if (_controller.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: _status == null
                        ? t.ordersEmptyTitleNone
                        : t.ordersEmptyTitleFiltered,
                    message: _status == null
                        ? t.ordersEmptyMessageNone
                        : t.ordersEmptyMessageFiltered,
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
                      return OrderCard(order: _controller.items[index]);
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
