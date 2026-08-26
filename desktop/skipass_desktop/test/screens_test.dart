import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skipass_desktop/core/api/api_client.dart';
import 'package:skipass_desktop/core/theme/app_theme.dart';
import 'package:skipass_desktop/l10n/app_localizations.dart';
import 'package:skipass_desktop/models/announcement.dart';
import 'package:skipass_desktop/models/benefit.dart';
import 'package:skipass_desktop/models/incident.dart';
import 'package:skipass_desktop/models/order.dart';
import 'package:skipass_desktop/models/paged_result.dart';
import 'package:skipass_desktop/models/partner.dart';
import 'package:skipass_desktop/models/reference_item.dart';
import 'package:skipass_desktop/models/report.dart';
import 'package:skipass_desktop/models/ski_lift.dart';
import 'package:skipass_desktop/models/ticket.dart';
import 'package:skipass_desktop/models/trail.dart';
import 'package:skipass_desktop/models/user.dart';
import 'package:skipass_desktop/providers/auth_provider.dart';
import 'package:skipass_desktop/providers/notification_provider.dart';
import 'package:skipass_desktop/screens/announcements/announcements_screen.dart';
import 'package:skipass_desktop/screens/benefits/benefits_screen.dart';
import 'package:skipass_desktop/screens/incidents/incidents_screen.dart';
import 'package:skipass_desktop/screens/incidents/report_incident_dialog.dart';
import 'package:skipass_desktop/screens/notifications/notifications_screen.dart';
import 'package:skipass_desktop/screens/reference_data/reference_data_screen.dart';
import 'package:skipass_desktop/screens/reports/reports_screen.dart';
import 'package:skipass_desktop/screens/resorts/resorts_screen.dart';
import 'package:skipass_desktop/screens/tickets/tickets_screen.dart';
import 'package:skipass_desktop/screens/tickets/validate_ticket_dialog.dart';
import 'package:skipass_desktop/screens/users/user_form_dialog.dart';
import 'package:skipass_desktop/screens/users/users_screen.dart';
import 'package:skipass_desktop/services/auth_service.dart';
import 'package:skipass_desktop/services/benefit_service.dart';
import 'package:skipass_desktop/services/engagement_service.dart';
import 'package:skipass_desktop/services/order_service.dart';
import 'package:skipass_desktop/services/reference_data_service.dart';
import 'package:skipass_desktop/services/report_service.dart';
import 'package:skipass_desktop/services/resort_service.dart';
import 'package:skipass_desktop/services/user_service.dart';
import 'package:skipass_desktop/widgets/app_card.dart';
import 'package:skipass_desktop/widgets/state_views.dart';

import 'support/fake_api.dart';

