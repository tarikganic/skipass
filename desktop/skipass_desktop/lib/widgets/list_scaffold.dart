import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/dimens.dart';
import '../l10n/app_localizations.dart';
import '../providers/paged_list_controller.dart';
import 'state_views.dart';

/// Zaglavlje jedne administrativne stranice: naslov, opcione akcije (npr. dugme
/// "Dodaj"), pretraga i filteri. Ista struktura se ponavlja na svakoj listi,
/// pa je izdvojena u jednu komponentu umjesto da se ponavlja po ekranima.
class ListScaffold<T> extends StatefulWidget {
  const ListScaffold({
    super.key,
    required this.title,
    required this.controller,
    required this.itemBuilder,
    this.actions = const [],
    this.searchHint,
    this.onSearchChanged,
    this.filters,
    this.gridDelegate,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle,
    this.emptyMessage,
    this.skeletonHeight = 96,
  });

  final String title;
  final PagedListController<T> controller;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final List<Widget> actions;

  /// Kada nije zadano, koristi se generalna poruka "Pretrazi...".
  final String? searchHint;

  /// Poziva se (sa debounce-om) kada korisnik promijeni tekst pretrage.
  final void Function(String value)? onSearchChanged;

  /// Dodatni filteri prikazani desno od polja za pretragu.
  final Widget? filters;

  /// Kada je zadan, lista se prikazuje kao grid umjesto kao kolona kartica.
  final SliverGridDelegate? gridDelegate;

  final IconData emptyIcon;

  /// Kada nije zadano, koristi se generalna poruka "Nema podataka".
  final String? emptyTitle;
  final String? emptyMessage;
  final double skeletonHeight;

  @override
  State<ListScaffold<T>> createState() => _ListScaffoldState<T>();
}

class _ListScaffoldState<T> extends State<ListScaffold<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 320) {
      widget.controller.loadNextPage();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => widget.onSearchChanged?.call(value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.lg),
          child: Row(
            children: [
              Text(widget.title, style: theme.textTheme.headlineSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: l10n.commonRefresh,
                onPressed: widget.controller.refresh,
              ),
              ...widget.actions,
            ],
          ),
        ),
        if (widget.onSearchChanged != null || widget.filters != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.lg),
            child: Row(
              children: [
                if (widget.onSearchChanged != null)
                  SizedBox(
                    width: 340,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? l10n.commonSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  setState(() {});
                                },
                              ),
                      ),
                      onSubmitted: (_) {},
                    ),
                  ),
                if (widget.filters != null) ...[
                  const SizedBox(width: AppSpacing.lg),
                  widget.filters!,
                ],
              ],
            ),
          ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoadingFirstPage) {
          return LoadingSkeleton(
            count: 5,
            height: widget.skeletonHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          );
        }

        if (controller.hasError) {
          return ErrorStateView(message: controller.errorMessage!, onRetry: controller.loadFirstPage);
        }

        if (controller.isEmpty) {
          return EmptyStateView(
            icon: widget.emptyIcon,
            title: widget.emptyTitle ?? AppLocalizations.of(context)!.commonNoData,
            message: widget.emptyMessage,
          );
        }

        final items = controller.items;

        if (widget.gridDelegate != null) {
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxxl),
            gridDelegate: widget.gridDelegate!,
            itemCount: items.length,
            itemBuilder: (context, index) => widget.itemBuilder(context, items[index]),
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxxl),
          itemCount: items.length + (controller.isLoadingNextPage ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            if (index >= items.length) return const NextPageLoader();
            return widget.itemBuilder(context, items[index]);
          },
        );
      },
    );
  }
}
