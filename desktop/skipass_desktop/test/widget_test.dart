import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipass_desktop/app.dart';
import 'package:skipass_desktop/core/theme/app_colors.dart';
import 'package:skipass_desktop/core/utils/formatters.dart';
import 'package:skipass_desktop/core/utils/validators.dart';
import 'package:skipass_desktop/models/ticket.dart';
import 'package:skipass_desktop/services/reference_data_service.dart';
import 'package:skipass_desktop/widgets/status_chip.dart';

void main() {
  testWidgets('SkiPassDesktopApp se pokrece i prikazuje pocetno stanje', (WidgetTester tester) async {
    await tester.pumpWidget(const SkiPassDesktopApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  group('Validatori korisnickog unosa', () {
    test('e-mail prihvata ispravan format i odbija neispravan', () {
      expect(Validators.email('admin@skipass.ba'), isNull);
      expect(Validators.email('bez-monkey.ba'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('telefon je opcion, ali mora biti ispravnog formata kada je unesen', () {
      expect(Validators.phone(null), isNull);
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('+387 61 100 100'), isNull);
      expect(Validators.phone('telefon'), isNotNull);
    });

    test('potvrda lozinke mora odgovarati unesenoj lozinci', () {
      expect(Validators.passwordConfirmation('test', 'test'), isNull);
      expect(Validators.passwordConfirmation('test1', 'test'), isNotNull);
    });

    test('korisnicko ime dozvoljava samo predvidjene znakove', () {
      expect(Validators.username('osoblje.haris'), isNull);
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('ime prezime'), isNotNull);
    });

    test('lozinka mora imati najmanje 4 znaka', () {
      expect(Validators.password('test'), isNull);
      expect(Validators.password('abc'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });
  });

  group('Formatiranje prikaza', () {
    test('iznos se prikazuje sa dvije decimale i valutom', () {
      expect(Formatters.money(113.4), contains('113'));
      expect(Formatters.money(113.4), endsWith('KM'));
    });

    test('jednodnevna karta prikazuje samo jedan datum', () {
      final day = DateTime(2026, 2, 14);
      expect(Formatters.dateRange(day, day), '14.02.2026');
      expect(Formatters.dateRange(day, DateTime(2026, 2, 16)), contains('-'));
    });

    test('broj dana i karata koristi ispravan oblik', () {
      expect(Formatters.days(1), '1 dan');
      expect(Formatters.days(3), '3 dana');
      expect(Formatters.tickets(1), '1 karta');
      expect(Formatters.tickets(3), '3 karte');
    });
  });

  group('Boje iz baze', () {
    test('HEX oznaka tezine staze se pretvara u boju', () {
      expect(AppColors.fromHex('#1E88E5'), const Color(0xFF1E88E5));
      expect(AppColors.fromHex('1E88E5'), const Color(0xFF1E88E5));
    });

    test('neispravna vrijednost vraca rezervnu boju', () {
      expect(AppColors.fromHex('nije-boja'), AppColors.primary);
      expect(AppColors.fromHex(null), AppColors.primary);
    });
  });

  group('Poslovna pravila na klijentu', () {
    test('cijena tipa karte uzima u obzir popust', () {
      const ticketType = TicketType(
        id: 1,
        name: 'Visednevna karta',
        pricePerDay: 42,
        maxDays: 7,
        discountPercentage: 10,
        isActive: true,
        skiResortId: 1,
        skiResortName: 'Bjelasnica',
      );

      // Ista formula koju server primjenjuje: 42 x 3 x 0.90 = 113.40
      expect(ticketType.priceFor(3), 113.40);
      expect(ticketType.priceFor(1), 37.80);
    });

    test('referentna konfiguracija pokriva svih osam sifarnika', () {
      expect(ReferenceTableConfig.all.length, 8);
      expect(ReferenceTableConfig.all.map((c) => c.resource).toSet().length, 8);

      final cities = ReferenceTableConfig.all.firstWhere((c) => c.resource == 'Cities');
      expect(cities.hasCountry, isTrue);
      expect(cities.hasPostalCode, isTrue);

      final paymentMethods = ReferenceTableConfig.all.firstWhere((c) => c.resource == 'PaymentMethods');
      expect(paymentMethods.hasCode, isTrue);
      expect(paymentMethods.hasActiveFlag, isTrue);
      expect(paymentMethods.hasDescription, isFalse);
    });
  });

  group('Prikaz statusa', () {
    test('statusi se prevode u razumljive oznake', () {
      expect(StatusStyles.order('Pending').label, 'Ceka placanje');
      expect(StatusStyles.order('Cancelled').label, 'Otkazana');
      expect(StatusStyles.ticket('Active').label, 'Aktivna');
      expect(StatusStyles.incident('Rejected').label, 'Odbijen');
    });

    testWidgets('oznaka stanja prikazuje tekst statusa', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusChip(style: StatusStyles.ticket('Active')),
          ),
        ),
      );

      expect(find.text('Aktivna'), findsOneWidget);
    });
  });
}
