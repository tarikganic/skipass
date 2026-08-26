import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';

/// Prikaz nakon uspjesno poslane narudzbe.
///
/// Narudzba u ovoj fazi ostaje u statusu "Ceka placanje" - placanje kroz
/// PayPal sandbox implementira se u narednoj fazi projekta.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final SkiPassOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.orderConfirmationAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xxl,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 46,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  t.orderReceivedTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.orderNumberLabel(order.orderNumber),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.orderStatusLabel, style: theme.textTheme.titleSmall),
                    ),
                    StatusChip(style: StatusStyles.order(context, order.status)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(color: theme.colorScheme.outline),
                const SizedBox(height: AppSpacing.sm),
                LabeledValue(
                  label: t.orderDateLabel,
                  value: Formatters.dateTime(order.orderDate),
                  icon: Icons.event_rounded,
                ),
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          SectionHeader(title: t.purchasedTicketsTitle),
          ...order.tickets.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.holderFullName, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            '${ticket.ticketTypeName} · '
                            '${Formatters.dateRange(ticket.validFrom, ticket.validTo)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.money(ticket.price),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.ticketsAwaitingPaymentTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        t.ticketsAwaitingPaymentBody,
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
          const SizedBox(height: AppSpacing.xxl),

          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.backToPurchaseButton),
          ),
        ],
      ),
    );
  }
}