/// Testovi provjeravaju da se administrativni ekrani ispravno iscrtavaju i
/// reaguju na akcije nad stvarnim odgovorima API-ja, snimljenim sa pokrenutog
/// servera (backend/README - nalog `desktop`/Admin), ukljucujuci prelaze
/// stanja (state machine) koje server salje kroz `allowedNextStatuses`.
void main() {
  // Podrazumijevana testna povrsina je 800x600, sto ne odgovara desktopu.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1600, 1000);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  group('Parsiranje stvarnih odgovora API-ja', () {
    test('profil administratora se mapira sa inicijalima za avatar', () {
      final user = AppUser.fromJson(FakeApi.readJson('me'));

      expect(user.role, 'Admin');
      expect(user.email, contains('@'));
      expect(user.initials.length, inInclusiveRange(1, 2));
    });

    test('karte nose status narudzbe i naziv nacina placanja', () {
      final page = PagedResult.fromJson(FakeApi.readJson('tickets'), SkiPassTicket.fromJson);

      expect(page.items, isNotEmpty);
      for (final ticket in page.items) {
        expect(ticket.qrCode, isNotEmpty);
        expect(ticket.orderStatus, isNotEmpty);
        expect(ticket.paymentMethodName, isNotEmpty);
      }
    });

    test('tip karte racuna cijenu po istoj formuli kao server', () {
      final page = PagedResult.fromJson(FakeApi.readJson('ticket_types'), TicketType.fromJson);

      expect(page.items, isNotEmpty);
      for (final type in page.items) {
        final price = type.priceFor(2);
        final expected = double.parse((type.pricePerDay * 2 * (1 - type.discountPercentage / 100)).toStringAsFixed(2));
        expect(price, expected);
      }
    });

    test('staze nose id i naziv tezine sa serverom uskladjenim poljima', () {
      final page = PagedResult.fromJson(FakeApi.readJson('trails'), Trail.fromJson);

      expect(page.items, isNotEmpty);
      for (final trail in page.items) {
        expect(trail.difficultyId, greaterThan(0));
        expect(trail.difficultyName, isNotEmpty);
        expect(trail.lengthLabel, isNotEmpty);
      }
    });

    test('liftovi imaju popunjenost u granicama 0-1', () {
      final page = PagedResult.fromJson(FakeApi.readJson('lifts'), SkiLift.fromJson);

      expect(page.items, isNotEmpty);
      for (final lift in page.items) {
        expect(lift.occupancyRatio, inInclusiveRange(0, 1));
      }
    });

    test('pogodnosti nose skijaliste i partnera kao id, ne samo kao naziv', () {
      final page = PagedResult.fromJson(FakeApi.readJson('benefits'), Benefit.fromJson);

      expect(page.items, isNotEmpty);
      for (final benefit in page.items) {
        expect(benefit.skiResortId, greaterThan(0));
        expect(benefit.effectivePrice, lessThanOrEqualTo(benefit.price));
        if (!benefit.hasDiscount) {
          expect(benefit.effectivePrice, benefit.price);
        }
      }
    });

    test('partneri se mapiraju sa brojem povezanih usluga', () {
      final page = PagedResult.fromJson(FakeApi.readJson('partners'), Partner.fromJson);

      expect(page.items, isNotEmpty);
      expect(page.items.every((p) => p.benefitCount >= 0), isTrue);
    });

    test('obavijesti nose id kategorije i skijalista za izmjenu', () {
      final page = PagedResult.fromJson(FakeApi.readJson('announcements'), Announcement.fromJson);

      expect(page.items, isNotEmpty);
      for (final announcement in page.items) {
        expect(announcement.categoryId, greaterThan(0));
        expect(announcement.skiResortId, greaterThan(0));
      }
    });

    test('korisnici u administraciji imaju sve tri role', () {
      final page = PagedResult.fromJson(FakeApi.readJson('users'), AppUser.fromJson);

      expect(page.items, isNotEmpty);
      for (final user in page.items) {
        expect(['Skier', 'Staff', 'Admin'], contains(user.role));
      }
    });

    test('referentna tabela tezina staza nosi boju i broj povezanih staza', () {
      final page = PagedResult.fromJson(FakeApi.readJson('trail_difficulties'), ReferenceItem.fromJson);

      expect(page.items, isNotEmpty);
      for (final item in page.items) {
        expect(item.colorHex, startsWith('#'));
        expect(item.relatedCount, isNotNull);
      }
    });

    test('referentna tabela drzava nosi ISO oznaku', () {
      final page = PagedResult.fromJson(FakeApi.readJson('countries'), ReferenceItem.fromJson);

      expect(page.items, isNotEmpty);
      for (final item in page.items) {
        expect(item.isoCode, isNotNull);
        expect(item.isoCode!.length, inInclusiveRange(2, 3));
      }
    });

    test('izvjestaj prodaje: ukupan broj karata odgovara zbiru po danima', () {
      final report = SalesReport.fromJson(FakeApi.readJson('sales_report'));

      final sum = report.days.fold<int>(0, (total, day) => total + day.ticketCount);
      expect(sum, report.totalTicketCount);
      expect(report.days, isNotEmpty);
    });

    test('top korisnici su rangirani opadajuce po broju karata', () {
      final report = TopUsersReport.fromJson(FakeApi.readJson('top_users'));

      expect(report.users, isNotEmpty);
      for (var i = 1; i < report.users.length; i++) {
        expect(report.users[i - 1].ticketCount, greaterThanOrEqualTo(report.users[i].ticketCount));
      }
    });
  });

  group('State machine - prelazi stanja sa servera', () {
    test('narudzba u statusu Pending dozvoljava potvrdu ili otkazivanje, zavrsene ne dozvoljavaju nista', () {
      final page = PagedResult.fromJson(FakeApi.readJson('orders'), SkiPassOrder.fromJson);

      final pending = page.items.where((o) => o.status == 'Pending');
      for (final order in pending) {
        expect(order.allowedNextStatuses, containsAll(['Confirmed', 'Cancelled']));
      }

      final terminal = page.items.where((o) => o.status == 'Cancelled' || o.status == 'Completed');
      for (final order in terminal) {
        expect(order.allowedNextStatuses, isEmpty);
      }
    });

    test('prijavljeni incident dozvoljava preuzimanje ili odbijanje', () {
      final page = PagedResult.fromJson(FakeApi.readJson('incidents'), Incident.fromJson);

      final reported = page.items.where((i) => i.status == 'Reported');
      expect(reported, isNotEmpty);
      for (final incident in reported) {
        expect(incident.allowedNextStatuses, containsAll(['InProgress', 'Rejected']));
      }
    });

    test('kvar lifta u toku dozvoljava zavrsetak ili otkazivanje prijave', () {
      final page = PagedResult.fromJson(FakeApi.readJson('lift_maintenance'), LiftMaintenanceRecord.fromJson);

      final inProgress = page.items.where((m) => m.status == 'InProgress');
      expect(inProgress, isNotEmpty);
      for (final record in inProgress) {
        expect(record.allowedNextStatuses, containsAll(['Completed', 'Cancelled']));
      }

      final completed = page.items.where((m) => m.status == 'Completed');
      for (final record in completed) {
        expect(record.allowedNextStatuses, isEmpty);
      }
    });
  });

  group('Iscrtavanje ekrana nad stvarnim podacima', () {
    testWidgets('Karte prikazuju tabelu karata i mogu se prebaciti na tipove karata', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const TicketsScreen()));
      await tester.pumpAndSettle();

      // "Karte" se pojavljuje i kao naziv taba i kao naslov liste.
      expect(find.text('Karte'), findsWidgets);
      expect(find.text('Validiraj kartu'), findsOneWidget);

      await tester.tap(find.text('Tipovi karata'));
      await tester.pumpAndSettle();

      expect(find.text('Novi tip karte'), findsOneWidget);
      expect(find.byType(AppCard), findsWidgets);
    });

    testWidgets('Staze i ski liftovi prikazuju obje kartice sa CRUD akcijama', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const ResortsScreen()));
      await tester.pumpAndSettle();

      // "Staze" se pojavljuje i kao naziv taba i kao naslov liste.
      expect(find.text('Staze'), findsWidgets);
      expect(find.text('Dodaj stazu'), findsOneWidget);

      await tester.tap(find.text('Ski liftovi'));
      await tester.pumpAndSettle();

      expect(find.text('Dodaj lift'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('Usluge prikazuju pogodnosti i mogu se prebaciti na partnere', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const BenefitsScreen()));
      await tester.pumpAndSettle();

      // "Usluge" se pojavljuje i kao naziv taba i kao naslov liste.
      expect(find.text('Usluge'), findsWidgets);
      expect(find.text('Dodaj novu uslugu'), findsOneWidget);

      await tester.tap(find.text('Partneri'));
      await tester.pumpAndSettle();

      expect(find.text('Dodaj partnera'), findsOneWidget);
    });

    testWidgets('Incidenti prikazuju kanban tablu sa cetiri kolone i akcijama po statusu', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const IncidentsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Incidenti'), findsOneWidget);
      expect(find.text('Prijavljeno'), findsOneWidget);
      expect(find.text('U toku'), findsOneWidget);
      expect(find.text('Rijeseno'), findsOneWidget);
      expect(find.text('Odbijeno'), findsOneWidget);

      // Bar jedna prijavljena prijava mora nuditi obje akcije servera.
      expect(find.text('Preuzmi'), findsWidgets);
      expect(find.text('Odbij'), findsWidgets);
    });

    testWidgets('Obavijesti razdvajaju hitne od aktivnih obavijesti', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const AnnouncementsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Obavijesti'), findsOneWidget);
      expect(find.text('Hitne obavijesti'), findsOneWidget);
      expect(find.text('Aktivne obavijesti'), findsOneWidget);
    });

    testWidgets('Notifikacije prikazuju listu i akciju oznaci sve procitano', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notifikacije'), findsOneWidget);
      expect(find.text('Oznaci sve kao procitano'), findsOneWidget);
    });

    testWidgets('Korisnici prikazuju listu sa rolama i otvaraju formu za novog korisnika', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const UsersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Korisnici'), findsOneWidget);
      expect(find.text('Novi korisnik'), findsOneWidget);

      await tester.tap(find.text('Novi korisnik'));
      await tester.pumpAndSettle();

      expect(find.byType(UserFormDialog), findsOneWidget);
      // Oznake polja se iscrtavaju kroz RichText (zvjezdica za obavezno polje),
      // pa se ne mogu naci preko find.text - koristi se sadrzaj RichText-a.
      expect(findFieldLabel('Korisnicko ime'), findsOneWidget);
      // Lozinka je obavezna samo pri kreiranju, ne pri izmjeni.
      expect(findFieldLabel('Lozinka'), findsOneWidget);
    });

    testWidgets('Referentni podaci prikazuju osam sifarnika kao chip izbor', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const ReferenceDataScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Referentni podaci'), findsOneWidget);
      expect(find.text('Drzave'), findsWidgets);
      expect(find.text('Gradovi'), findsOneWidget);
      expect(find.text('Nacini placanja'), findsOneWidget);

      await tester.tap(find.text('Tezine staza'));
      await tester.pumpAndSettle();

      expect(find.text('Dodaj: Tezina staze'), findsOneWidget);
    });

    testWidgets('Izvjestaji prikazuju graf prodaje i tabelu top korisnika sa PDF akcijama', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Izvjestaji'), findsOneWidget);
      expect(find.text('Prodaja karata po danima'), findsOneWidget);
      expect(find.text('Top 5 korisnika'), findsOneWidget);
      expect(find.text('Preuzmi PDF'), findsNWidgets(2));
      expect(find.text('Ispis'), findsNWidgets(2));

      // Prvi korisnik u top listi mora biti prikazan sa ukupnom potrosnjom.
      final topUsers = TopUsersReport.fromJson(FakeApi.readJson('top_users'));
      expect(find.text(topUsers.users.first.fullName), findsOneWidget);
    });

    testWidgets('Prijava problema nudi tip incidenta, lokaciju i opis', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const ReportIncidentDialog()));
      await tester.pumpAndSettle();

      expect(find.text('Prijavi problem'), findsOneWidget);
      expect(find.text('Staza'), findsOneWidget);
      expect(find.text('Ski lift'), findsOneWidget);
      // Oznaka polja je obavezna (RichText sa " *"), ne obican Text.
      expect(findFieldLabel('Opis problema'), findsOneWidget);
    });

    testWidgets('Validacija karte nudi odabir lifta i unos QR koda', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const ValidateTicketDialog()));
      await tester.pumpAndSettle();

      expect(find.text('Validacija karte'), findsOneWidget);
      expect(findFieldLabel('Ski lift'), findsOneWidget);
    });
  });

  group('Stanja praznog prikaza i greske', () {
    testWidgets('prazna lista narudzbi/karata prikazuje prazno stanje', (tester) async {
      final fake = FakeApi(overrides: {
        '/api/Tickets': '{"items":[],"totalCount":0,"page":1,"pageSize":20,"totalPages":0,'
            '"hasPreviousPage":false,"hasNextPage":false}',
      });

      await tester.pumpWidget(_wrap(fake.build(), const TicketsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('greska servera se prikazuje kroz poruku koju je server poslao', (tester) async {
      final fake = FakeApi(overrides: {'/api/Trails': '__ERROR__'});

      await tester.pumpWidget(_wrap(fake.build(), const ResortsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Podatke nije moguce ucitati'), findsOneWidget);
      expect(find.text('Skijaliste trenutno nije dostupno.'), findsOneWidget);
      expect(find.text('Pokusaj ponovo'), findsOneWidget);
    });

    testWidgets('kanban tabla bez incidenata prikazuje "Nema prijava" u svakoj koloni', (tester) async {
      final fake = FakeApi(overrides: {
        '/api/Incidents': '{"items":[],"totalCount":0,"page":1,"pageSize":20,"totalPages":0,'
            '"hasPreviousPage":false,"hasNextPage":false}',
      });

      await tester.pumpWidget(_wrap(fake.build(), const IncidentsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Nema prijava'), findsNWidgets(4));
    });
  });
}

/// Nalazi oznaku polja (`_FieldLabel` u `form_fields.dart`) koja se iscrtava
/// preko `RichText` (radi zvjezdice za obavezno polje), pa je `find.text` ne
/// moze pronaci - poredi se sadrzaj cijelog RichText-a umjesto tacnog Text-a.
Finder findFieldLabel(String label) => find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().trim().startsWith(label),
    );

/// Postavlja servise i teme oko ekrana koji se testira, isto kao `lib/app.dart`.
Widget _wrap(ApiClient api, Widget child) {
  final authService = AuthService(api);

  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      Provider<AuthService>.value(value: authService),
      Provider<ReferenceDataService>(create: (_) => ReferenceDataService(api)),
      Provider<ResortService>(create: (_) => ResortService(api)),
      Provider<OrderService>(create: (_) => OrderService(api)),
      Provider<BenefitService>(create: (_) => BenefitService(api)),
      Provider<EngagementService>(create: (_) => EngagementService(api)),
      Provider<UserService>(create: (_) => UserService(api)),
      Provider<ReportService>(create: (_) => ReportService(api)),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(apiClient: api, authService: authService),
      ),
      ChangeNotifierProvider<NotificationProvider>(
        create: (context) => NotificationProvider(context.read<EngagementService>()),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('bs'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
