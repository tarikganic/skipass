/// Skala razmaka. Sve margine i paddinzi izvedeni su iz osnovne jedinice od 4 px
/// kako bi razmaci kroz aplikaciju bili dosljedni.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontalni padding glavnog sadrzaja.
  static const double page = 32;

  /// Alias za `page`, koriste ga zajednicke komponente preuzete iz mobilne aplikacije.
  static const double screen = page;
}

/// Radijusi zaobljenja.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
  static const double pill = 999;
}

/// Dimenzije koje se ponavljaju kroz vise ekrana desktop aplikacije.
class AppSizes {
  const AppSizes._();

  static const double buttonHeight = 44;
  static const double inputHeight = 44;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double avatar = 40;

  /// Sirina bocne navigacije.
  static const double sidebarWidth = 240;

  /// Standardna sirina modalnih dijaloga za forme.
  static const double dialogWidth = 560;
  static const double wideDialogWidth = 760;

  /// Visina reda u tabelarnom prikazu.
  static const double tableRowHeight = 52;

  /// Sirina kartice u grid prikazima (staze, liftovi, usluge).
  static const double cardWidth = 260;
  static const double cardImageHeight = 140;
}
