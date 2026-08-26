import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/notification_provider.dart';
import '../benefits/benefits_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../purchase/purchase_screen.dart';
import '../tickets/my_tickets_screen.dart';
import '../trails/trails_screen.dart';

/// Glavni okvir aplikacije sa donjom navigacijom.
///
/// Ekrani se cuvaju kroz IndexedStack kako se stanje liste i pretrage
/// ne bi gubilo pri prebacivanju izmedju tabova.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Brojac neprocitanih notifikacija se osvjezava automatski, bez rucnog povlacenja.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().startPolling();
    });
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _goToTab),
      const TrailsScreen(),
      const PurchaseScreen(),
      const MyTicketsScreen(),
      const BenefitsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onSelected: _goToTab,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onSelected,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              backgroundColor: AppColors.danger,
              label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
              child: const Icon(Icons.home_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              backgroundColor: AppColors.danger,
              label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
              child: const Icon(Icons.home_rounded),
            ),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.downhill_skiing_outlined),
            selectedIcon: const Icon(Icons.downhill_skiing_rounded),
            label: t.navTrails,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            selectedIcon: const Icon(Icons.add_shopping_cart_rounded),
            label: t.navPurchase,
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_number_outlined),
            selectedIcon: const Icon(Icons.confirmation_number_rounded),
            label: t.navTickets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_offer_outlined),
            selectedIcon: const Icon(Icons.local_offer_rounded),
            label: t.navBenefits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }
}
