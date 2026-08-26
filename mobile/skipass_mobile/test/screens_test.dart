import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skipass_mobile/core/api/api_client.dart';
import 'package:skipass_mobile/core/theme/app_theme.dart';
import 'package:skipass_mobile/l10n/app_localizations.dart';
import 'package:skipass_mobile/models/benefit.dart';
import 'package:skipass_mobile/models/home_summary.dart';
import 'package:skipass_mobile/models/order.dart';
import 'package:skipass_mobile/models/paged_result.dart';
import 'package:skipass_mobile/models/ski_lift.dart';
import 'package:skipass_mobile/models/ticket.dart';
import 'package:skipass_mobile/models/trail.dart';
import 'package:skipass_mobile/models/user.dart';
import 'package:skipass_mobile/providers/auth_provider.dart';
import 'package:skipass_mobile/providers/home_provider.dart';
import 'package:skipass_mobile/providers/notification_provider.dart';
import 'package:skipass_mobile/screens/announcements/announcements_screen.dart';
import 'package:skipass_mobile/screens/benefits/benefits_screen.dart';
import 'package:skipass_mobile/screens/home/home_screen.dart';
import 'package:skipass_mobile/screens/notifications/notifications_screen.dart';
import 'package:skipass_mobile/screens/tickets/my_tickets_screen.dart';
import 'package:skipass_mobile/screens/trails/trails_screen.dart';
import 'package:skipass_mobile/widgets/state_views.dart';
import 'package:skipass_mobile/services/auth_service.dart';
import 'package:skipass_mobile/services/catalog_service.dart';
import 'package:skipass_mobile/services/engagement_service.dart';
import 'package:skipass_mobile/services/purchase_service.dart';

import 'support/fake_api.dart';

