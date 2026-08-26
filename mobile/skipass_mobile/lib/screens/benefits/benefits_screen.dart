import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/benefit.dart';
import '../../models/paged_result.dart';
import '../../providers/paged_list_controller.dart';
import '../../services/catalog_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_views.dart';
import '../reviews/review_section.dart';
import 'benefit_details_screen.dart';
import 'my_benefits_screen.dart';

/// Ponuda dodatnih pogodnosti i partnerskih usluga.
class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late final PagedListController<Benefit> _controller;
  Timer? _debounce;

  String? _query;
  int? _categoryId;
  List<Lookup> _categories = const [];

  @override
  void initState() {
    super.initState();

    _controller = PagedListController<Benefit>(
      fetchPage: (page, pageSize) => context.read<CatalogService>().searchBenefits(
            page: page,
            pageSize: pageSize,
            query: _query,
            categoryId: _categoryId,
          ),
    );

    _scrollController.addListener(_onScroll);
    _controller.loadFirstPage();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final items = await context.read<CatalogService>().lookup('BenefitCategories');
    if (mounted) setState(() => _categories = items);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 320) {
      _controller.loadNextPage();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim().isEmpty ? null : value.trim();
      _controller.loadFirstPage();
    });
  }

  void _setCategory(int? categoryId) {
    setState(() => _categoryId = categoryId);
    _controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.navBenefits),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: t.myBenefitsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyBenefitsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: t.benefitsSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: t.clearSearchTooltip,
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
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
                    selected: _categoryId == null,
                    showCheckmark: false,
                    onSelected: (_) => _setCategory(null),
                  ),
                ),
                ..._categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      showCheckmark: false,
                      onSelected: (_) => _setCategory(
                        _categoryId == category.id ? null : category.id,
                      ),
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
                    icon: Icons.local_offer_outlined,
                    title: t.benefitsEmptyTitle,
                    message: t.benefitsEmptyMessage,
                    actionLabel: t.resetFiltersAction,
                    onAction: () {
                      _searchController.clear();
                      _query = null;
                      _setCategory(null);
                    },
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
                      return BenefitCard(benefit: _controller.items[index]);
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

class BenefitCard extends StatelessWidget {
  const BenefitCard({super.key, required this.benefit});

  final Benefit benefit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BenefitDetailsScreen(benefitId: benefit.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _categoryIcon(benefit.categoryName),
                  size: AppSizes.iconMd,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benefit.partnerName == null
                          ? benefit.categoryName
                          : '${benefit.categoryName} · ${benefit.partnerName}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (benefit.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '-${benefit.discountPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Ocjena ustupa prostor cijeni; kada je prostor uzak, prikaz se smanjuje
              // umjesto da se prelije preko ivice kartice.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: benefit.ratingCount > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RatingStars(rating: benefit.averageRating, size: 13),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${benefit.averageRating.toStringAsFixed(1)} (${benefit.ratingCount})',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          )
                        : Text(
                            t.benefitNotYetRated,
                            style: theme.textTheme.labelSmall,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (benefit.hasDiscount) ...[
                Text(
                  Formatters.money(benefit.price),
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                Formatters.money(benefit.effectivePrice),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('oprem')) return Icons.downhill_skiing_rounded;
    if (value.contains('ugostitelj')) return Icons.restaurant_rounded;
    if (value.contains('skol')) return Icons.school_rounded;
    if (value.contains('smjest')) return Icons.hotel_rounded;
    if (value.contains('servis')) return Icons.build_rounded;
    return Icons.local_offer_rounded;
  }
}
