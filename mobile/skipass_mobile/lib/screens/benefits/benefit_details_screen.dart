import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../models/benefit.dart';
import '../../services/catalog_service.dart';
import '../../services/engagement_service.dart';
import '../../services/purchase_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/state_views.dart';
import '../reviews/review_section.dart';

/// Detalji pogodnosti sa kupovinom i ocjenama.
///
/// Vrijeme zadrzavanja na ovom ekranu salje se serveru kao signal za sistem
/// preporuke; podaci se stvarno upisuju, a ne simuliraju.
class BenefitDetailsScreen extends StatefulWidget {
  const BenefitDetailsScreen({super.key, required this.benefitId});

  final int benefitId;

  @override
  State<BenefitDetailsScreen> createState() => _BenefitDetailsScreenState();
}

class _BenefitDetailsScreenState extends State<BenefitDetailsScreen> {
  final DateTime _openedAt = DateTime.now();

  /// Servis se preuzima dok je widget jos u stablu, jer se pregled evidentira
  /// u dispose(), gdje pristup preko context-a vise nije siguran.
  late final CatalogService _catalogService;

  Benefit? _benefit;
  List<Review> _reviews = const [];

  bool _isLoading = true;
  bool _isBuying = false;
  String? _errorMessage;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _catalogService = context.read<CatalogService>();
    _load();
  }

  @override
  void dispose() {
    _trackView();
    super.dispose();
  }

  /// Pregled se evidentira pri napustanju ekrana, kada je poznato trajanje.
  void _trackView() {
    final seconds = DateTime.now().difference(_openedAt).inSeconds;
    // Poziv se namjerno ne ceka jer ekran vise nije prikazan.
    _catalogService
        .trackBenefitView(widget.benefitId, seconds.clamp(0, 7200))
        .catchError((_) {});
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        context.read<CatalogService>().getBenefit(widget.benefitId),
        context.read<EngagementService>().searchReviews(
              benefitId: widget.benefitId,
              pageSize: 5,
            ),
      ]);

      if (!mounted) return;

      setState(() {
        _benefit = results[0] as Benefit;
        _reviews = (results[1] as dynamic).items.cast<Review>();
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

  Future<void> _buy() async {
    final t = AppLocalizations.of(context)!;
    final benefit = _benefit!;
    final total = benefit.effectivePrice * _quantity;

    final confirmed = await AppFeedback.confirm(
      context,
      title: t.benefitPurchaseConfirmTitle,
      message: t.benefitPurchaseConfirmMessage(
        _quantity,
        benefit.name,
        Formatters.money(total),
      ),
      confirmLabel: t.commonBuy,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isBuying = true);

    try {
      await context.read<PurchaseService>().buyBenefit(benefit.id, _quantity);

      if (!mounted) return;
      AppFeedback.success(
        context,
        t.benefitPurchaseSuccessMessage(benefit.name),
      );
      setState(() => _quantity = 1);
      _load();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_benefit?.name ?? t.benefitDetailsDefaultTitle)),
      body: _buildBody(),
      bottomNavigationBar: _benefit == null || !_benefit!.isActive ? null : _buildBuyBar(),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 3, height: 130);

    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _load);
    }

    final benefit = _benefit!;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(benefit.name, style: theme.textTheme.titleLarge),
                    ),
                    if (benefit.hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          t.discountBadge(benefit.discountPercentage.toStringAsFixed(0)),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    RatingStars(rating: benefit.averageRating, size: 15),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      benefit.ratingCount == 0
                          ? t.benefitNotYetRated
                          : t.benefitRatingsSummary(
                              benefit.averageRating.toStringAsFixed(1),
                              benefit.ratingCount,
                            ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: theme.colorScheme.outline),
                const SizedBox(height: AppSpacing.sm),
                LabeledValue(
                  label: t.benefitCategoryLabel,
                  value: benefit.categoryName,
                  icon: Icons.category_outlined,
                ),
                if (benefit.partnerName != null)
                  LabeledValue(
                    label: t.benefitPartnerLabel,
                    value: benefit.partnerName!,
                    icon: Icons.handshake_outlined,
                  ),
                if (benefit.brand != null)
                  LabeledValue(
                    label: t.benefitBrandLabel,
                    value: benefit.brand!,
                    icon: Icons.sell_outlined,
                  ),
                LabeledValue(
                  label: t.benefitRegularPriceLabel,
                  value: Formatters.money(benefit.price),
                  icon: Icons.local_offer_outlined,
                ),
                LabeledValue(
                  label: t.benefitDiscountedPriceLabel,
                  value: Formatters.money(benefit.effectivePrice),
                  icon: Icons.payments_outlined,
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          SectionHeader(title: t.benefitDescriptionSectionTitle),
          AppCard(child: Text(benefit.description, style: theme.textTheme.bodyMedium)),

          if (!benefit.isActive) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.warningSurface,
              borderColor: AppColors.warning.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t.benefitInactiveNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          ReviewSection(
            title: t.benefitUserReviewsTitle,
            reviews: _reviews,
            targetType: 'Benefit',
            benefitId: benefit.id,
            averageRating: benefit.averageRating,
            reviewCount: benefit.ratingCount,
            onChanged: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildBuyBar() {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final benefit = _benefit!;
    final total = benefit.effectivePrice * _quantity;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStepperField(
            label: t.benefitQuantityLabel,
            value: _quantity,
            min: 1,
            max: 50,
            onChanged: (value) => setState(() => _quantity = value),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.commonTotal, style: theme.textTheme.bodySmall),
                  Text(
                    Formatters.money(total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: BusyButton(
                  label: t.commonBuy,
                  icon: Icons.shopping_bag_outlined,
                  isBusy: _isBuying,
                  onPressed: _buy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
