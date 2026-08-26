import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../services/purchase_service.dart';
import '../../services/stripe_checkout.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../tickets/my_tickets_screen.dart';

/// Detalji narudzbe sa listom karata i evidencijom placanja - master-details prikaz.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  SkiPassOrder? _order;
  bool _isLoading = true;
  bool _isCancelling = false;
  bool _isPaying = false;
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
      final order = await context.read<PurchaseService>().getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
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

  /// Otkazivanje je nepovratna akcija, pa trazi potvrdu i obavezan razlog.
  Future<void> _cancelOrder() async {
    final t = AppLocalizations.of(context)!;
    final reason = await AppFeedback.promptReason(
      context,
      title: t.orderCancelTitle,
      label: t.cancellationReasonLabel,
      confirmLabel: t.orderCancelButton,
    );

    if (reason == null || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      final updated = await context
          .read<PurchaseService>()
          .cancelOrder(widget.orderId, reason);

      if (!mounted) return;
      setState(() => _order = updated);
      AppFeedback.success(context, t.orderCancelSuccessMessage(updated.orderNumber));
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  /// Ponovni pokusaj placanja narudzbe koja jos ceka uplatu - isti tok kao pri
  /// prvoj kupovini (Stripe PaymentSheet unutar aplikacije za online nacine placanja).
  Future<void> _payNow() async {
    final t = AppLocalizations.of(context)!;
    final order = _order;
    if (order == null) return;

    setState(() => _isPaying = true);

    try {
      final payment = await context.read<PurchaseService>().initiatePayment(
            orderId: order.id,
            paymentMethodId: order.paymentMethodId,
          );

      if (!mounted) return;

      final result = await StripeCheckout.present(payment);
      if (!mounted) return;

      switch (result.outcome) {
        case StripeCheckoutOutcome.success:
          await _load();
          if (mounted) AppFeedback.success(context, t.paymentReceivedMessage);
        case StripeCheckoutOutcome.cancelled:
          break;
        case StripeCheckoutOutcome.failed:
          AppFeedback.error(context, result.message ?? t.paymentFailedGenericMessage);
      }
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_order?.orderNumber ?? t.orderDetailsDefaultTitle)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 3, height: 130);

    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _load);
    }

    final order = _order!;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.orderNumber, style: theme.textTheme.titleMedium),
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
                Divider(color: theme.colorScheme.outline),
                const SizedBox(height: AppSpacing.sm),
                LabeledValue(
                  label: t.orderTicketCountLabel,
                  value: Formatters.tickets(order.ticketCount),
                  icon: Icons.confirmation_number_outlined,
                ),
                LabeledValue(
                  label: t.orderPaymentMethodLabel,
                  value: order.paymentMethodName,
                  icon: Icons.payments_outlined,
                ),
                LabeledValue(
                  label: t.orderTotalAmountLabel,
                  value: Formatters.money(order.totalAmount),
                  icon: Icons.receipt_long_rounded,
                  valueColor: theme.colorScheme.primary,
                ),
                if (order.paidAmount > 0)
                  LabeledValue(
                    label: t.orderPaidLabel,
                    value: Formatters.money(order.paidAmount),
                    icon: Icons.check_circle_outline_rounded,
                    valueColor: AppColors.success,
                  ),
                if (order.refundedAmount > 0)
                  LabeledValue(
                    label: t.orderRefundedLabel,
                    value: Formatters.money(order.refundedAmount),
                    icon: Icons.undo_rounded,
                    valueColor: AppColors.warning,
                  ),
                if (order.confirmedAt != null)
                  LabeledValue(
                    label: t.statusOrderConfirmed,
                    value: Formatters.dateTime(order.confirmedAt!),
                    icon: Icons.event_available_rounded,
                  ),
              ],
            ),
          ),

          if (order.cancellationReason != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.dangerSurface,
              borderColor: AppColors.danger.withValues(alpha: 0.3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.cancellationReasonLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          order.cancellationReason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (order.awaitsPayment) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.warningSurface,
              borderColor: AppColors.warning.withValues(alpha: 0.3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t.orderAwaitingPaymentNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BusyButton(
              label: t.orderPayNowButton,
              icon: Icons.payment_rounded,
              isBusy: _isPaying,
              onPressed: _payNow,
            ),
          ],

          if (order.payments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(title: t.paymentsHistoryTitle),
            ...order.payments.map(
              (payment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.paymentMethodName,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              payment.paidAt == null
                                  ? t.paymentNotCompleted
                                  : Formatters.dateTime(payment.paidAt!),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.money(payment.amount),
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          StatusChip(
                            compact: true,
                            style: _paymentStatusStyle(context, payment.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: t.ticketsInOrderTitle),
          ...order.tickets.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TicketCard(ticket: ticket, showOrderLink: false),
            ),
          ),

          if (order.canBeCancelled) ...[
            const SizedBox(height: AppSpacing.lg),
            BusyButton(
              label: t.orderCancelButton,
              icon: Icons.cancel_outlined,
              isBusy: _isCancelling,
              backgroundColor: AppColors.danger,
              onPressed: _cancelOrder,
            ),
          ],
        ],
      ),
    );
  }

  StatusStyle _paymentStatusStyle(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;
    return switch (status) {
      'Completed' => StatusStyle(
          label: t.orderPaidLabel,
          color: AppColors.success,
          background: AppColors.successSurface,
          icon: Icons.check_circle_rounded,
        ),
      'Pending' => StatusStyle(
          label: t.statusIncidentInProgress,
          color: AppColors.warning,
          background: AppColors.warningSurface,
          icon: Icons.schedule_rounded,
        ),
      'Refunded' => StatusStyle(
          label: t.orderRefundedLabel,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.undo_rounded,
        ),
      'PartiallyRefunded' => StatusStyle(
          label: t.paymentStatusPartiallyRefunded,
          color: AppColors.info,
          background: AppColors.infoSurface,
          icon: Icons.undo_rounded,
        ),
      _ => StatusStyle(
          label: t.paymentStatusFailed,
          color: AppColors.danger,
          background: AppColors.dangerSurface,
          icon: Icons.error_outline_rounded,
        ),
    };
  }
}
