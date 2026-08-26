import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/benefit.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/purchase_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

/// Pogodnosti koje je korisnik kupio.
class MyBenefitsScreen extends StatefulWidget {
  const MyBenefitsScreen({super.key});

  @override
  State<MyBenefitsScreen> createState() => _MyBenefitsScreenState();
}

class _MyBenefitsScreenState extends State<MyBenefitsScreen> {
  late final PagedListController<BenefitPurchase> _controller;

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<BenefitPurchase>(
      fetchPage: (page, pageSize) => context
          .read<PurchaseService>()
          .searchBenefitPurchases(page: page, pageSize: pageSize),
    );

    _controller.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cancel(BenefitPurchase purchase) async {
    final t = AppLocalizations.of(context)!;
    final reason = await AppFeedback.promptReason(
      context,
      title: t.benefitCancelPurchaseTitle,
      label: t.cancellationReasonLabel,
      confirmLabel: t.commonCancel,
    );

    if (reason == null || !mounted) return;

    try {
      final updated = await context
          .read<PurchaseService>()
          .cancelBenefitPurchase(purchase.id, reason);

      if (!mounted) return;
      _controller.replaceWhere((item) => item.id == purchase.id, updated);
      AppFeedback.success(context, t.benefitCancelSuccessMessage(purchase.benefitName));
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.myBenefitsTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoadingFirstPage) {
            return const LoadingSkeleton(count: 4, height: 110);
          }

          if (_controller.hasError) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.loadFirstPage,
            );
          }

          if (_controller.isEmpty) {
            return EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: t.myBenefitsEmptyTitle,
              message: t.myBenefitsEmptyMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              itemCount: _controller.items.length + (_controller.isLoadingNextPage ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index >= _controller.items.length) return const NextPageLoader();

                final purchase = _controller.items[index];
                return _PurchaseCard(
                  purchase: purchase,
                  onCancel: purchase.canBeCancelled ? () => _cancel(purchase) : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase, this.onCancel});

  final BenefitPurchase purchase;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

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
                    Text(
                      purchase.benefitName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(purchase.categoryName, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              StatusChip(style: StatusStyles.order(context, purchase.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                Formatters.dateTime(purchase.purchasedAt),
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${purchase.quantity} × · ${Formatters.money(purchase.totalPrice)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (purchase.cancellationReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              t.benefitCancellationReasonLine(purchase.cancellationReason!),
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: AppSizes.iconSm),
              label: Text(t.benefitCancelPurchaseButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
