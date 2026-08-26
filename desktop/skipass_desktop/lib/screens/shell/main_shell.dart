import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/side_nav.dart';
import '../announcements/announcements_screen.dart';
import '../benefits/benefits_screen.dart';
import '../incidents/incidents_screen.dart';
import '../incidents/report_incident_dialog.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_dialog.dart';
import '../reference_data/reference_data_screen.dart';
import '../reports/reports_screen.dart';
import '../resorts/resorts_screen.dart';
import '../tickets/tickets_screen.dart';
import '../users/users_screen.dart';

/// Glavni okvir desktop aplikacije: bocna navigacija + sadrzaj.
///
/// Stranice se cuvaju kroz IndexedStack kako pretraga i paginacija ne bi
/// resetovale stanje pri prebacivanju izmedju sekcija.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final unread = context.watch<NotificationProvider>().unreadCount;
    final l10n = AppLocalizations.of(context)!;

    final items = <SideNavItem>[
      SideNavItem(icon: Icons.confirmation_number_outlined, label: l10n.navTickets),
      SideNavItem(icon: Icons.downhill_skiing_outlined, label: l10n.navResorts),
      SideNavItem(icon: Icons.local_offer_outlined, label: l10n.navBenefits),
      SideNavItem(icon: Icons.report_gmailerrorred_outlined, label: l10n.navIncidents),
      SideNavItem(icon: Icons.campaign_outlined, label: l10n.navAnnouncements),
      SideNavItem(icon: Icons.notifications_none_rounded, label: l10n.navNotifications, badgeCount: unread),
      SideNavItem(icon: Icons.bar_chart_rounded, label: l10n.navReports),
      if (isAdmin) SideNavItem(icon: Icons.people_outline_rounded, label: l10n.navUsers),
      if (isAdmin) SideNavItem(icon: Icons.tune_rounded, label: l10n.navReferenceData),
    ];

    final pages = <Widget>[
      const TicketsScreen(),
      const ResortsScreen(),
      const BenefitsScreen(),
      const IncidentsScreen(),
      const AnnouncementsScreen(),
      const NotificationsScreen(),
      const ReportsScreen(),
      if (isAdmin) const UsersScreen(),
      if (isAdmin) const ReferenceDataScreen(),
    ];

    final safeIndex = _selectedIndex >= pages.length ? 0 : _selectedIndex;

    return Scaffold(
      body: Row(
        children: [
          SideNav(
            items: items,
            selectedIndex: safeIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
            onReportIncident: () => showDialog<void>(
              context: context,
              builder: (_) => const ReportIncidentDialog(),
            ),
            userName: auth.user?.fullName ?? '',
            userRole: auth.user?.role == 'Admin' ? l10n.roleAdmin : l10n.roleStaff,
            onProfileTap: () => showDialog<void>(context: context, builder: (_) => const ProfileDialog()),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: IndexedStack(index: safeIndex, children: pages)),
        ],
      ),
    );
  }
}
