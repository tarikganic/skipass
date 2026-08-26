import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/status_chip.dart';

/// Detalji narudzbe: karte, evidencija placanja i promjena statusa.
///
/// Prelazi statusa postuju server-side state machine (OrderStatusRules) - dugmad
/// za akcije se prikazuju samo za statuse koje `allowedNextStatuses` dozvoljava.
class OrderDetailDialog extends StatefulWidget {
  const OrderDetailDialog({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  SkiPassOrder? _order;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await context.read<OrderService>().getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(String status) async {
    final l10n = AppLocalizations.of(context)!;
    String? reason;

    if (status == 'Cancelled') {
      reason = await AppFeedback.promptReason(
        context,
        title: l10n.orderDetailCancelTitle,
        label: l10n.orderDetailCancelReasonLabel,
        confirmLabel: l10n.orderDetailCancelConfirmButton,
      );
      if (reason == null) return;
    } else {
      final confirmed = await AppFeedback.confirm(
        context,
        title: l10n.orderDetailStatusChangeTitle,
        message: l10n.orderDetailStatusChangeMessage(status),
      );
      if (!confirmed) return;
    }

    setState(() => _isBusy = true);
    try {
      final updated = await context.read<OrderService>().updateOrderStatus(
            widget.orderId,
            status,
            cancellationReason: reason,
          );
      if (!mounted) return;
      setState(() => _order = updated);
      AppFeedback.success(context, l10n.orderDetailStatusUpdateSuccess);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _refund(int paymentId, double refundable) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await AppFeedback.promptReason(
      context,
      title: l10n.orderDetailRefundTitle,
      label: l10n.orderDetailRefundReasonLabel,
      confirmLabel: l10n.orderDetailRefundConfirmButton,
    );
    if (reason == null) return;

    setState(() => _isBusy = true);
    try {
      await context.read<OrderService>().refundPayment(paymentId, reason);
      await _load();
      if (mounted) AppFeedback.success(context, l10n.orderDetailRefundSuccess);
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: order?.orderNumber ?? l10n.orderDetailDefaultTitle,
      width: AppSizes.wideDialogWidth,
      actions: order == null
          ? null
          : [
              for (final status in order.allowedNextStatuses)
                BusyButton(
                  label: _statusActionLabel(l10n, status),
                  isBusy: _isBusy,
                  isOutlined: status != 'Cancelled',
                  backgroundColor: status == 'Cancelled' ? AppColors.danger : null,
                  onPressed: () => _changeStatus(status),
                ),
            ],
      child: _isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : _error != null
              ? SizedBox(
                  height: 160,
                  child: Center(child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium)),
                )
              : _buildContent(order!),
    );
  }

  Widget _buildContent(SkiPassOrder order) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(order.userFullName, style: theme.textTheme.titleMedium),
            ),
            StatusChip(style: StatusStyles.order(order.status)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              LabeledValue(label: l10n.orderDetailDateLabel, value: Formatters.dateTime(order.orderDate)),
              LabeledValue(label: l10n.orderDetailPaymentMethodLabel, value: order.paymentMethodName),
              LabeledValue(label: l10n.orderDetailTicketCountLabel, value: '${order.ticketCount}'),
              LabeledValue(label: l10n.orderDetailTotalLabel, value: Formatters.money(order.totalAmount)),
              LabeledValue(
                label: l10n.orderDetailPaidLabel,
                value: Formatters.money(order.paidAmount),
                valueColor: order.isPaid ? AppColors.success : null,
              ),
              if (order.refundedAmount > 0)
                LabeledValue(label: l10n.orderDetailRefundedLabel, value: Formatters.money(order.refundedAmount), valueColor: AppColors.warning),
              if (order.cancellationReason != null)
                LabeledValue(label: l10n.orderDetailCancelReasonLabel, value: order.cancellationReason!),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.navTickets, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ...order.tickets.map(
          (ticket) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.holderFullName, style: theme.textTheme.bodyMedium),
                        Text(
                          '${ticket.ticketTypeName} · ${Formatters.dateRange(ticket.validFrom, ticket.validTo)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(Formatters.money(ticket.price), style: theme.textTheme.bodyMedium),
                  const SizedBox(width: AppSpacing.md),
                  StatusChip(style: StatusStyles.ticket(ticket.status), compact: true),
                ],
              ),
            ),
          ),
        ),
        if (order.payments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.orderDetailPaymentsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...order.payments.map((payment) {
            final refundable = payment.amount - payment.refundedAmount;
            final canRefund = payment.status == 'Completed' && refundable > 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${payment.paymentMethodName} · ${Formatters.money(payment.amount)}', style: theme.textTheme.bodyMedium),
                          Text(
                            payment.paidAt == null ? l10n.orderDetailPaymentNotCompleted : Formatters.dateTime(payment.paidAt!),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(payment.status, style: theme.textTheme.bodySmall),
                    if (canRefund) ...[
                      const SizedBox(width: AppSpacing.md),
                      OutlinedButton(
                        onPressed: _isBusy ? null : () => _refund(payment.id, refundable),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size(0, 36)),
                        child: Text(l10n.orderDetailRefundButton),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _statusActionLabel(AppLocalizations l10n, String status) => switch (status) {
        'Confirmed' => l10n.commonConfirm,
        'Completed' => l10n.commonComplete,
        'Cancelled' => l10n.commonCancel,
        _ => status,
      };
}
