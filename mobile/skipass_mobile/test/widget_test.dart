import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipass_mobile/core/theme/app_colors.dart';
import 'package:skipass_mobile/core/utils/formatters.dart';
import 'package:skipass_mobile/core/utils/validators.dart';
import 'package:skipass_mobile/l10n/app_localizations.dart';
import 'package:skipass_mobile/models/ticket.dart';
import 'package:skipass_mobile/widgets/status_chip.dart';

void main() {
  group('Validatori korisnickog unosa', () {
    test('e-mail prihvata ispravan format i odbija neispravan', () {
      expect(Validators.email('tarik@skipass.ba'), isNull);
      expect(Validators.email('bez-monkey.ba'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('telefon je opcion, ali mora biti ispravnog formata kada je unesen', () {
      expect(Validators.phone(null), isNull);
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('+387 61 123 456'), isNull);
      expect(Validators.phone('telefon'), isNotNull);
    });

    test('potvrda lozinke mora odgovarati unesenoj lozinci', () {
      expect(Validators.passwordConfirmation('test', 'test'), isNull);
      expect(Validators.passwordConfirmation('test1', 'test'), isNotNull);
    });

    test('korisnicko ime dozvoljava samo predvidjene znakove', () {
      expect(Validators.username('skijas.haris'), isNull);
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('ime prezime'), isNotNull);
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
    test('cijena karte uzima u obzir popust tipa karte', () {
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

    test('karta van perioda vazenja nije upotrebljiva danas', () {
      final past = _ticket(
        status: 'Active',
        validFrom: DateTime.now().subtract(const Duration(days: 10)),
        validTo: DateTime.now().subtract(const Duration(days: 8)),
      );

      final today = _ticket(
        status: 'Active',
        validFrom: DateTime.now(),
        validTo: DateTime.now(),
      );

      final cancelled = _ticket(
        status: 'Cancelled',
        validFrom: DateTime.now(),
        validTo: DateTime.now(),
      );

      expect(past.isValidToday, isFalse);
      expect(today.isValidToday, isTrue);
      expect(cancelled.isValidToday, isFalse);
    });
  });

  group('Prikaz statusa', () {
    testWidgets('statusi se prevode u razumljive oznake', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('bs'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      expect(StatusStyles.order(capturedContext, 'Pending').label, 'Ceka placanje');
      expect(StatusStyles.order(capturedContext, 'Cancelled').label, 'Otkazana');
      expect(StatusStyles.ticket(capturedContext, 'Active').label, 'Aktivna');
      expect(StatusStyles.incident(capturedContext, 'Rejected').label, 'Odbijen');
    });

    testWidgets('oznaka stanja prikazuje tekst statusa', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('bs'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: StatusChip(style: StatusStyles.ticket(context, 'Active')),
            ),
          ),
        ),
      );

      expect(find.text('Aktivna'), findsOneWidget);
    });
  });
}

SkiPassTicket _ticket({
  required String status,
  required DateTime validFrom,
  required DateTime validTo,
}) {
  return SkiPassTicket(
    id: 1,
    qrCode: 'SP-TEST',
    holderFullName: 'Lejla Music',
    validFrom: DateTime(validFrom.year, validFrom.month, validFrom.day),
    validTo: DateTime(validTo.year, validTo.month, validTo.day),
    numberOfDays: 1,
    price: 45,
    status: status,
    orderId: 1,
    orderNumber: 'SP-TEST-0001',
    ticketTypeName: 'Dnevna karta',
    skiResortName: 'Bjelasnica',
    validationCount: 0,
  );
}
