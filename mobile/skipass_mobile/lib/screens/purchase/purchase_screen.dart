import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../models/paged_result.dart';
import '../../models/ticket.dart';
import '../../providers/auth_provider.dart';
import '../../services/catalog_service.dart';
import '../../services/purchase_service.dart';
import '../../services/stripe_checkout.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/state_views.dart';
import 'order_confirmation_screen.dart';

/// Kupovina ski pass karata: odabir tipa, datuma, broja dana i broja karata.
///
/// Karte se dodaju u korpu, pa se jednom narudzbom moze kupiti vise karata
/// za porodicu ili grupu.
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<OrderDraftItem> _cart = [];

  List<TicketType> _ticketTypes = const [];
  List<Lookup> _paymentMethods = const [];

  TicketType? _selectedType;
  Lookup? _selectedPaymentMethod;
  DateTime? _validFrom;
  int _numberOfDays = 1;
  int _numberOfTickets = 1;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final catalog = context.read<CatalogService>();
      final results = await Future.wait([
        catalog.searchTicketTypes(),
        catalog.lookup('PaymentMethods'),
      ]);

      if (!mounted) return;

      final types = (results[0] as dynamic).items.cast<TicketType>() as List<TicketType>;
      final methods = results[1] as List<Lookup>;

      setState(() {
        _ticketTypes = types;
        _paymentMethods = methods;
        _selectedType = types.isEmpty ? null : types.first;
        _selectedPaymentMethod = methods.isEmpty ? null : methods.first;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.price);

  void _addToCart() {
    final t = AppLocalizations.of(context)!;
    setState(() => _dateError = null);

    if (_selectedType == null) {
      AppFeedback.error(context, t.selectTicketTypeError);
      return;
    }

    if (_validFrom == null) {
      setState(() => _dateError = t.selectStartDateError);
      return;
    }

    if (_cart.length + _numberOfTickets > 20) {
      AppFeedback.error(
        context,
        t.maxTicketsPerOrderError,
      );
      return;
    }

    final user = context.read<AuthProvider>().user;

    setState(() {
      for (var i = 0; i < _numberOfTickets; i++) {
        _cart.add(OrderDraftItem(
          ticketType: _selectedType!,
          // Prva karta se podrazumijevano vodi na prijavljenog korisnika,
          // a ostale se imenuju prije slanja narudzbe.
          holderFirstName: _cart.isEmpty && i == 0 ? (user?.firstName ?? '') : '',
          holderLastName: _cart.isEmpty && i == 0 ? (user?.lastName ?? '') : '',
          validFrom: _validFrom!,
          numberOfDays: _numberOfDays,
        ));
      }
      _numberOfTickets = 1;
    });

    AppFeedback.success(
      context,
      AppLocalizations.of(context)!.ticketsAddedToCartMessage,
    );
  }

  Future<void> _submitOrder() async {
    final t = AppLocalizations.of(context)!;
    if (_cart.isEmpty) {
      AppFeedback.error(context, t.emptyCartError);
      return;
    }

    if (_selectedPaymentMethod == null) {
      AppFeedback.error(context, t.selectPaymentMethodError);
      return;
    }

    // Ime nosioca je obavezno za svaku kartu jer se stampa na karti.
    final missingHolder = _cart.indexWhere(
      (item) => item.holderFirstName.trim().length < 2 || item.holderLastName.trim().length < 2,
    );

    if (missingHolder >= 0) {
      AppFeedback.error(
        context,
        t.missingHolderNameError(missingHolder + 1),
      );
      return;
    }

    final confirmed = await AppFeedback.confirm(
      context,
      title: t.orderConfirmTitle,
      message: t.orderConfirmMessage(
        Formatters.tickets(_cart.length),
        Formatters.money(_cartTotal),
      ),
      confirmLabel: t.orderPlaceButton,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final purchaseService = context.read<PurchaseService>();

      final order = await purchaseService.createOrder(
            paymentMethodId: _selectedPaymentMethod!.id,
            items: _cart,
          );

      final payment = await purchaseService.initiatePayment(
        orderId: order.id,
        paymentMethodId: _selectedPaymentMethod!.id,
      );

      if (!mounted) return;

      if (payment.requiresStripePayment) {
        final result = await StripeCheckout.present(payment);

        if (!mounted) return;

        if (result.outcome == StripeCheckoutOutcome.cancelled) {
          // Narudzba ostaje "Ceka placanje" - korisnik moze pokusati ponovo iz Narudzbi.
          AppFeedback.info(context, t.paymentCancelledMessage);
          return;
        }

        if (result.outcome == StripeCheckoutOutcome.failed) {
          AppFeedback.error(context, result.message ?? t.paymentFailedRetryFromOrdersMessage);
          return;
        }
      }

      setState(() {
        _cart.clear();
        _validFrom = null;
        _numberOfDays = 1;
        _numberOfTickets = 1;
      });

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.purchaseAppBarTitle)),
      body: _buildBody(),
      bottomNavigationBar: _cart.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 4, height: 110);

    if (_loadError != null) {
      return ErrorStateView(message: _loadError!, onRetry: _loadReferenceData);
    }

    // Forma se ne otvara ako preduslovi nisu ispunjeni, uz jasno objasnjenje.
    if (_ticketTypes.isEmpty) {
      return EmptyStateView(
        icon: Icons.confirmation_number_outlined,
        title: t.purchaseUnavailableTitle,
        message: t.purchaseUnavailableMessage,
      );
    }

    final today = DateTime.now();
    final maxDays = _selectedType?.maxDays ?? 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xl,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        SectionHeader(title: t.newTicketSectionTitle),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdownField<TicketType>(
                label: t.ticketTypeLabel,
                items: _ticketTypes,
                value: _selectedType,
                isRequired: true,
                prefixIcon: Icons.confirmation_number_outlined,
                itemLabel: (type) =>
                    t.ticketTypePriceOption(type.name, Formatters.money(type.pricePerDay)),
                onChanged: (value) => setState(() {
                  _selectedType = value;
                  // Broj dana se ogranicava na maksimum koji tip karte dozvoljava.
                  if (value != null && _numberOfDays > value.maxDays) {
                    _numberOfDays = value.maxDays;
                  }
                }),
              ),
              if (_selectedType != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _TicketTypeHint(ticketType: _selectedType!),
              ],
              const SizedBox(height: AppSpacing.xl),

              AppDateField(
                label: t.startDateLabel,
                value: _validFrom,
                isRequired: true,
                firstDate: DateTime(today.year, today.month, today.day),
                lastDate: today.add(const Duration(days: 365)),
                errorText: _dateError,
                onChanged: (value) => setState(() {
                  _validFrom = value;
                  _dateError = null;
                }),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppStepperField(
                label: t.daysCountLabel,
                value: _numberOfDays,
                min: 1,
                max: maxDays,
                helperText: t.maxDaysAllowedHelper(Formatters.days(maxDays)),
                suffixBuilder: Formatters.days,
                onChanged: (value) => setState(() => _numberOfDays = value),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppStepperField(
                label: t.ticketsCountLabel,
                value: _numberOfTickets,
                min: 1,
                max: 20 - _cart.length,
                helperText: t.multipleTicketsHelper,
                suffixBuilder: Formatters.tickets,
                onChanged: (value) => setState(() => _numberOfTickets = value),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_selectedType != null && _validFrom != null)
                _PricePreview(
                  ticketType: _selectedType!,
                  numberOfDays: _numberOfDays,
                  numberOfTickets: _numberOfTickets,
                ),
              const SizedBox(height: AppSpacing.lg),

              FilledButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(t.addToCartButton),
              ),
            ],
          ),
        ),

        if (_cart.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: t.cartSectionTitle(Formatters.tickets(_cart.length))),
          ...List.generate(_cart.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _CartItemCard(
                index: index,
                item: _cart[index],
                onChanged: () => setState(() {}),
                onRemove: () => setState(() => _cart.removeAt(index)),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<Lookup>(
            label: t.paymentMethodLabel,
            items: _paymentMethods,
            value: _selectedPaymentMethod,
            isRequired: true,
            prefixIcon: Icons.payments_outlined,
            itemLabel: (method) => method.name,
            emptyHint: t.paymentMethodsUnavailableHint,
            onChanged: (value) => setState(() => _selectedPaymentMethod = value),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckoutBar() {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.commonTotal, style: theme.textTheme.bodySmall),
              Text(
                Formatters.money(_cartTotal),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: BusyButton(
              label: t.submitOrderButton,
              icon: Icons.check_rounded,
              isBusy: _isSubmitting,
              onPressed: _submitOrder,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketTypeHint extends StatelessWidget {
  const _TicketTypeHint({required this.ticketType});

  final TicketType ticketType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppSizes.iconSm,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ticketType.description != null)
                  Text(ticketType.description!, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    Text(ticketType.ageLabel, style: theme.textTheme.labelSmall),
                    if (ticketType.discountPercentage > 0)
                      Text(
                        t.discountBadge(ticketType.discountPercentage.toStringAsFixed(0)),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pregled cijene prije dodavanja u korpu. Konacnu cijenu uvijek racuna server.
class _PricePreview extends StatelessWidget {
  const _PricePreview({
    required this.ticketType,
    required this.numberOfDays,
    required this.numberOfTickets,
  });

  final TicketType ticketType;
  final int numberOfDays;
  final int numberOfTickets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final unitPrice = ticketType.priceFor(numberOfDays);
    final total = unitPrice * numberOfTickets;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: '${Formatters.money(ticketType.pricePerDay)} × ${Formatters.days(numberOfDays)}',
            value: Formatters.money(ticketType.pricePerDay * numberOfDays),
          ),
          if (ticketType.discountPercentage > 0)
            _PriceRow(
              label: t.discountBadge(ticketType.discountPercentage.toStringAsFixed(0)),
              value: '- ${Formatters.money(ticketType.pricePerDay * numberOfDays - unitPrice)}',
              valueColor: AppColors.success,
            ),
          _PriceRow(
            label: t.pricePerTicketLabel,
            value: Formatters.money(unitPrice),
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.totalForTicketsLabel(Formatters.tickets(numberOfTickets)),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Text(
                Formatters.money(total),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryDark),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartica jedne karte u korpi, sa unosom imena nosioca.
class _CartItemCard extends StatefulWidget {
  const _CartItemCard({
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final OrderDraftItem item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _firstName =
      TextEditingController(text: widget.item.holderFirstName);
  late final TextEditingController _lastName =
      TextEditingController(text: widget.item.holderLastName);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final item = widget.item;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  item.ticketType.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                Formatters.money(item.price),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: t.removeTicketTooltip,
                color: AppColors.danger,
                onPressed: widget.onRemove,
              ),
            ],
          ),
          Text(
            '${Formatters.dateRange(item.validFrom, item.validFrom.add(Duration(days: item.numberOfDays - 1)))}'
            ' · ${Formatters.days(item.numberOfDays)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: t.ticketHolderFirstNameLabel,
                  controller: _firstName,
                  isRequired: true,
                  validator: (value) => Validators.name(value, 'Ime'),
                  onChanged: (value) {
                    item.holderFirstName = value;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: t.fieldLastNameLabel,
                  controller: _lastName,
                  isRequired: true,
                  validator: (value) => Validators.name(value, 'Prezime'),
                  onChanged: (value) {
                    item.holderLastName = value;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