/// Testovi provjeravaju da se ekrani ispravno iscrtavaju nad stvarnim
/// odgovorima API-ja, snimljenim sa pokrenutog servera.
void main() {
  // Podrazumijevana testna povrsina je 800x600, sto ne odgovara telefonu.
  // Ekrani se provjeravaju na dimenzijama uobicajenog Android uredjaja.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 3.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  group('Parsiranje stvarnih odgovora API-ja', () {
    test('pocetna stranica se mapira iz odgovora servera', () {
      final summary = HomeSummary.fromJson(FakeApi.readJson('home_summary'));

      expect(summary.skiResortName, isNotEmpty);
      expect(summary.totalTrailCount, greaterThan(0));
      expect(summary.totalLiftCount, greaterThan(0));
      expect(summary.openTrailCount, lessThanOrEqualTo(summary.totalTrailCount));
      expect(summary.operationalLiftCount, lessThanOrEqualTo(summary.totalLiftCount));
      expect(summary.weather, isNotNull);
      expect(summary.latestAnnouncements, isNotEmpty);
      expect(summary.featuredBenefits, isNotEmpty);
      // Radno vrijeme dolazi kao TimeOnly i mora se skratiti na sate i minute.
      expect(summary.openingTime, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('staze se mapiraju sa tezinom, statusom i uslovima', () {
      final page = PagedResult.fromJson(FakeApi.readJson('trails'), Trail.fromJson);

      expect(page.items, isNotEmpty);
      expect(page.totalCount, greaterThan(0));

      final trail = page.items.first;
      expect(trail.name, isNotEmpty);
      expect(trail.difficultyName, isNotEmpty);
      expect(trail.difficultyColorHex, startsWith('#'));
      expect(trail.lengthLabel, isNotEmpty);
      expect(
        ['Low', 'Moderate', 'High', 'VeryHigh'],
        contains(trail.crowdLevel),
      );
    });

    test('liftovi se mapiraju sa popunjenoscu u granicama 0-1', () {
      final page = PagedResult.fromJson(FakeApi.readJson('lifts'), SkiLift.fromJson);

      expect(page.items, isNotEmpty);
      for (final lift in page.items) {
        expect(lift.occupancyRatio, inInclusiveRange(0, 1));
      }
    });

    test('karte se mapiraju sa QR kodom i periodom vazenja', () {
      final page =
          PagedResult.fromJson(FakeApi.readJson('tickets'), SkiPassTicket.fromJson);

      expect(page.items, isNotEmpty);

      final ticket = page.items.first;
      expect(ticket.qrCode, isNotEmpty);
      expect(ticket.holderFullName.trim(), isNotEmpty);
      expect(ticket.validTo.isBefore(ticket.validFrom), isFalse);
    });

    test('pogodnosti imaju izracunatu cijenu sa popustom', () {
      final page = PagedResult.fromJson(FakeApi.readJson('benefits'), Benefit.fromJson);

      expect(page.items, isNotEmpty);
      for (final benefit in page.items) {
        expect(benefit.effectivePrice, lessThanOrEqualTo(benefit.price));
        if (!benefit.hasDiscount) {
          expect(benefit.effectivePrice, benefit.price);
        }
      }
    });

    test('narudzbe nose dozvoljene prelaze statusa sa servera', () {
      final page = PagedResult.fromJson(FakeApi.readJson('orders'), SkiPassOrder.fromJson);

      expect(page.items, isNotEmpty);
      for (final order in page.items) {
        expect(order.orderNumber, isNotEmpty);
        if (order.status == 'Cancelled' || order.status == 'Completed') {
          expect(order.allowedNextStatuses, isEmpty);
        }
      }
    });

    test('profil korisnika se mapira sa inicijalima za avatar', () {
      final user = AppUser.fromJson(FakeApi.readJson('me'));

      expect(user.fullName, isNotEmpty);
      expect(user.email, contains('@'));
      expect(user.initials.length, inInclusiveRange(1, 2));
    });
  });

  group('Iscrtavanje ekrana nad stvarnim podacima', () {
    testWidgets('pocetna prikazuje uslove, staze, liftove i obavijesti',
        (tester) async {
      final fake = FakeApi();
      await tester.pumpWidget(_wrap(fake.build(), HomeScreen(onNavigateToTab: (_) {})));
      await tester.pumpAndSettle();

      expect(find.text('Staze'), findsWidgets);
      expect(find.text('Ski liftovi'), findsOneWidget);
      expect(find.text('Trenutno na stazi'), findsOneWidget);
      expect(find.text('Najnovije obavijesti'), findsOneWidget);

      // Izdvojene pogodnosti su nize na stranici, pa se do njih dolazi skrolanjem.
      await tester.scrollUntilVisible(find.text('Izdvojene pogodnosti'), 300);
      expect(find.text('Izdvojene pogodnosti'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      expect(find.text('Preporuceno za vas'), findsOneWidget);
      expect(find.text('Iznajmljivanje skija Rossignol'), findsOneWidget);
      expect(find.text('Jer ste ranije kupili iz kategorije Iznajmljivanje opreme'), findsOneWidget);

      // Pocetna mora povuci summary i preporuke paralelno, a ne nizom odvojenih zahtjeva.
      expect(fake.requestedPaths, contains('/api/Home/summary'));
      expect(fake.requestedPaths, contains('/api/Recommendations/benefits'));
      expect(fake.requestedPaths.where((p) => p.startsWith('/api/')).length, 2);
    });

    testWidgets('pregled staza prikazuje kartice staza sa pretragom',
        (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const TrailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Staze i liftovi'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(TrailCard), findsWidgets);
    });

    testWidgets('moje karte prikazuju karticu karte sa QR akcijom',
        (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const MyTicketsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Moje karte'), findsOneWidget);
      expect(find.byType(TicketCard), findsWidgets);
      expect(find.text('Prikazi QR kod'), findsWidgets);
    });

    testWidgets('pogodnosti prikazuju listu sa cijenama', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const BenefitsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pogodnosti'), findsOneWidget);
      expect(find.byType(BenefitCard), findsWidgets);
    });

    testWidgets('obavijesti se prikazuju kao lista', (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const AnnouncementsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Obavijesti'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.textContaining('Detaljnije'), findsWidgets);
    });

    testWidgets('notifikacije prikazuju listu i akciju za oznaku procitano',
        (tester) async {
      await tester.pumpWidget(_wrap(FakeApi().build(), const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notifikacije'), findsOneWidget);
      expect(find.text('Oznaci sve'), findsOneWidget);
    });
  });

  group('Stanja praznog prikaza i greske', () {
    testWidgets('prazna lista staza nudi ponistavanje filtera', (tester) async {
      final fake = FakeApi(overrides: {
        '/api/Trails':
            '{"items":[],"totalCount":0,"page":1,"pageSize":20,"totalPages":0,'
                '"hasPreviousPage":false,"hasNextPage":false}',
      });

      await tester.pumpWidget(_wrap(fake.build(), const TrailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Nema staza za zadate uslove'), findsOneWidget);
      expect(find.text('Ponisti filtere'), findsOneWidget);
    });

    testWidgets('greska servera se prikazuje kroz poruku koju je server poslao',
        (tester) async {
      final fake = FakeApi(overrides: {
        '/api/Trails': '__ERROR__',
      });

      await tester.pumpWidget(_wrap(fake.build(), const TrailsScreen()));
      await tester.pumpAndSettle();

      // Prikazuje se komponenta za gresku sa porukom servera, a ne genericki tekst.
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Podatke nije moguce ucitati'), findsOneWidget);
      expect(find.text('Skijaliste trenutno nije dostupno.'), findsOneWidget);
      expect(find.text('Pokusaj ponovo'), findsOneWidget);
    });
  });
}

/// Postavlja servise i teme oko ekrana koji se testira.
Widget _wrap(ApiClient api, Widget child) {
  final authService = AuthService(api);

  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      Provider<AuthService>.value(value: authService),
      Provider<CatalogService>(create: (_) => CatalogService(api)),
      Provider<PurchaseService>(create: (_) => PurchaseService(api)),
      Provider<EngagementService>(create: (_) => EngagementService(api)),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(apiClient: api, authService: authService),
      ),
      ChangeNotifierProvider<HomeProvider>(
        create: (context) => HomeProvider(context.read<CatalogService>()),
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
      home: child,
    ),
  );
}

